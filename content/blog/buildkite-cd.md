---
author: "Rob Ashton"
date: 2022-09-27
title: Continuous Delivery with Buildkite
tags:
 - Buildkite
 - CD
 - deployment
 - DevOps
---

# Introduction

Our deployments at RESIDE typically consist of a python script using [constellation](https://github.com/reside-ic/constellation) to bring up a set of docker containers each of which contains a separate part of the application. We might have one docker image for the web app, one for the database, one for redis, one for an R backend API, and multiple workers. We use [Buildkite](https://buildkite.com/) as part of our CI (continuous integration) process to build these images and test them.

When we want to deploy a new feature to production our process typically involves:
1. ssh onto the staging server
1. Run the deployment script
1. Manually test the app for any issues
1. ssh onto the production server
1. Deploy to production
1. Manually test the app for any issues

This creates barriers to deployments: there are tedious manual steps involved you need to remember what server the app is running on, what script needs to be run, and how it is run. Additionally, we want to limit access to the machines to avoid accidental breakages. We have researchers on the team who don't work with the command line regularly and want to be able to deploy changes to their part of the code to see the effect it will have on the full app.

We wanted a way to
* Reduce the barrier to deployment making it easy and quick to encourage frequent integration and deployment
* Deploy automatically to a staging server so we can always review the state of the current master/main
* Allow researchers to redeploy and see their code changes without having to go through the development team

This blog post covers how we have used Buildkite within RESIDE to support continuous delivery of new features to staging environments. This does not cover details of the deployment script itself but how we have set up Buildkite agents and configured a pipeline so that we can deploy via running a build, have it trigger automatically and deploy specific tags of docker images through build [environment variables](https://buildkite.com/docs/pipelines/environment-variables).

# Setting up Buildkite agent

We want to create a separate agent from our normal build agents so that a deployment does not have to wait on any long-running builds. Buildkite agents can be configured to listen to specific queues. The default queue is called `default` – jobs added without a specified queue go onto the `default` queue and Buildkite agents without a specified queue pull jobs from this queue. We can create an agent which listens to a different queue by setting the `queue` tag in the [agent configuration](https://buildkite.com/docs/agent/v3/configuration). For example set `tags="queue=deploy"` to pull jobs from the `deploy` queue.

To run the script on the remote server the agent will need an ssh key pair. These need to be static and not change if the agent is torn down and brought up again. We have added a persistent ssh key pair into our [vault](https://www.vaultproject.io/) secret store. Then when the agent is brought up we read the secret out of the vault and write it into the ssh dir.

```
AGENT_SSH=~buildkite-agent/.ssh
mkdir -p $AGENT_SSH
vault read -field=public secret/deploy/ssh > $AGENT_SSH/id_deploy.pub
vault read -field=private secret/deploy/ssh > $AGENT_SSH/id_deploy
chmod 600 $AGENT_SSH/id_deploy
chown -R buildkite-agent.buildkite-agent $AGENT_SSH
```

We then add the public key to the list of authorised keys on the app host server.

We can now start the agent. In the agents list on Buildkite, we can see the agent running with the queue set to `deploy`. We now have an agent listening on a dedicated deploy queue that can run scripts on the app host server. Next, we need to set up the deployment pipelines themselves.
<img src="/img/buildkite-cd-agent.png" alt="png of agent list"/>

# Deployment pipeline

We define our deplyoment pipeline using a yml file in at path `./buildkite/deploy-pipeline.yml` with content

```
steps:
  - label: ":rocket: deploy"
    command: >-
      ssh -i ~/.ssh/id_deploy -oStrictHostKeyChecking=accept-new <username>@<host> './deploy.sh'
    agents:
      queue: "deploy"
```

The important parts here are
* The `ssh` command sets the key to use via `-i ~/.ssh/id_deploy`
* `StrictHostKeyChecking` is set to `accept-new`, this will accept the host key the first time but refuse to connect if the saved key does not match. This will suffice for us because our agents and host server are on a private internal network so we can trust accepting an unknown key the first time we login to the remote server.
* `<username>@<host>` is be the username and host of the remote server where the app will be deployed
* `./deploy.sh` is the name of the deployment script on the remote server

Now we need to add the pipeline to Buildkite. This is a little different to adding a new CI build because we want finer control over when this pipeline is triggered.

1. Login to Buildkite and click the "+" icon to add a new pipeline
1. Set the "Git Repository URL" to the repo containing the deployment pipeline
1. Set the steps to "Read steps from repository" and update the "Commands to run" to use the path to the deployment pipeline `buildkite-agent pipeline upload ./buildkite/deploy-pipeline.yml`
1. Set the "Agent Targeting Rules" to `queue=deploy`, we can see that this queue matches one of the connected agents
   <img src="/img/buildkite-cd-pipeline.png" alt="png of pipeline setup"/>
1. Click "Create Pipeline"
1. Skip the webhook setup as we do not want the deployment to be triggered on changes to the repo which contains the pipeline
1. Go to pipeline settings and update the default branch to "main"
1. Go to the "GitHub" settings and scroll down to select "Disable all GitHub activity" and click save.

We now have a pipeline that can be manually run to deploy our app.

# Triggering the pipeline

Buildkite allows you to set up triggers for your pipeline so that as well as deploying by manually starting the build we can deploy automatically when another build has completed. For example, say we have services A and B which form an app we want to deploy. A and B both have a CI pipeline running on Buildkite already. When either A or B is updated (i.e. there is a new commit on the main branch) we want to trigger the deployment pipeline. To do this we add a trigger to the bottom of the pipeline yml, after all the tests have been run

```
  - wait

  # This makes sure that deploys are triggered in the same order as the
  # test builds, no matter which test builds finish first.
  # see https://buildkite.com/docs/pipelines/controlling-concurrency
  - label: "Concurrency gate"
    command: "exit 0"
    if: build.branch == 'main'
    concurrency: 1
    concurrency_group: "app-concurrency-gate"

  - wait

  - label: ":rocket:"
    trigger: "deploy"
    if: build.branch == 'main'
```

Buildkite can support more complex [triggers](https://buildkite.com/docs/pipelines/trigger-step) and [scheduled builds](https://buildkite.com/docs/pipelines/scheduled-builds). For our use case, we have a pipeline that deploys to a staging instance which is triggered automatically whenever there is a change to any of the services which form the app.


# Controlling deployment

We would also like to have the option to deploy a specific branch of one of our services so we can see the effect of big changes before merging into main. Buildkite gives us a way to do this through [environent variables](https://buildkite.com/docs/pipelines/environment-variables#defining-your-own). Each service that forms part of the app has a CI pipeline that builds a docker image. These are tagged with the branch name and the sha. We can use environment variables to set the tag of the docker image we want to deploy. There are multiple ways to set environment variables but in this example we set them through the pipeline yml. We updated our deployment pipeline to look like

```
env:
  TAG: "${TAG:-main}"

steps:
  - label: ":rocket: deploy"
    command: >-
      ssh -i ~/.ssh/id_deploy -oStrictHostKeyChecking=accept-new <username>@<host> './deploy.sh --tag=$TAG'
    agents:
      queue: "deploy"
```

This will define an env var `TAG` with default value `main` which will then be passed into the command step. The deployment script will have to take a `--tag` argument to bring up the docker container with that specific tag.

When we run a build via the Buildkite UI we can then set the environment variable in the new build dialog.

<img src="/img/buildkite-cd-run.png" alt="png of pipeline run"/>

# Next steps

We wanted to set up Buildkite deployment pipelines to both simplify deployments and automate repeated manual work. We now have pipelines that will allow us to deploy manually, deploy automatically, and deploy a specified tag of a docker image. When we deploy to the staging instance we still have to manually check the newly deployed version works. This is slow and prone to missing regressions. When we deploy a new feature we manually check it, but we don't necessarily check all other parts of the app. Bugs can be introduced which we only know about when users report issues or we notice errors in the logs. We could take the automation a step further by writing browser tests that run after the deployment.
