---
author: "Emma Russell"
date: 2026-06-04
title: "RESIDE update: June 2026"
tags:
 - update
---

It's been a while since we posted an update - we are still here, we are just (very) infrequent bloggers! Here's a quick run down of some of the things we've been working on recently.

- a brand new GPU cluster for DIDE
- a new version of [MINT](https://mint.dide.ic.ac.uk/) (Malaria INdicators Tool) backed by neural network-based emulator models, with a new interface for modelling future scenarios. ([github link](https://github.com/mrc-ide/mint-v2))
- [Vaxviz](https://vaxviz.vaccineimpact.org/) - a new visualisation tool to accompany latest paper from the Vaccine Impact Modelling Consortium. ([github link](https://github.com/vimc/vaxviz))
- [Vimcheck](https://github.com/vimc/vimcheck) - also for VIMC, an R package for running diagnostic checks on disease burden estimates and on vaccine impact estimates.
- Daedalus - a [model package](https://github.com/jameel-institute/Daedalus) and associated [web application](https://daedalus.jameel-institute.org) ([github link](https://github.com/jameel-institute/daedalus-web-app)) for projecting and optimising the health, social and economic costs of a pandemic.
- Daedalus ecosystem - a set of packages that relate to Daedalus; [daedalus.data](https://github.com/jameel-institute/daedalus.data) holds data used by Daedalus, [daedalus.compare](https://github.com/jameel-institute/daedalus.compare) allows running multiple [daedalus.api](https://github.com/jameel-institute/daedalus.api) connects the R/C++ model to the Daedalus Explore web application, [Daedalus.jl](https://github.com/jameel-institute/Daedalus.jl) is an emerging port of Daedalus to Julia.
- EpiEconShocks.jl - a [Julia package](https://github.com/jameel-institute/EpiEconShocks.jl) for calculating the labour productivity and consumption losses due to a pandemic, and a way to model the impacts of these losses on the global economy using the [Global Trade Analysis Project model](https://www.gtap.agecon.purdue.edu/default.asp).
- [Skadi (aka Static Wodin)](https://github.com/mrc-ide/wodin/blob/main/config-static/README.md) - this project provides a framework of web components for running, and parameterising [odin](https://github.com/mrc-ide/odin) models. It uses components developed initially for our Wodin teaching platform, but allows them to be flexibly composed and included in arbitrary web pages, allowing for a greater range of options in presenting these models interactively while providing narrative context as required. 
- [Skadi chart](https://github.com/mrc-ide/skadi-chart) - to support Skadi, we've also been developing our own charting library to replace plotly. This is a structured thin wrapper around [d3](https://d3js.org/) which provides us with the flexibility required to develop the visualisations we want. 
- [chronofix](https://github.com/mrc-ide/chronofix) - a package for cleaning and correcting datasets which include manually entered dates
- [PiranhaNET](https://github.com/polio-nanopore/piranhaNET) (WIP) - a new GUI for the [Piranha](https://github.com/polio-nanopore/piranha) package analysing sequences for detection of poliovirus. This will be provided as a desktop electron application and an online web application.  


