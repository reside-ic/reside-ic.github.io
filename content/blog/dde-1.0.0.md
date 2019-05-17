---
author: "Rich FitzJohn"
date: 2019-05-20
title: dde 1.0.0
best: false
---

Last week we released the first official version of [`dde`](https://mrc-ide.github.io/dde/), which is now [available on CRAN](https://cran.r-project.org/package=dde).  This package implements a method for solving [delay differential equations](https://en.wikipedia.org/wiki/Delay_differential_equation), which we use with [`odin`](https://mrc-ide.github.io/odin) to model disease dynamics.

With ordinary differential equations, you express the system of equations as *dy/dt = f(y(t), t)*; the rate of change of the system depends on the current state of the system and the current time, but with delay differential equations *dy/dt* also depends on *y(t - tau)*.  In general these are hard to solve numerically but there is a large class of useful equations with constant delays that are both interesting and tractable.

Integrating delay differential equations allows researchers in our department to model relationships where (say) the number of mosquitos entering a lifecycle phase now depends on the number of people who were bitten several days ago.

`dde` implements the method of [Hairer, Norsett and Wanner (1993)](http://www.unige.ch/~hairer/software.html) where we use an ODE solver that can accurately interpolate to points within steps that it takes along with a [ring buffer](https://github.com/richfitz/ring) to store the history.  It only works with non-stiff systems but we have found it to work well on large systems of equations where the DDE support in [`deSolve`](https://cran.r-project.org/package=deSolve) (implemented using `lsoda`) stopped working.

`dde` is now available from CRAN and can be installed with

```
install.packages("dde")
```

To get started see [the package vignette](https://mrc-ide.github.io/dde/articles/dde.html).
