+++
date = "2020-06-01"
title = "2019-nCoV-SARS/COVID-19 pandemic response"
+++

Our team is providing technical and software support to the [ongoing 2019-nCoV-SARS/COVID-19 pandemic](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis/covid-19/). Much of this builds on tools that we have developed over the previous 5 years, with some ongoing development of these tools to track the research needs:

* [orderly](https://vimc.github.io/orderly) and [OrderlyWeb](https://github.com/vimc/orderly-web), our reproducible reporting framework developed for the [Vaccine Impact Modelling Consortium](https://www.vaccineimpact.org/), is being used to coordinate research results amongst our (now distributed) team of researchers in a reproducible and traceable way. During the response we have developed extensions such as [sharepoint support](https://github.com/vimc/orderly.sharepoint) and an [Rstudio addin](https://github.com/vimc/orderly.rstudio), as well as a [lot of new features](https://github.com/vimc/orderly/blob/master/NEWS.md)
* [odin](https://mrc-ide.github.io/odin) is being used to implement both stochastic and deterministic compartmental models, and we have developed [odin.js](https://mrc-ide.github.io/odin.js) which can compile odin models to JavaScript during the pandemic to deploy models to the web. For stochastic models we have started developing a new simulation engine ([dust](https://mrc-ide.github.io/dust)) and tools for inference ([mcstate](https://mrc-ide.github.io/mcstate))
* [cyphr](https://ropensci.github.io/cyphr/) is being used to encrypt data at rest

We are working directly with researchers as they develop models and analyses, supporting

* [CovidSim](https://github.com/mrc-ide/covid-sim/) (an individual-based simulation requiring significant HPC capacity to run)
* [sircovid](https://github.com/mrc-ide/sircovid) an odin model for the epidemic through the UK hospital system, fit using particle filter MCMC
* [squire](https://github.com/mrc-ide/squire) an odin model with both a stochastic version used to fit to data ([with nightly reports fitting to 110 countries](https://mrc-ide.github.io/global-lmic-reports/)) and a deterministic version that is [available on the web](https://www.covidsim.org) (the web app was created by [Bio Nano consulting](http://www.bio-nano-consulting.com/), and the embedded model runs purely client side, compiled with odin.js). Featured on [Our World in Data](https://ourworldindata.org/covid-models#imperial-college-london-icl)
* Tooling and strategies for processing multiple daily streams of incoming unstandardised data.
