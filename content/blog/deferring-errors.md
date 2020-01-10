---
author: "Rich FitzJohn"
date: 2019-08-09
title: Deferring errors with R
tags:
 - R
---

How do you run a block of code and collect up all the errors in order to report them back in a batch?  This is the sort of thing that might turn up in a validation exercise where we want to check a number of properties of the provided data and then report back in one go all the errors so that the user can fix multiple problems at each upload attempt.




For example suppose that `check_*` are functions that verify some property of a data set; we might want to run

```
function(d) {
  check_rows(d)
  check_cols(d)
  check_missing(d)
  d
}
```

and all the separate errors reported back at once so that we might see output like:

```
Error: 3 errors reported:
  - too few rows uploaded (expected at least 10)
  - too many columns uploaded (expected at most 5)
  - missing data detected in columns 2, 3
```

The trick is _keeping going_ after the first error, and not jumping back out to the top level.  We could do this manually like:

```
function(d) {
  errors <- NULL
  tryCatch(
    check_rows(d),
    error = function(e) errors <<- c(errors, e$message))
  ...
  if (length(errors) > 0) {
    # ... throw nicely
  }
  d
}
```

but this is going to massively increase the complexity of our validation function.

R has a super-flexible error handling system, but I never usually use anything more complicated than `tryCatch` above.  But it must be possible to do this because [`testthat`](https://testthat.r-lib.org/) does exactly this within `test_that` blocks.  It turns out that it's not too bad.

First, we define a special error type that we will deem continuable.  To indicate this, add a custom class (here using `deferrable_error`) and throw this error wrapped with `withRestarts` and a dummy restart function


```r
deferrable_error <- function(message) {
  e <- structure(list(message = message),
                 class = c("deferrable_error", "error", "condition"))
  withRestarts(
    stop(e),
    continue_deferrable_error = function(...) NULL)
}
```

This can be be used approximately like `stop`:


```r
deferrable_error("something bad happened")
```

```
## Error: something bad happened
```

as in it will throw an error and prevent continuing beyond this statement within a block:


```r
local({
  message("will be printed")
  deferrable_error("something bad happened")
  message("will not be reached")
})
```

```
## will be printed
```

```
## Error: something bad happened
```

In order to actually defer the error, we need to add a calling handler that will intercept the `deferrable_error` and invoke the `continue_deferrable_error` restart (which will mean that execution will continue):


```r
defer_errors <- function(expr, call = FALSE) {
  errors <- list()

  value <- withCallingHandlers(
    expr,
    deferrable_error = function(e) {
      errors <<- c(errors, e$message)
      invokeRestart("continue_deferrable_error")
    })

  if (length(errors) > 0L) {
    stop(sprintf("%d %s occurred:\n%s",
                 length(errors),
                 ngettext(length(errors), "error", "errors"),
                 paste0("  - ", errors, collapse = "\n")),
         call. = call)
  }

  value
}
```

So when an error of `deferrable_error` occurs, `withCallingHandlers` invokes the handler which collects the error up for later, then invokes the restart (registered by the error itself) which does nothing but _somehow_ signals that we can continue.

So, `defer_errors` is a function that will accept a code block as its argument, and will accumulate errors into an internal list, throwing if at least one error was observed.  An ordinary error will throw straight away.

As a trivial example


```r
check_positive <- function(x) {
  if (x < 0) {
    deferrable_error(paste("got a negative number:", x))
  }
}
```

Running a block of code that throws only `deferrable_error` (and not `stop`) will reach the bottom of the block and throw


```r
defer_errors({
  check_positive(0)
  check_positive(-1)
  check_positive(-2)
})
```

```
## Error: 2 errors occurred:
##   - got a negative number: -1
##   - got a negative number: -2
```

A slightly tidied version of this code is available in a [micro R package `defer`](https://github.com/reside-ic/defer).

This sort of approach might be useful when there is a large upfront cost that you don't want to pay on each verification cycle (e.g., loading a large file, uploading a file to a server etc).  On the other hand, if validation *should* stop after a set of errors, this pattern might make things more complicated - for example errors generated checking that column names are distinct will likely be nonsensical in the case where a table does not contain column names!

For the validation case, there is an R package [`assertr`](https://github.com/ropensci/assertr#what-does-it-look-like) that can collect assertion errors in a pattern like the above, though it does not use a restart approach.
