+++
date = "2022-03-03"
title = "R packages"
+++

The most commonly used language in the department is R, and so we have written many R packages to support research.

## `cinterpolate` - interpolation from C, for R

A small utility R package for interpolation (piecewise constant, linear and spline) from C for use within R packages

* [Package webpage](https://mrc-ide.github.io/cinterpolate)
* [CRAN page](https://cran.r-project.org/package=cinterpolate)
* Blog posts: [announcement](/blog/cinterpolate-1.0.0/)

## `cyphr` - easy to use encryption for R

A high-level approach to make using encryption from R more accessible; the `cyphr` package wraps the [`openssl`](https://cran.r-project.org/package=openssl) and [`sodium`](https://cran.r-project.org/package=sodium) packages to provide a common interface, along with abstractions to make encryption easier for data analysts.

* [Package webpage](https://ropensci.github.io/cyphr/)
* [CRAN page](https://cran.r-project.org/package=cyphr)
* Blog posts: [1.1.0](/blog/cyphr-1.1.0/)

(This is also an [rOpenSci](https://ropensci.org/) package.)

## `dde` - an R package for solving delay differential equations

The `dde` package implements a simple solver for delay differential equations (DDEs), which are an extension to ordinary differential equations (ODEs) where the derivatives depend not only on the current state but also on the state at some point in the model's past.  They turn up modelling contexts (e.g., the number of people bitten by mosquitos 10 days ago).

* [Package webpage](https://mrc-ide.github.io/dde)
* [CRAN page](https://cran.r-project.org/package=dde)
* Blog posts: [announcement](/blog/dde-1.0.0/), [debugging](/blog/debugging-at-the-edge-of-reason/)

## `dettl` - ETL (Extract-Transform-Load) support

We wrote this package to support our work with the [Vaccine Impact Modelling Consortium](https://www.vaccineimpact.org/), to allow reviewable and testable data uploads into our databases.

* [Package webpage](https://www.vaccineimpact.org/dettl/)

## `ids` - simple random identifiers

Random idenfiers in a number of different forms, including random hex strings (e.g., `8fa9afdd5bc04b3732fd07ddde865f48`) to human-readable/semi-memorable phrases (`bombastic_anteater` or `3_bashful_rabbits_spying_obnoxiously`). We use this package anywhere we need random keys.

* [Package webpage](https://reside-ic.github.io/ids/)
* [CRAN page](https://cran.r-project.org/package=ids)

## `fakerbase` - fake database tables for unit testing

Lightweight fake tables that automatically conform to a database schema, used to replace databases in tests.  Currently used in [vimpact](https://github.com/vimc/vimpact/) to replace a complex Postgres database.

* [Package website](https://reside-ic.github.io/fakerbase/)

## `jsonvalidate` - JSON schema validation for R

[JSON schemas](https://json-schema.org/) provide a mechanism for validating that JSON conforms to an expected structure.  This R package wraps two popular JSON schema libraries written in javascript - [`is-my-json-valid`](https://github.com/mafintosh/is-my-json-valid) and [`ajv`](https://github.com/epoberezkin/ajv).

* [Package webpage](https://docs.ropensci.org/jsonvalidate)
* Blog posts [1.1.0](/blog/jsonvalidate-1.1.0)
* [CRAN page](https://cran.r-project.org/package=jsonvalidate)

(This is also an [rOpenSci](https://ropensci.org/) package.)

## `odin` - high level differential equations

A "domain specific language", hosted in R, for representing and compiling ordinary differential equations.  `odin` provides a language that has the same syntax as R but compiles to C (or to R or JavaScript) in order to represent equations at a high level but allow high-performance solutions.  Currently `odin` is being used within the department for research on malaria, measles, HIV and flu.

* [Package webpage](https://mrc-ide.github.io/odin)
* Blog posts: [0.2.0](/blog/odin-0.2.0/)
* [CRAN page](https://cran.r-project.org/package=odin)
* [UseR! talk](https://www.youtube.com/watch?v=R0GHyFd3k8Q)

## `orderly` - lightweight reproducible reporting

A lightweight system for reproduducible reporting, in R. Composed of [an R package, `orderly`](https://github.com/vimc/orderly) and [a web application, OrderlyWeb](https://github.com/vimc/OrderlyWeb), `orderly` makes it straightforward to associate analyses with their inputs, version outputs and organise and distribute everything with a user-friendly front-end. The researcher-friendly framework makes very few restrictions on how analyses are carried out.

* [Package webpage](https://vimc.github.io/orderly)
* [CRAN page](https://cran.r-project.org/package=orderly)
* [Web application](https://github.com/vimc/OrderlyWeb)
* Blog posts: [1.0.1](/blog/orderly-1.0.1-released-to-cran/)

## `porcelain` - testable HTTP API packages

An opinionated way of structuring [plumber](https://www.rplumber.io/) APIs (simple HTTP APIs written in R, similar to [flask](https://flask.palletsprojects.com/en/2.0.x/) in Python).  On top of the system provided by plumber, `porcelain` adds validation of json requests and responses (using [jsonvalidate](https://docs.ropensci.org/jsonvalidate/)), easier unit and integration testing, and integration with [roxygen2](https://roxygen2.r-lib.org/).

* [Package webpage](https://reside-ic.github.io/porcelain/)

## `traduire` - internationalisation for R packages

The traduire R package provides a wrapper around the [i18next](https://www.i18next.com/) JavaScript library. It presents an alternative interface to R’s built-in internationalisation functions, with a focus on the ability to change the target language within a session.  We use this to support dynamic translation of [`hintr`](https://github.com/mrc-ide/hintr/) which is a [`porcelain`](https://reside-ic.github.io/porcelain/) API to [naomi](https://naomi.unaids.org/) - see [the naomi project page](naomi.md) for more information.

* [Package webpage](https://reside-ic.github.io/traduire/)

## `spud` - sharepoint upload and download

Simple interface to Sharepoint allowing uploading and downloading of files.  Much less fully featured than [Microsoft365R](https://cran.r-project.org/package=Microsoft365R) but does not require that the site administrators have enabled exotic API endpoints.

* [Package webpage](https://reside-ic.github.io/spud/)

## `vaultr` - an R client for Vault

The R package [`vaultr`](https://vimc.github.io/vaultr) is a client for [HashiCorp's "vault"](https://vaultproject.io), a system for storing secrets and sensitive data and enabling these secrets to be used in applications.

* [Package webpage](https://vimc.github.io/vaultr)
* [CRAN page](https://cran.r-project.org/package=vaultr)
* Blog posts: [announcement](/blog/vaultr-1.0.2/)


---

dust
mcstate
rrq
odin.dust
odin.js (archive now)
conan
kelp
ring
indivdual
didehpc & friends
eigen1
syncr

specio
beers

viralload (from dust)
