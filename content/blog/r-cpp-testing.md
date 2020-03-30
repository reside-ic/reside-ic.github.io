---
author: "Giovanni Charles"
date: 2020-03-30
title: "Gotta catch 'em all"
best: false
tags:
 - R
 - C++
---

Great packages have great test suites. Packages with C++ are not exceptions. You
might be surprised to find how easy it is to add C++ unittests to your package.

This post will focus on [testthat](https://github.com/r-lib/testthat)'s
[Catch](https://github.com/catchorg/Catch2) integration.
There are plenty of C++ testing frameworks, each with their own pros and cons.
The benefit of this approach is the really low setup cost and no dependency
management.

# Set up

The first step is to add some boilerplate to your package. Enter
`testthat::use_catch()`. Make sure to follow the instructions in the command
output to configure your package correctly.

Now you can run all of your tests with `devtools::test()` or `R CMD check`!

# Writing your tests

As soon as you start writing tests you may say, "hang on a minute, where are all
my assertions?". You would be right to worry. Testthat.h only provides 4
assertions:

 * expect_true
 * expect_false
 * expect_error
 * expect_error_as

That leaves a lot to be desired, not to mention unhelpful error messages when
your tests fail.

At this point it's helpful to explain that testthat.h simply gives you sugar to
make a catch test _look_ like a more familiar testthat test. If you dig into the
header you'll find that `test_that` is defined as `CATCH_SECTION` and 
`expect_true` is defined as `CATCH_CHECK`.

You can find a much larger list of
straightfoward and extensive Catch assertions on
[github](https://github.com/catchorg/Catch2/blob/master/docs/assertions.md).
And they can be accessed through the testthat API by prefixing them with `CATCH_`.

So the secret here is to use Catch directly. Let's say, for example, that you
would like to test your own square root function `sqrt`. You could write the
test like so:

```
#include <testthat.h> /* context, test_that, CATCH_REQUIRE, Approx */
#include "my_math.h" /* sqrt */

context("My math library") {
    test_that("Squareroot of 2 is correct") {
        CATCH_REQUIRE(sqrt(2) == Approx(1.41421356237));
    }
}
```

Notice how catch provides a helpful `Approx` class to handle the comparison
of real numbers.

And when I stub my `sqrt` function, I get a helpful error message like below:

```
test-math.cpp:XX: FAILED:
  CATCH_REQUIRE( sqrt(2) == Approx(1.41421356237) )
with expansion:
  2 == Approx(1.41421356237)
```

# Logging

When making your tests pass, it's useful to see what's going on with your code.
Unfortunately the default test runner swallows the standard output stream. Even
`CATCH_INFO` fails to release any output onto the screen.

To keep your logs visible you have to write to standard error (`Rcpp::cerr`) or
to a file. So it is useful to have a configurable logger early in development.

Happy coding!
