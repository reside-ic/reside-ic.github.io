+++
date = "2020-02-03"
title = "Naomi"
+++

[https://naomi.unaids.org](https://naomi.unaids.org/)

A web interface for a model estimating various HIV epidemic indicators at a regional level. The application is used by teams of health officials from sub-Saharan African countries to inform HIV programme targets. The tool was rolled out during a series of UNAIDS-led workshops in Johannesburg and Abidjan from December 2019 - January 2020. The model produces district-level estimates of people living with HIV, coverage of and unmet need for antiretroviral treatment, and new HIV infections. Estimates are used to develop official HIV programme targets and budget allocations for the US Government PEPFAR programme planning, Global Fund grant applications, and other national HIV programme planning needs.

The app is comprised of:

* [HIV model](https://github.com/mrc-ide/naomi)
* [wrapped by an R API](https://github.com/mrc-ide/hintr)
* [a Kotlin web server](https://github.com/mrc-ide/hint)
* [a Vue.js front-end](https://github.com/mrc-ide/hint/tree/master/src/app/static)
* Supported by
   * [a Postgres database for the Kotlin web server](https://github.com/mrc-ide/hint-db)
   * [R i18n infrastructure](https://github.com/reside-ic/traduire)
   * [load balancing long-running jobs via a Redis queue](https://github.com/mrc-ide/rrq)
   * [deployment tool](https://github.com/mrc-ide/hint-deploy)
   * [built using constellation](https://github.com/reside-ic/constellation)

This is the first example in our experiments for wrapping research code and deploying it to the web using modern testable technologies.

Presented as a <a href="/resources/RSLondonSE-hint-poster.pdf" target="_blank">poster</a> at [RSLondonSouthEast](https://rslondon.ac.uk/) on 6th February.
