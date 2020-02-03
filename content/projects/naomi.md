+++
date = "2020-02-03"
title = "Naomi"
+++

[https://naomi.unaids.org](https://naomi.unaids.org/)

A web interface for a model estimating various HIV epidemic indicators at a regional level. For use by 
countries in association with UNAIDS. The app is comprised of:

* [an R API and R workers](https://github.com/mrc-ide/hintr), managed by a [Redis queue](https://github.com/mrc-ide/rrq)
* [a Kotlin web server](https://github.com/mrc-ide/hint)
* [a Vue.js front-end](https://github.com/mrc-ide/hint/tree/master/src/app/static)
* [HIV model](https://github.com/mrc-ide/naomi)

Presented at a poster [RSLondonSouthEast](https://rslondon.ac.uk/) on 6th February

<img src="/img/RSLondonSE-hint-poster.png" alt="hint poster"/>