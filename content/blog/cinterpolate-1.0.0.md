---
author: "Rich FitzJohn"
date: 2019-04-15
title: cinterpolate 1.0.0
best: false
tags:
 - cinterpolate
 - R
---

Last week we released the first official version of [`cinterpolate`](https://mrc-ide.github.io/cinterpolate/) to [available on CRAN](https://cran.r-project.org/package=cinterpolate).  This package provides a minimal set of interpolation methods (piecewise constant, linear and spline) designed to be compatible with R's builtin [`approx`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/approxfun.html) and [`spline`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/splinefun.html) functions, but but callable from C. It will primarily be of interest to people writing R packages that include C or C++.

When writing an R package with C or C++ extensions, you have to forgo many of the the functions that make operating in a high-level easy.  R's C API (and Rcpp, which reflects it) includes [lots of helper functions](https://cran.r-project.org/doc/manuals/R-exts.html#Numerical-analysis-subroutines) for common tasks but this is a small list compared to what you might want to do from R.

In [`odin`](https://mrc-ide.github.io/odin/) we need to be able to interpolate functions of time (e.g., a trace of temperature against time, or a square wave representing pulses of interventions) from C code.  For piecewise constant and linear functions this is straightforward, but for splines it is a [little more involved](http://blog.ivank.net/interpolation-with-cubic-splines.html).  In all cases, we want look-up of the interpolated functions to be fast - using bisection searches and starting searches near the last point that was used.

The original version of the code that became `cinterpolate` of this was [bundled into odin](https://github.com/mrc-ide/odin/tree/6bee9749325c3ff297f30b43cb31811fdf44c5ae/inst) but this quickly became a pain to test so it was broken out into its own package.

To get started with `cinterpolate`, see the [the vignette](https://mrc-ide.github.io/cinterpolate/articles/cinterpolate.html), which explains how to configure your `DESCRIPTION` and how to use the functions.  The C API includes only 3 functions (allocation, evaluation and cleanup).
