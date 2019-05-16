+++
date = "2019-05-16"
title = "Projects"
+++

An incomplete list of some projects that we have worked on within our RSE group.

## Collaborative work with research groups

### The Vaccine Impact Modelling Consortium

The [Vaccine Impact Modelling Consortium](https://www.vaccineimpact.org/) coordinates the work of several research groups modelling the impact of vaccination programmes worldwide.  We provide the technical infrastructure for this project, including

* a web-based system for collecting, verifying and storing many gigabytes of modelling results
* a reproducible-research system for the project scientists to work with this data
* interactive data visualisation
* a web-based system for disseminating results

## Reusable components

### `cinterpolate` - interpolation from C, for R

A small utility R package for interpolation (piecewise constant, linear and spline) from C for use within R packages

* [Package webpage](https://mrc-ide.github.io/cinterpolate)
* [CRAN page](https://cran.r-project.org/package=cinterpolate)
* Blog posts: [announcement](/blog/cinterpolate-1.0.0/)

### `cyphr` - easy to use encryption for R

A high-level approach to make using encryption from R more accessible; the `cyphr` package wraps the [`openssl`](https://cran.r-project.org/package=openssl) and [`sodium`](https://cran.r-project.org/package=sodium) packages to provide a common interface, along with abstractions to make encryption easier for data analysts.

* [Package webpage](https://ropensci.github.io/cyphr/)
* [CRAN page](https://cran.r-project.org/package=cyphr)

(This is also an [rOpenSci](https://ropensci.org/) package.)

### `dde` - an R package for solving delay differential equations

The `dde` package solves delay differential equations (DDEs), which are an extension to ordinary differential equations (ODEs) where the derivatives depend not only on the current state but also on the state at some point in the model's past.  They turn up modelling contexts (e.g., the number of people bitten by mosquitos 10 days ago).

* [Package webpage](https://mrc-ide.github.io/dde)
* [CRAN page](https://cran.r-project.org/package=dde)
* Blog posts: [debugging](/blog/debugging-at-the-edge-of-reason/)

### `odin` - high level differential equations

A "domain specific language", hosted in R, for representing and compiling ordinary differential equations.  `odin` provides a language that has the same syntax as R but compiles to C (or to R or JavaScript) in order to represent equations at a high level but allow high-performance solutions.  Currently `odin` is being used within the department for research on malaria, measles, HIV and flu.

* [Package webpage](https://mrc-ide.github.io/odin)
* Blog posts: [0.2.0](/blog/odin-0.2.0/)

### `vaultr` - an R client for Vault

The R package [`vaultr`](https://vimc.github.io/vaultr) is a client for [HashiCorp's "vault"](https://vaultproject.io), a system for storing secrets and sensitive data and enabling these secrets to be used in applications.

* [Package webpage](https://vimc.github.io/vaultr)
* [CRAN page](https://cran.r-project.org/package=vaultr)
* Blog posts: [announcement](/blog/vaultr-1.0.2/)

## Public Engagement Tools

We have a collection of tools for use in science festivals, public engagement events and internal socials, where we explore epidemiological ideas with games and hands-on experiments.

* [Barcode epidemic](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Barcode_Epidemic) - where an epidemic is spread by passing unqiue QR codes.
* [Microbit epidemic](https://www.github.com/mrc-ide/public-events-barcode-epidemic) - where an epidemic is transmitted over Microbit radio
* Zombie Spatial Simulator [original](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Zombie_Sim_I) and [simplified](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Zombie_Sim_II) - visualisationg an individual-based spatial epidemic.
* [Herd Immunity](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Herd_Immunity) - explore vaccination efects in an epidemic simulated by bouncing balls off each other.
