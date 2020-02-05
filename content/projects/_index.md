+++
date = "2019-05-16"
title = "Projects"
+++

An incomplete list of some projects that we have worked on within our RSE group.

## Collaborative work with research groups

### The Vaccine Impact Modelling Consortium

The [Vaccine Impact Modelling Consortium](https://www.vaccineimpact.org/) coordinates the work of several research groups modelling the impact of vaccination programmes worldwide.  We provide the technical infrastructure for this project, including

* a web-based system for collecting, verifying and storing many gigabytes of modelling results
* a reproducible-research system, [orderly](#orderly-lightweight-reproducible-reporting) for the project scientists to work with this data
* interactive data visualisation
* a web-based system for disseminating results

### Shiny90
[https://shiny90.unaids.org](https://shiny90.unaids.org/)

An R Shiny web interface for a model that estimates the proportion of people living 
with HIV who are aware of their status given national or regional data. For use by countries to estimate
how close they are to the [UNAIDS 90-90-90 target](https://www.unaids.org/en/resources/909090)

* [Paper describing the model](https://www.biorxiv.org/content/10.1101/532010v1)

### Naomi

A web interface for a model estimating various HIV epidemic indicators, see the [project page](naomi) for more information.

### Custom data collection app

We developed a custom data collection Android app for use in a health economics field survey. The need for a custom app
 came from innovative survey questions that could not easily be represented in a conventional form or existing app - 
 they seek to capture a spread of belief allocation across an exhaustive answer space.
The code for this is not open due to the confidential nature of the survey.

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
* Blog posts: [announcement](/blog/dde-1.0.0/), [debugging](/blog/debugging-at-the-edge-of-reason/)

### `jsonvalidate` - JSON schema validation for R

[JSON schemas](https://json-schema.org/) provide a mechanism for validating that JSON conforms to an expected structure.  This R package wraps two popular JSON schema libraries written in javascript - [`is-my-json-valid`](https://github.com/mafintosh/is-my-json-valid) and [`ajv`](https://github.com/epoberezkin/ajv).

* [Package webpage](https://docs.ropensci.org/jsonvalidate)
* Blog posts [1.1.0](/blog/jsonvalidate-1.1.0)
* [CRAN page](https://cran.r-project.org/package=jsonvalidate)

(This is also an [rOpenSci](https://ropensci.org/) package.)

### `odin` - high level differential equations

A "domain specific language", hosted in R, for representing and compiling ordinary differential equations.  `odin` provides a language that has the same syntax as R but compiles to C (or to R or JavaScript) in order to represent equations at a high level but allow high-performance solutions.  Currently `odin` is being used within the department for research on malaria, measles, HIV and flu.

* [Package webpage](https://mrc-ide.github.io/odin)
* Blog posts: [0.2.0](/blog/odin-0.2.0/)
* [CRAN page](https://cran.r-project.org/package=odin)
* [UseR! talk](https://www.youtube.com/watch?v=R0GHyFd3k8Q)

### `orderly` - lightweight reproducible reporting

A lightweight system for reproduducible reporting, in R. Composed of [an R package, `orderly`](https://github.com/vimc/orderly) and [a web application, OrderlyWeb](https://github.com/vimc/OrderlyWeb), `orderly` makes it straightforward to associate analyses with their inputs, version outputs and organise and distribute everything with a user-friendly front-end. The researcher-friendly framework makes very few restrictions on how analyses are carried out.

* [Package webpage](https://vimc.github.io/orderly)
* [CRAN page](https://cran.r-project.org/package=orderly)
* [Web application](https://github.com/vimc/OrderlyWeb)
* Blog posts: [1.0.1](/blog/orderly-1.0.1-released-to-cran/)

### `vaultr` - an R client for Vault

The R package [`vaultr`](https://vimc.github.io/vaultr) is a client for [HashiCorp's "vault"](https://vaultproject.io), a system for storing secrets and sensitive data and enabling these secrets to be used in applications.

* [Package webpage](https://vimc.github.io/vaultr)
* [CRAN page](https://cran.r-project.org/package=vaultr)
* Blog posts: [announcement](/blog/vaultr-1.0.2/)

## Public Engagement Tools

We have a collection of tools for use in science festivals, public engagement events and internal socials, where we explore epidemiological ideas with games and hands-on experiments.

* [Barcode epidemic](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Barcode_Epidemic) - where an epidemic is spread by passing unqiue QR codes.
* [Microbit epidemic](https://www.github.com/mrc-ide/public-events-microbit-epidemic) - where an epidemic is transmitted over Microbit radio
* Zombie Spatial Simulator [original](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Zombie_Sim_I) and [simplified](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Zombie_Sim_II) - visualisation of an individual-based spatial epidemic.
* [Herd Immunity](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Herd_Immunity) - explore vaccination efects in an epidemic simulated by bouncing balls off each other.
