---
author: "Rich FitzJohn"
title: "A warning about warning()"
date: 2020-07-06
tags:
- R
---

I believe that `warning()` should be used very rarely in R - it's a weird function that is partly logging and partly flow control but doesn't do a great job at either. Package authors use `warning` for a range of conditions ranging from informational through to catastrophic and users are left ignoring warnings due to the former or debugging issues a significant distance from the source due to the latter.

## Background

R provides 3[^1] main mechanisms for reporting information back to a user about how a function is progressing:

* `message()` which displays an informational message and can be used for logging
* `stop()` which aborts the current computation with a message about what went wrong
* `warning()` which, well, is the topic of this blog post

On the surface warnings seem useful -- they provide a mechanism for telling the user that something fairly bad has happened that probably warrants their attention, but that the program will try and continue on anyway.  A "WARN" logging level is available in popular logging frameworks, so this *is* a common use case.

However, there's a lot of uncertainty in that statement and it leads to very difficult to track down errors.  For example:

```r
f <- function(n) {
 rnorm(n)
}
f("two")
#> Error in rnorm(n) : invalid arguments
#> In addition: Warning message:
#> In rnorm(n) : NAs introduced by coercion
```

Sometimes these "helpful" warn-and-continue effects continue as the NA or zero-length vector created wrecks havoc on your code leading to "missing value where TRUE/FALSE needed" or "argument is of length zero" type errors where they finally hit an `if` statement, with the actual problem now quite distant from the solution.

Aha, but you can turn warnings into errors, and then use normal error handling to investigate?

```r
options(warn = 2)
f("two")
#> Error in rnorm(n) : (converted from warning) NAs introduced by coercion
```

which is fine if your warning is the *first* warning to occur.  But if your code is littered with "informational warnings" then the error will be thrown before your new error is reached.

By default R only shows the last 10 warnings, and only keeps hold of the last 50, so it's not guaranteed you'll be able to read the warning that really caused the problem.

## The problem

Base R is filled with cases where warnings are used where errors would have been more appropriate:

```r
readRDS("nosuchfile")
#> Error in gzfile(file, "rb") : cannot open the connection
#> In addition: Warning message:
#> In gzfile(file, "rb") :
#>   cannot open compressed file 'nosuchfile', probable reason 'No such file or directory'
```

Here, `gzfile` tries to open a file which doesn't exist, "throws" a warning, then just lets the program continue, passing back a connection object that cannot be read from. When something does read from it, it ends badly. However, the true error (the file does not exist) is obscured as a warning and the user is left holding a weirder one ("cannot open a connection").

Once you add in the maximum number of warnings issue, things get more annoying.  Consider a completely silly example:

```r
local({
  for (i in 1:50) {
    Sys.timezone(FALSE)
  }
  readRDS("nosuchfile")
})
#> Error in gzfile(file, "rb") : cannot open the connection
#> In addition: There were 50 or more warnings (use warnings() to see the first 50)
```

Similar to above, except we do not get the real error here anymore. Worse, when following the instructions and running `warnings()` our true error is not found as every warning printed is about a defunct argument to `Sys.timezone`

```r
#> 1: Sys.timezone(location = FALSE) is defunct and ignored
#> 2: Sys.timezone(location = FALSE) is defunct and ignored
...
#> 50: Sys.timezone(location = FALSE) is defunct and ignored
```

This means that the catastrophic warning produced by `readRDS` is swamped by the informational one by `Sys.timezone` and the user has limited information with which to start debugging.

The above example is obviously contrived but it's not that hard to accumulate 50 warnings - many packages are quite chatty with warnings as many packages use them for informational messages. Alternatively, you might have `options(warnPartialMatchDollar = TRUE)` set so that partial matching produces warnings and have used code like

```r
seq(1, 10, length = 11)
#>  [1]  1.0  1.9  2.8  3.7  4.6  5.5  6.4  7.3  8.2  9.1 10.0
#> Warning message:
#> In seq.default(1, 10, length = 11) :
#>   partial argument match of 'length' to 'length.out'
```

There are really very many warnings produced by base R that should be considered as errors, and they are too easy to ignore.  Things like

```r
y <- Map(`+`, 1:5, 1:4)
#> Warning message:
#> In mapply(FUN = f, ..., SIMPLIFY = FALSE) :
#>   longer argument not a multiple of length of shorter
```

are almost always a bug and should be verified and fixed.  The use of warning here makes this job harder for you as a programmer - try not to impose this same cost on your users.

## When are warnings OK?

The most common case where I feel that warnings are absolutely the right choice is deprecating features.  If your package will soon stop supporting a feature (removing an argument, changing a data format), the program _can_ continue, and you want the user to update the call, then warnings provide a good way of conveying that.

```r
package::function(a = 1)
#> Warning message:
#> In f(1) : Use of argument 'a' is deprecated, please use 'b'
```

this approach has been formalised in both base R (`?.Deprecated`) and within the tidyverse's ["lifecycle" package](https://cran.r-project.org/web/packages/lifecycle/vignettes/lifecycle.html#deprecating-arguments)

## Dealing with warnings in other packages

If you're writing a package and using another package which creates warnings, you're left with two options - either pass them along to your user or suppress them. There are times where both are the least bad option (suppressing informational warnings leads to potentially suppressing showstopping warnings). There's `suppressWarnings()` which prevents all warnings coming out of any piece of code:

```r
local({
  for (i in 1:50) {
    suppressWarnings(Sys.timezone(FALSE))
  }
  readRDS("nosuchfile")
})
#> Error in gzfile(file, "rb") : cannot open the connection
#> In addition: Warning message:
#> In gzfile(file, "rb") :
#>   cannot open compressed file 'nosuchfile', probable reason 'No such file or directory'
```

However this is a big hammer and should be wrapped around the smallest piece of code possible. You might write your own warning handlers that filter bad warnings and make them worse. For example, `install.packages` does not throw an error when installation fails:

```r
install.packages("nosuchpackage")
#> Warning message:
#> package ‘nosuchpackage’ is not available (for R version 3.6.1)
```

(there is a similar error when installation fails during compilation, which prints a big "ERROR" but only raises a warning). We might wrap `install.packages` using `withCallingHandlers` and look for this warning, converting it into an error, while allowing other warnings to remain warnings:

```r
install_packages2 <- function(pkgs, ...) {
  rethrow_failure <- function(e) {
    is_failure <-
      grepl("package.*(is|are) not available", e$message) ||
      grepl("installation of package.*had non-zero exit status", e$message)
    if (is_failure) {
      stop(e$message, call. = FALSE)
    }
  }
  withCallingHandlers(utils::install.packages(pkgs, ...),
                      warning = rethrow_failure)
}
```

with this, a failed installation will error:

```r
install_packages2("nosuchpackage")
#> Error: package ‘nosuchpackage’ is not available (for R version 3.6.1)
```

However, this is fragile as we're matching on a warning string, which only works in an English locale and may change at any point.

## TL;DR

In my opinion, most of the time people use `warning` it would be better as `message` or `stop`. Don't display a warning and continue if there's a good chance that the program will not run correctly and don't bother the user with a warning if it's just informational.

[^1]: There is also the confusingly named `print` function, which is often used where `message` (or `cat`) is better.  This leads to lots of logs of the form `[1] "my message here"` in people's logs. The `print` function seems intended to display a human-readable version of an object, rather than as a replacement for (say) Python's `print` function (most of the time writing a method for `format` seems the best way to write a custom print method, meaning the combination of `print` and `format` behaves similarly to python's `__str__` methods.
