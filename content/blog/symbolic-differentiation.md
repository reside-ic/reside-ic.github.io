---
author: "Rich FitzJohn"
title: "Symbolic differentiation in a few lines of code"
date: 2023-06-26
tags:
- R
---

<!--
Render original source Rmd with:

Rscript -e 'rmarkdown::render("symbolic-differentiation.Rmd", output_format=rmarkdown::md_document(preserve_yaml = TRUE, variant = "markdown_github"))'

-->

We are working on [automatic
differentiation](https://en.wikipedia.org/wiki/Automatic_differentiation)
of [odin](https://mrc-ide.github.io/odin/) models, which requires
support for differentiating expressions symbolically, in order to write
new equations that can be used to numerically propagate derivatives of a
model.

R already has support for doing this via the `D` function:

``` r
D(quote(2 * x^2 * log(sqrt(x))), "x")
```

    ## 2 * (2 * x) * log(sqrt(x)) + 2 * x^2 * (0.5 * x^-0.5/sqrt(x))

and the [`Deriv`](https://cran.r-project.org/package=Deriv) package
provides an extensible interface. However, `odin` has peculiar syntax
with arrays and we’re interested in trying to differentiate through
stochastic functions, so a bespoke solution felt useful.

Symbolic differentiation turns out to be surprisingly easy, and quite
elegant, to implement; this post shows the general idea.

To start, consider differentiating the expression `x^2 + x^3` with
respect to `x`. Recall the mechanical rules of differentiation from
school that we can write this as `d/dx x^2 + d/dx x^3` and then that we
differentiate functions of the form `x^n` as `n x^(n - 1)` – this is the
primary insight we need: that the process is recursive as we break down
every operation into smaller chunks and keep on differentiating interior
expressions with respect to `x` until there’s nothing left.

The simplest possible differentiation rules concern numbers; `d/dx n`
for any number `n` is zero (that is, the gradient of `n` with respect to
`x` is zero). Similarly, for any symbol (say `a` but not `a + b`)
*except* `x` the derivative is also zero. And the derivative of `x` with
respect to `x` is one. With this, we have the edge case for a recursive
function:

``` r
differentiate <- function(expr, name) {
  if (!is.recursive(expr)) {
    if (identical(expr, as.symbol(name))) 1 else 0
  } else {
    stop("not yet implemented")
  }
}
```

which we can apply like so:

``` r
differentiate(quote(x), "x")
```

    ## [1] 1

``` r
differentiate(quote(a), "x")
```

    ## [1] 0

``` r
differentiate(quote(1), "x")
```

    ## [1] 0

Interesting expressions are not supported yet:

``` r
differentiate(quote(x + x * x), "x")
```

    ## Error in differentiate(quote(x + x * x), "x"): not yet implemented

To implement the case where we have compound expressions
(`is.recursive(expr)` returning `TRUE`), consider the way we can
represent these expressions:

``` r
expr <- quote(x + x * x)
as.list(expr)
```

    ## [[1]]
    ## `+`
    ## 
    ## [[2]]
    ## x
    ## 
    ## [[3]]
    ## x * x

Every call can be represented this way - the first element is the
function being called and the remaining elements are its arguments. This
structure is recursive:

``` r
as.list(expr[[3]])
```

    ## [[1]]
    ## `*`
    ## 
    ## [[2]]
    ## x
    ## 
    ## [[3]]
    ## x

To apply our differentiation rules we need to describe how to handle
each function (here, `+` and `*`) and put together the results,
descending into the subexpressions with `differentiate()` again until we
get our edge cases.

The rule for differentiating sums is very straightforward, as noted
above: we take the sum of the derivatives!

``` r
d_plus <- function(expr, name) {
  call("+", differentiate(expr[[2]], name), differentiate(expr[[3]], name))
}
```

The `call()` function constructs expression arguments (so
`call("+", quote(x), 1)` returns `x + 1`) and here we are descending
into each expression with `differentiate()`. We then rewrite
`differentiate()` to call `d_plus()` when required:

``` r
differentiate <- function(expr, name) {
  if (!is.recursive(expr)) {
    if (identical(expr, as.symbol(name))) 1 else 0
  } else {
    fn <- as.character(expr[[1]])
    switch(fn,
           "+" = d_plus(expr, name),
           stop("not yet implemented"))
  }
}
```

With this we can differentiate a sum of any depth:

``` r
differentiate(quote(x + 5), "x")
```

    ## 1 + 0

``` r
differentiate(quote(x + y + x), "x")
```

    ## 1 + 0 + 1

We can then proceed, writing out rules for different functions as we
need them. For example, the product rule:

``` r
d_product <- function(expr, name) {
  a <- expr[[2]]
  b <- expr[[3]]
  da <- differentiate(a, name)
  db <- differentiate(b, name)
  call("+", call("*", da, b), call("*", a, db))
}
```

or the quotient rule

``` r
d_quotient <- function(expr, name) {
  a <- expr[[2]]
  b <- expr[[3]]
  da <- differentiate(a, name)
  db <- differentiate(b, name)
  ## da / b - a * db / (b * b)
  call("-", call("/", da, b), call("/", call("*", a, db), call("*", b, b)))
}
```

For subtraction, we need to distinguish between unary minus (e.g., `-a`)
and subtraction (e.g., `a - b`)

``` r
d_minus <- function(expr, name) {
  if (length(expr) == 2) {
    call("-", differentiate(expr[[2]], name))
  } else {
    call("-", differentiate(expr[[2]], name), differentiate(expr[[3]], name))
  }
}
```

It turns out that `(` is a function too, and also needs a rule, but it
is very simple:

``` r
d_parenthesis <- function(expr, name) {
  call("(", differentiate(expr[[2]], name))
}
```

We can put all these rules into a list:

``` r
rules <- list(
  "+" = d_plus,
  "-" = d_minus,
  "*" = d_product,
  "/" = d_quotient,
  "(" = d_parenthesis)
```

and rewrite our `differentiate()` implementation again:

``` r
differentiate <- function(expr, name) {
  if (!is.recursive(expr)) {
    if (identical(expr, as.symbol(name))) 1 else 0
  } else {
    fn <- as.character(expr[[1]])
    if (!(fn %in% names(rules))) {
      stop(sprintf("Differentiation of '%s' not yet implemented", fn))
    }
    rules[[fn]](expr, name)
  }
}
```

and with this we can differentiate all sorts of things:

``` r
differentiate(quote(-2 * x / (x * x - 3 * x)), "x")
```

    ## (-0 * x + -2 * 1)/(x * x - 3 * x) - -2 * x * (1 * x + x * 1 - 
    ##     (0 * x + 3 * 1))/((x * x - 3 * x) * (x * x - 3 * x))

This is fine, except that the generated expressions are fairly ugly,
with lots of obviously redundant expressions (e.g., `-0 * x` which is
obviously `0` and `+ -2 * 1` which is just `- 2`). However, the
expressions agree with those from `D` once evaluated:

``` r
eval(differentiate(quote(-2 * x / (x * x - 3 * x)), "x"), list(x = pi))
```

    ## [1] 99.75819

``` r
eval(D(quote(-2 * x / (x * x - 3 * x)), "x"), list(x = pi))
```

    ## [1] 99.75819

Extending the implementation by adding more rules
-------------------------------------------------

We could extend this easily now by adding more rules, and the
implementation will even tell us what we need to add. So if we try and
evaluate

``` r
differentiate(quote(exp(2 * x)), "x")
```

    ## Error in differentiate(quote(exp(2 * x)), "x"): Differentiation of 'exp' not yet implemented

we get told to we need to implement the rule for `exp` which is simply:

``` r
d_exp <- function(expr, name) {
  call("*", differentiate(expr[[2]], name), expr)
}
```

(that is, `d/dx exp(f(x))` is `f'(x) exp(f(x)))`. We add this to our set
of rules:

``` r
rules$exp <- d_exp
```

and now we can differentiate this new expression:

``` r
differentiate(quote(exp(2 * x)), "x")
```

    ## (0 * x + 2 * 1) * exp(2 * x)

Improving the implementation by writing sensible expressions
------------------------------------------------------------

Simplifying the expressions turns out to be much more work than the
differentiation. The trick that we use is to avoid using `call()`
directly to build expressions and create a simplifying expression
builder that applies some simple rules to avoid building overly
complicated expressions. This does not simplify everything, but cuts out
the most egregious bits of noise.

This is probably not important for the efficiency of generated code
(we’re going to send this to an optimising compiler via some C++ code
eventually) but it does make the resulting expressions easier to think
about.

Consider replacing `call("+", a, b)` with something that will avoid
creating silly expressions. If given numeric arguments for `a` and `b`
we should sum them, and if either of `a` or `b` is zero we should return
the other argument:

``` r
m_plus <- function(a, b) {
  if (is.numeric(a) && is.numeric(b)) {
    a + b
  } else if (is.numeric(b)) {
    m_plus(b, a)
  } else if (is.numeric(a) && a == 0) {
    b
  } else {
    call("+", a, b)
  }
}
```

The pattern here is that only the last branch gives up and actually
builds an expression with `call()`

``` r
m_plus(3, 4)
```

    ## [1] 7

``` r
m_plus(quote(a), 0)
```

    ## a

``` r
m_plus(quote(a), 1)
```

    ## 1 + a

``` r
m_plus(0, quote(b))
```

    ## b

``` r
m_plus(1, quote(b))
```

    ## 1 + b

``` r
m_plus(quote(a), quote(b))
```

    ## a + b

We can do similar things with multiplication:

``` r
m_product <- function(a, b) {
  if (is.numeric(a) && is.numeric(b)) {
    a * b
  } else if (is.numeric(b)) {
    m_product(b, a)
  } else if (is.numeric(a) && a == 0) {
    0
  } else if (is.numeric(a) && a == 1) {
    b
  } else {
    call("*", a, b)
  }
}
m_product(3, 4)
```

    ## [1] 12

``` r
m_product(quote(a), 0)
```

    ## [1] 0

``` r
m_product(quote(a), 1)
```

    ## a

``` r
m_product(quote(a), 2)
```

    ## 2 * a

``` r
m_product(quote(a), quote(b))
```

    ## a * b

unary minus

``` r
is_call <- function(x, name) {
  is.recursive(x) && as.character(x[[1]]) == name
}
m_uminus <- function(a) {
  if (is.numeric(a)) {
    -a
  } else if (length(a) == 2 && identical(a[[1]], quote(`-`))) {
    a[[2]]
  } else if (is_call(a, "(")) {
    m_uminus(a[[2]])
  } else {
    call("-", a)
  }
}
```

subtraction

``` r
m_minus <- function(a, b) {
  if (is.numeric(a) && is.numeric(b)) {
    a - b
  } else if (is.numeric(a) && a == 0) {
    m_uminus(b)
  } else if (is.numeric(b) && b == 0) {
    a
  } else {
    call("-", a, b)
  }
}
```

and division

``` r
m_quotient <- function(a, b) {
  if (is.numeric(a) && is.numeric(b)) {
    a / b
  } else if (is.numeric(a) && a == 0) {
    0
  } else if (is.numeric(b) && b == 0) {
    Inf
  } else if (is.numeric(b) && b == 1) {
    a
  } else {
    call("/", a, b)
  }
}
```

Finally, parentheses (this is done differently in our implementation but
this is a little simpler):

``` r
m_parenthesis <- function(a) {
  if (is.symbol(a) || is.numeric(a)) {
    a
  } else {
    call("(", a)
  }
}
```

We can then rewrite all our rules to use these functions instead of
`call()` directly:

``` r
d_plus <- function(expr, name) {
  m_plus(differentiate(expr[[2]], name), differentiate(expr[[3]], name))
}

d_minus <- function(expr, name) {
  if (length(expr) == 2) {
    m_uminus(differentiate(expr[[2]], name))
  } else {
    m_minus(differentiate(expr[[2]], name), differentiate(expr[[3]], name))
  }
}

d_product <- function(expr, name) {
  a <- expr[[2]]
  b <- expr[[3]]
  da <- differentiate(a, name)
  db <- differentiate(b, name)
  m_plus(m_product(da, b), m_product(a, db))
}

d_quotient <- function(expr, name) {
  a <- expr[[2]]
  b <- expr[[3]]
  da <- differentiate(a, name)
  db <- differentiate(b, name)
  ## da / b - a * db / (b * b)
  m_minus(m_quotient(da, b), m_quotient(m_product(a, db), m_product(b, b)))
}

d_parenthesis <- function(expr, name) {
  m_parenthesis(differentiate(expr[[2]], name))
}

rules <- list(
  "+" = d_plus,
  "-" = d_minus,
  "*" = d_product,
  "/" = d_quotient,
  "(" = d_parenthesis)
```

Now, when we call `differentiate()`, things look much nicer:

``` r
differentiate(quote(-2 * x / (x * x - 3 * x)), "x")
```

    ## -2/(x * x - 3 * x) - -2 * x * (x + x - 3)/((x * x - 3 * x) * 
    ##     (x * x - 3 * x))

There are still some weirdnesses here (e.g., `a - -2 * x * (x + x - 3)`
which are surprisingly hard to undo; the rhs of this expression is a
tree with structure:

``` r
lobstr::ast(-2 * x * (x + x - 3))
```

    ## █─`*` 
    ## ├─█─`*` 
    ## │ ├─█─`-` 
    ## │ │ └─2 
    ## │ └─x 
    ## └─█─`(` 
    ##   └─█─`-` 
    ##     ├─█─`+` 
    ##     │ ├─x 
    ##     │ └─x 
    ##     └─3

so to simplify subtraction we have to extract the `-` from within two
layers of multiplication, which is yet more recursion.

Our full implementation can be seen in [this pull
request](https://github.com/mrc-ide/odin/pull/298/files), which follows
the presentation here fairly closely.

Why go to this effort?
----------------------

Given that the `D` function (and the
[`Deriv`](https://cran.r-project.org/package=Deriv) package) can do all
this (and more) already, it’s not very obvious why you might want to
this. We don’t really want to differentiate R, but instead the domain
specific language that supports odin. This is a [small subset of
R](https://mrc-ide.github.io/odin/articles/functions.html) but there are
two things that have quite different semantics that we need considerable
control over (they’re not yet supported in the PR linked above).

Firstly, odin (via [odin.dust](https://mrc-ide.github.io/odin.dust/))
supports converting stochastic models into deterministic ones by taking
expectations of the stochastic components; the underlying stochastic
support already looks different to the call expected from R. So for
example, we might write:

``` r
m <- rbinom(n, p)
```

to represent a binomial random draw with size `n` and probability `p`;
R’s first argument (the number of draws to take) does not appear here.
The expectation of this draw is simply `n * p` and we can now easily add
rules to our differentiation support to differentiate this part of a
model with respect to any other model quantity.

The other tricky part we have is the way that odin interprets array
expressions, especially those that contain sums, as these have specific
semantics. For example, the valid odin expression

``` r
lambda[] <- beta * sum(s_ij[, i])
```

could be rewritten as in something more R-ish

``` r
for (i in seq_along(lambda)) {
  lambda[i] <- beta * sum(s_ij[, i])
}
```

and differentiating the odin DSL version requires knowledge of this
semantics. The solution to this is left as an exercise to the reader, ad
possibly a future blog post…
