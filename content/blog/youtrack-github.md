---
author: "Alex Hill"
date: 2019-04-17
title: Integrating YouTrack and GitHub workflows
best: false
---

Like most technical teams we use an issue tracker to manage our work. Our tool of choice for
this is [YouTrack](https://www.jetbrains.com/youtrack/). We also make extensive use of GitHub and to synchronise our 
workflow across the two platforms we name our git branches with YouTrack ticket ids, so every pull request 
corresponds to a ticket. This naming convention makes it easier to track work in progress across the two platforms, 
plus our deploy tool can use git to look at which branches have been merged in and then auto-update the 
corresponding YouTrack tickets once the code is deployed. 

An issue moves through 5 states before deployment:

1. issue created
1. issue in progress
1. review requested
1. review submitted
1. issue ready for deploy
 
In the web development team we use an Agile board in YouTrack to track an issue through these states and to know whether 
an issue is waiting for us to review it, or changes to our code have been requested; others who are not using an Agile
 board prefer to monitor GitHub. Given the diversity of our team some divergence of workflows is inevitable, so rather 
 than trying to force everyone into the same habits I wrote a [webhook](https://developer.github.com/webhooks/) to 
 automatically keep tickets and branches in sync.

This is a small Flask app that accepts payloads from GitHub whenever a pull request related action is taken and uses the 
[YouTrack API](https://www.jetbrains.com/help/youtrack/standalone/General-REST-API.html) to update the relevant ticket. 
A small config file maps GitHub users to YouTrack users, so that when a code review is requested on GitHub, the YouTrack
ticket gets assigned to the relevant person. Similarly when code changes are requested the 
ticket gets assigned back to the author.

Code and a full README for the webhook can be found at: https://github.com/vimc/youtrack-integration
