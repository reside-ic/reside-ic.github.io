---
author: Mark Woodbridge
date: 2021-03-30
title: Creating project templates using Cookiecutter
tags:
- Cookiecutter
---

# Introduction

We recently took the opportunity presented by some new projects to build a re-usable web application project template.
This post explains our objectives, the implementation, and some reflections on the process.

# Objectives

We develop and/or maintain a number of applications that provide web-based user interfaces to research data and
scientific models. They all include a Kotlin backend and are built using Gradle but differ in other implementation
details:

- Some use a database, whereas others don't need to persist or access data directly
- The most recent use TypeScript - older ones use vanilla Javascript
- We mostly use Vue 2, but we have a couple using React
- We use several server-side HTTP frameworks, reflecting their maturity (and that of Kotlin) when the relevant apps were
  developed
- We have standardised on Spring Boot for new apps, but we have also used Spark in the past

There are other differences, but this should demonstrate the kind of divergence that we're aiming to address, primarily
based on our learnings about each technology or framework since adopting them. We're also keen to make it easier to
bootstrap new projects without having to deconstruct existing apps and their (necessary!) idiosyncrasies.

Our aim therefore is to standardise on the following stack for future apps:

- Latest stable versions of Kotlin, Spring Boot and Gradle (using the Kotlin rather than Groovy DSL)
- Vue 3 with TypeScript, scaffolded using [Vue CLI](https://cli.vuejs.org/)
- Code coverage and automated linting for Kotlin and TypeScript
- Structured (JSON-based) logging, to leverage
  our [recent ELK deployment](https://reside-ic.github.io/blog/aggregating-logs-from-services-deployed-with-docker/)
- Buildkite for on-premise CI and Docker images for deployment

In reality each app will diverge beyond this foundation - particularly if data storage is required - but a common
substrate should make context-switching between projects much easier.

# Implementation

We have used [Cookiecutter](https://github.com/cookiecutter/cookiecutter) for templating our project. It's a very
accessible tool that effectively performs a search-and-replace across a directory structure, replacing variables such as
project name with your desired values. It's written in (pure) Python but can template any kind of project.

Our resulting [web application template](https://github.com/reside-ic/cookiecutter-kotlin-typescript) has four
variables:

- Project name
- Kotlin/Java package prefix
- GitHub repository name
- Docker image name

A nice feature of Cookiecutter is that it can pull templates from GitHub so that the latest is always used. It can also
be used non-interactively, which we use in a QA process implemented using GitHub Actions: we populate the template with
some default values whenever it's updated and ensure that its build/lint/test scripts execute successfully. Given that
the template includes tests for both front-end and back-end code, this gives us some confidence that it is a suitable
basis for a working application, and that any updates to its dependencies aren't inherently problematic.

# Reflections

Building a template encouraged us to reflect on and debate the favoured (and unfavoured) parts of our current stack. As
a result we can be confident that we have a common foundation that we all understand, and that we consider capable
enough for a wide range of purposes, even if the resulting scaffold will always require extensive modification on a
case-by-case basis.

Cookiecutter has proven a useful and accessible tool, and well worth considering if you
outgrow [GitHub's template repository](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-template-repository)
feature i.e. if you need to modify files or the filesystem structure when “cloning” the template. We have since used
Cookiecutter to develop a [similar template for R packages](https://github.com/reside-ic/cookiecutter-r-package), where
the benefits may be even more significant given these are created more frequently in our group than new web
applications. [Many more templates](https://github.com/topics/cookiecutter) can be found on GitHub... so happy
Cookiecutting!

# Acknowledgements

Many thanks to all the [Cookiecutter contributors](https://github.com/cookiecutter/cookiecutter/blob/master/AUTHORS.md),
and [@seik](https://github.com/seik/cookiecutter-kotlin)
and [@thomaslee](https://github.com/thomaslee/cookiecutter-kotlin-gradle) for providing some inspiration for our
Kotlin/TypeScript template.
