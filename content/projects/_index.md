+++
date = "2021-03-09"
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

### UNAIDS

With [the HIV inference group](https://hiv-inference.org/) and [UNAIDS](https://unaids.org), we have developed a modern web interface for a model estimating various HIV epidemic indicators, see the [project page](naomi) for more information.

We have also developed a simpler shiny web interface, [shiny90](https://shiny90.unaids.org/), for a model that estimates the proportion of people living with HIV who are aware of their status given national or regional data. For use by countries to estimate how close they are to the [UNAIDS 90-90-90 target](https://www.unaids.org/en/resources/909090)

* [Paper describing the model](https://www.biorxiv.org/content/10.1101/532010v1)

### Custom data collection app

We developed a custom data collection Android app for use in a health economics field survey. The need for a custom app
 came from innovative survey questions that could not easily be represented in a conventional form or existing app - 
 they seek to capture a spread of belief allocation across an exhaustive answer space.
The code for this is not open due to the confidential nature of the survey.

### Outbreak response

We provide technical and software support to outbreaks as part of the [MRC Centre for Global Infectious Analysis](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis), most notably during the 2018-2020 Ebola outbreak in the Democratic Republic of Congo.

We are currently heavily involved in the [ongoing 2019-nCoV-SARS/COVID-19 pandemic](covid), both in the UK and for other countries.

This work involves a number of packages from the list below, notably [orderly and OrderlyWeb](#orderly-lightweight-reproducible-reporting), [cyphr](https://ropensci.github.io/cyphr/), and [odin](https://mrc-ide.github.io/odin), as well as working directly with scientists to keep them able to focus on their science through training, advice, HPC support and dealing with particularly nasty datasets.

## Public Engagement Tools

We have a collection of tools for use in science festivals, public engagement events and internal socials, where we explore epidemiological ideas with games and hands-on experiments.

* [Barcode epidemic](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Barcode_Epidemic) - where an epidemic is spread by passing unqiue QR codes.
* [Microbit epidemic](https://www.github.com/mrc-ide/public-events-microbit-epidemic) - where an epidemic is transmitted over Microbit radio
* Zombie Spatial Simulator [original](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Zombie_Sim_I) and [simplified](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Zombie_Sim_II) - visualisation of an individual-based spatial epidemic.
* [Herd Immunity](https://mrcdata.dide.ic.ac.uk/wiki/index.php/Herd_Immunity) - explore vaccination efects in an epidemic simulated by bouncing balls off each other.

## Support for DIDE HPC Clusters

The department has its own high-performance computing clusters running Microsoft
HPC. Jobs can be launched and managed through Microsoft's own GUIs and command-line 
tools, but in a department where R is the most widely used language, the 
[didehpc](https://mrc-ide.github.io/didehpc/) package provides an interactive
experience from within an R session. 

It uses the [context](https://mrc-ide.github.io/context)
package to link packages, source code and local environment for running the jobs, and
the [queuer](https://mrc-ide.github.io/queuer) package for launching and running jobs.

Package management for the repositry the cluster uses is handled by 
[conan](https://mrc-ide.github.io/conan) the librarian.

## Standalone software packages

* A large and continually growing collection of [R packages](r-packages), on their own page.

* [constellation](https://github.com/reside-ic/constellation) - simple deployment configuration for a constallation of docker containers (written in Python)
* [dopri.js](https://github.com/mrc-ide/dopri-js) - simple ODE solver in JavaScript
