---
author: "Rich FitzJohn"
date: 2019-04-09
title: odin 0.2.0
best: false
tags:
 - R
 - odin
---

After a rather long period of gestation, yesterday I merged in a [long-running rewrite of odin](https://github.com/mrc-ide/odin/pull/156).  This is a major rework of odin which lays the groundwork for future improvements later this year.

[Odin](https://mrc-ide.github.io/odin) is our package for working with differential equations at a high level - it includes support for the sort of "structured [compartmental models](https://en.wikipedia.org/wiki/Compartmental_models_in_epidemiology)" that we use a lot in the department, compiling these to C for efficient execution.  Over the last few years of development the code had become increasingly complicated and difficult to extend as new features had been added on top of previous features.

At the [epirecipes](https://www.turing.ac.uk/events/epirecipes) event last year an attendee asked me "what does odin use as an [intermediate representation](https://en.wikipedia.org/wiki/Intermediate_representation)?" and I had no answer because it just compiled R directly to C which meant there was no real point where validation stopped and compilation began.  This turned out to be the insight I needed.

I rewrote odin entirely to compile first to an intermediate representation that captured the nature of the system and by which point all validation had happened.  Unlike general purpose intermediate representations, this one is written in [json](https://en.wikipedia.org/wiki/JSON) - you can see its schema [here](https://github.com/mrc-ide/odin/blob/master/inst/schema.json).  It's not designed to be terrifically concise either.

```
deriv(N) <- r * N * (1 - N / K)
initial(N) <- N0
N0 <- 1
K <- 100
r <- 0.5
```

which generates [this big pile of json](https://gist.github.com/richfitz/f3f618c45c8f5c0a52a7441ec15595b4#file-logistic-json).  But at this point we never have to check again if the equations "make sense" and we can just compile out the target code in a much more robotic fashion.

Doing this has enabled creation of an R backend (compiling R to R), which should make getting started with odin a lot easier, and we've got started with a JavaScript target ([`odin.js`](https://github.com/mrc-ide/odin.js)), which may get rolled into the main package, which would allow the creation of fully client-side models - see an [example of a simple SIR model here](https://mrc-ide.github.io/odin.js/simple/).

This release also fixes a number of long standing nuisances (see the [`NEWS.md`](https://github.com/mrc-ide/odin/blob/master/NEWS.md#odin-020) for details), but from the point of view of end users should seem almost unchanged.

Install odin with

```
# install.packages("drat") # if needed
drat:::add("mrc-ide")
install.packages("odin")
```

and get started with [the tutorial](https://mrc-ide.github.io/odin/articles/odin.html).
