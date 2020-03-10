---
title: "cyphr 1.1.0"
date: 2020-03-10
author: Rich
tags:
 - R
 - reproducible research
---

We have released a new version of our [cyphr](https://docs.ropensci.org/cyphr/) package, which makes data analysis workflows with R much easier.  The aim of the package is to make encrypted workflows as easy as

```r
d <- cyphr::decrypt(read.csv("secret-input.csv"), key)
...
cyphr::encrypt(write.csv(processed, "secret-output.csv"), key)
```

using [modern encryption technologies](https://github.com/jeroen/sodium) and taking care of most of the details so that data is not inadvertently leaked.

This new version has lots of small features which improve the behaviour of its [collaborative data process](https://docs.ropensci.org/cyphr/articles/data.html)

* The project directory is found automatically - this turned out to be important for working nicely with [orderly](https://vimc.github.io/orderly/)
* We added lots of guidance and improved error messages, so that when things go wrong, or when action is needed, this is more obvious to users
* SHA256 is used for the key fingerprint, not MD5 (which is the default in the openssl package), and the internal directory structure is versioned - this should add a great deal more backward compatibility
* The data key is cached within a session, making it easier for people to use password-protected ssh keys.
* Automatic handlers were added for reading and writing excel files with the [readxl](https://readxl.tidyverse.org/) and [writexl](https://docs.ropensci.org/writexl/) packages

These are all fairly small, but together we think make the package more accessible.  These features were driven by the use of the package as part of the [MRC Centre for Global Infectious Disease Analysis](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis) response to COVID-19.
