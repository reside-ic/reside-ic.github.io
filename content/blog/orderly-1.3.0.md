---
author: "Rich FitzJohn"
title: "Orderly 1.3.0 released to CRAN"
date: 2021-06-21
draft: true
tags:
 - orderly
 - reproducible research
---

After 18 months of heavy use within [VIMC](https://www.vaccineimpact.org/) and in the [COVID-19 modelling response](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis/covid-19/covid-19-response-team-2020-2021-report/), we have released orderly 1.3.0 to CRAN. This is a major update with many new features (more than 100 PRs since version 1.0.4 was published in early 2020).

Orderly is our [reproducible research framework](https://www.vaccineimpact.org/orderly/articles/orderly.html), designed to keep track of multiple versions of reports and allow researchers to automatically audit and roll back their data, or construct workflows around long running tasks.

Since 2020 we have:

* Expanded the documentation, including [a discussion of different workflow patterns orderly enables](https://www.vaccineimpact.org/orderly/articles/patterns.html)
* Support for exporting work to be rerun elsewhere (e.g., a compute cluster) and then sent back to a central server via [bundles](https://www.vaccineimpact.org/orderly/articles/bundles.html)
* Massively improved the power of [OrderlyWeb](https://github.com/vimc/orderly-web/), which can be used as a central server to share artefacts among a team [see the remotes vignette](https://www.vaccineimpact.org/orderly/articles/remote.html).
* Expanded how dependencies work, to allow depending on the latest version of a particular parameter (e.g., `latest(parameter:n_samples >= 1000)`) rather than just the latest version
* Addded a new report development mode [`orderly_develop_start`, `orderly_develop_status` and `orderly_develop_clean`](https://www.vaccineimpact.org/orderly/reference/orderly_develop_start.html) which will setup an environment so reports can be developed in the same was as one might write code outside of orderly. It copies required files and dependencies, sources code files and loads declared packages. This supersedes `orderly_test_start` but that function is retained in the package for now.
* Allowed easier use of a mixture of draft and archive reports in development, via the `use_draft` argument to `orderly_run` (rather than `draft` in the `orderly.yml`
* Added tools to visualise the graph structure of source or archive reports with [`orderly_graph`](https://www.vaccineimpact.org/orderly/reference/orderly_graph.html)
* Added helper functions, inspired by [`usethis`](https://usethis.r-lib.org/): [`orderly_use_resource` `orderly_use_source` and `orderly_use_package`](https://www.vaccineimpact.org/orderly/reference/orderly_use.html) which can add a resource, source, or package into the `orderly.yml`
* Allowed environment variables and secrets to be used in reports

In addition, there are lots of bug fixes and little features as needed, such as better handling of metadata for failed reports, more flexible querying of reports, integration with Microsoft Teams, more flexibility with complex SQL database configurations, and better error messages.

Over the course of the pandemic we have used orderly to collect together more than a Terabyte of research outputs (mostly simulation data) among a distributed team. It has been key to many of our workflows over the last 18 months, and we hope that other groups can leverage this work.
