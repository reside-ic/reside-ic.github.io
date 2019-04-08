---
author: "Emma Russell"
date: 2019-04-08
title: Metrics at Imperial*
best: false
---

What metrics should a software team be recording to measure their performance? Should these metrics have a different 
focus for RSE teams in general, and ourselves in particular? 

In previous jobs in a more commercial setting, I had become accustomed to thinking about 'metrics' in two broad 
categories - firstly those defining the performance and health of online systems (number of requests served, click 
through rate, uptime etc), and secondly those measuring the productivity of the team in making additions and 
improvements to those systems (story point burndown, number of open bugs, feature leadtime). 

The first category could 
have immediate business consequences - e.g. affecting a client's decision on whether to renew a contract, or whether a 
contractual uptime obligation was being met. The second category reflects how effectively the team is able to meet 
ongoing business requirements, and can typically highlight broader issues in the business culture, team dynamics or 
technology - as any dev will know who has ever fire-fought heroically to keep a failing service running, only to be 
shamed at the end of the sprint by a flat burndown chart.

However, at our recent RESIDE away day, our session on metrics did not touch on the first category at all, and only 
partially on the second. Instead, the primary focus of our discussion was around the way our team interacts with others 
- the researchers we undertake work for and with, other project personnel, and the wider Imperial organisation. 

Our position at DIDE is not quite so red in tooth and claw as the typical tech startup, so the immediate need to keep on 
top of accurate production metrics is not so urgent. Of course we want to know if a system goes down, and have 
monitoring in place where we need it, but we won't have to make redundancies if we fail to achieve 99.9% uptime on our 
services. (Not yet anyway.) 

Measures of team productivity are more of an issue for us, not because we think we're unproductive, but because we felt 
that a fair chunk of our productivity is actually going unrecorded, and this feeds into a broader question of how we 
define ourselves and what we do as a team and how we fit into DIDE. 

Why record our metrics at all? Well, ultimately, we need to be able to justify our existence. How can we prove that our 
salaries couldn't be better spent on more researchers or better coffee machines? Put more altruistically, if we want to 
be as useful as we can to researchers and others, we had better be able to measure how useful we are now, and record the 
sort of information that will help us improve.  

## The What, Who, Why and Wow. 

After much discussion we focussed on four areas where we could do more. 

### Record Every Task *(or What are we doing?)*
We have tended to have a lot of heterogeneity in how we record what we're actually doing. While work on our major 
projects is quite carefully recorded (we use [YouTrack](https://www.jetbrains.com/youtrack/)) we also undertake a lot of 
smaller tasks or more informal work, falling into several areas including:

* Self-contained applications for specific research areas
* Changes to existing apps produced by researchers 
* Ad hoc code for processing, cleaning or presenting data
* Providing help and advice on software issues to researchers
* Providing customisations or additions to our existing applications as requested

There are also differences between team members in how, where, and how much, we habitually record what we do in each of
these areas. We agreed 
that at minimum we need to keep a retrievable record of all the work we do, so that we can see the areas that take up 
most of our time and where we can provide value.

### User Stories, user focus *(or Who are we doing it for?)*
Following on from the issue of recording what we do is the question of how we record tasks. As developers it seems 
natural to express a task in terms of the actual code changes that are made (writing a class, adding an endpoint, 
changing configuration etc). These details are often vital to record when features are being planned, to record 
technical solutions as they are thought of - but they are lousy as a record of what benefit we are adding for users of 
our systems. 

There's nothing very radical about this thought - it's the reason why the User Story was a key part of early 
incarnations of [Agile development](https://www.agilealliance.org/glossary/user-stories) in the 1990s. However we do 
recognise that as a technically-driven team, it can be easy for us to leave the user stories aside as a given when we 
first dive into thinking about technical solutions  - which makes it harder to look back at them afterwards, and 
remember what they were solutions for! So we intend to record all features as user stories as far as possible.

### Cost and Benefit *(or Why are we doing it?)*
Having zeroed in on the user benefit of a task, another question arises: is it really worth it? Sometimes the priority 
we should assign to a task is hard to determine, particularly when we have many 'clients' of different kinds - 
individual researchers of varying seniority and requirements, users of our 'products', large projects spanning multiple 
organisations - and requests ranging from tiny cosmetic changes to entire applications. 

A 'cost/benefit' metric at the task level might help us to decide which should take priority, and give us visibility of 
why we have chosen to prioritise the tasks we have. We decided that for our needs, it would be overkill to set a strict 
formula to calculate a numerical priority value, but that it would be useful to record a checklist for incoming tasks, 
recording things like:

Costs: 

* Estimated story points (or days effort)
* Additional effort to fully specify requirements
* Any additional software or hardware costs
* Any risks 

Benefits:

* Benefit to user (e.g. major new feature users have been asking for, or just a cosmetic improvement)
* Urgency (Is this a 'showstopper'?)
* How many users this will benefit, and for how long
* Is this something which could be re-used / give future benefit to the team, or other areas of our work?

All these values will be subjective and uncertain, and it may take some time for us to settle on the right checklist to 
capture. However, having a framework such as this will enable us to start to quantify the priority of our incoming tasks 
and give visibility to why prioritisation decisions have been made. 

### Communicate Success *(or Wow!)*
If the ultimate purpose of metrics is to prove our worth, and to enable us to improve, then it's not enough to just 
record how well we've done - we need to tell someone! 

We'd like to establish an identity for ourselves as a team, rather than just a bunch of individually employed RSEs, 
and to communicate ways of working together which we have found successful, as well as to let people within DIDE, 
Imperial College and beyond know how we have solved particular problems. We hope this will be of use to others, either 
by enabling them to use our applications directly, or by providing some ideas on how they could approach similar 
problems themselves. Or just by letting people know we exist!

Of course, we could also use the same channels to communicate lessons learned the hard way, or why certain things we 
tried didn't work, and we would also like to receive feedback and ideas on how we could do things better. 

We're hoping to improve our external communications through talks and presentations, by getting involved in the wider 
RSE community, and also through this blog. So watch this space!

Do these experiences resonate with any readers in other RSE teams? What metrics do you focus on? Let us know!

**Puns or kilos?*
