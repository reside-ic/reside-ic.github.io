---
author: "Rich FitzJohn"
date: 2019-10-18
title: orderly 1.0.1 released to CRAN
---

We are pleased to announce the first public release of [`orderly`](https://vimc.github.io/orderly), our reproducible reporting framework, implemented as an R package and now available on CRAN.

The `orderly` package was designed to help with a common pattern in reporting where a report might be run multiple times (over say a number of weeks or months) and where the inputs to the report might change.  In our case at [VIMC](https://www.vaccineimpact.org) this is analysis of impact of vaccines, but this pattern exists in many fields.  When reports are run multiple times they will inevitably vary, but we want to understand **why** they vary - was it a change in the analysis code, in the input data, or in some other dependency of the report?  Critically, we want it to always be completely clear that a given set of inputs belongs to a given set of outputs, without relying on any discipline from the end-user.

The principle idea in `orderly` is that if the user lists the required inputs and expected outputs of an analysis, then we can automate many tasks.  The user must write a small configuration file[^1] like

```yaml
script: script.R

resources:
  - data.csv

artefacts:
  - staticgraph:
      description: A graph of things
      filenames: mygraph.png
```

indicating the script to be run, any additional files needed to run the script, and the files that will be produced by running the script.  After that, orderly imposes no strong restrictions on what goes into `script.R`.  As such it is designed to accept R analyses that might have started life as standalone analyses as much as ones that were developed specifically for use within `orderly`.

The basic idea is described in more detail [on the `orderly` web page](https://vimc.github.io/orderly/) and in the [introductory vignette](https://vimc.github.io/orderly/articles/orderly.html).

We have borrowed ideas from version control of source files to create a system where multiple versions of analyses can be compared side-by-side and where outputs of an analysis are always stored alongside their inputs.  We have used `orderly` in two large collaborative projects since 2017 and continue to actively improve the package.

Core features include:

* ability to use data from SQL databases from reports
* manage reports that depend on previously run reports (perhaps multiple or specific versions)
* completely agnostic as to the sort of analyses that are run within a report, requiring no changes to most source code
* all inputs and outputs are automatically hashed and (along with information on all loaded R packages and the current session) stored alongside the outputs and in a [database](https://vimc.github.io/orderly/schema)
* a simple directory layout that is designed to minimise git conflicts and streamline collaboration
* a [web front-end](https://github.com/vimc/orderly-web), OrderlyWeb, which can be used to create a user-friendly interface to the system and support a centralised workflow (see [the "remote" vignette](https://vimc.github.io/orderly/articles/remote.html))

We take backward compatibility very seriously and have developed a system for safely migrating any changes to the internal formats used, including running these migrations against reference data during automated testing.

Install `orderly` from CRAN with

```
install.packages("orderly")
```

[^1]: Currently this file is in yaml format because that suits our workflows, but it would be straightforward to replace this with either a special R function or even generate the configuration automatically (and transparently) for stereotyped uses like compiling markdown files.
