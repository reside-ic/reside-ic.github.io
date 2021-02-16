---
author: Mark Woodbridge date: 2021-02-15 title: Aggregating logs from services deployed with Docker tags:

- Docker
- ELK
- Logging

---

To-do

- [ ] Architecture image?

# Introduction

The [Elastic (ELK) Stack](https://www.elastic.co/what-is/elk-stack) is commonly used to centralise logs from across
multiple servers, providing a single point of access to the aggregated messages. Its components are open source and can
be self-hosted, albeit with some operational complexity. In this post we show how to set up a simple deployment, focused
on logging from applications deployed in one or more Docker containers. We’ll do this by describing our setup and
explaining a few of the choices that we’ve made - we’re still in the early days of exploring how Elasticsearch and
Kibana can help to monitor applications and identify and resolve issues in our code.

# Method

The unofficial [docker-elk](https://github.com/deviantony/docker-elk) project provides a very helpful setup for running
the stack itself in Docker, effectively simplifying deployment to `docker-compose up`. The key components are the log
indexer (Elasticsearch) and the web interface (Kibana).

The steps to deploymentsare:

- Clone [docker-elk](https://github.com/deviantony/docker-elk)
- Make any desired changes to the configuration, such as those described below
- Do some one-time setup steps, as described in README:
  ```sh
  docker-compose up elasticsearch -d
  docker-compose exec -T elasticsearch bin/elasticsearch-setup-passwords auto --batch
  # Make a note of these passwords
  docker-compose down
  ```
- Bring up Elasticsearch and Kibana and create an index pattern:
  ```sh
  export KIBANA_PASSWORD=…
  docker-compose up -d
  docker-compose exec kibana curl -XPOST -D- 'http://localhost:5601/api/saved_objects/index-pattern' -H 'Content-Type: application/json' -u elastic:${ELASTIC_PASSWORD?} -d '{"attributes":{"title":"filebeat-*,journalbeat-*","timeFieldName":"@timestamp"}}'
  ```
- Send some logs to Elasticsearch (see below)
- Visit http://localhost:5601 (assuming you’re not running a proxy - see below)
- Log in using username `elastic` and the password you noted earlier
- View logs, create visualisations/alerts/dashboards etc

We make some (
optional) [changes to the default configuration](https://github.com/deviantony/docker-elk/compare/main...reside-ic:main)
as follows:

- We don’t run an Elasticsearch cluster (yet) so we don’t need to
  expose [port 9300](https://discuss.elastic.co/t/what-are-ports-9200-and-9300-used-for/238578)
- We’re not currently using the Elasticsearch keystore, so we’ve removed the bootstrap password
- We’re using Filebeat and Journalbeat in their default configurations to send logs directly to Elasticsearch, so we
  don’t need to run Logstash - which reduces operational complexity
- We ensure that Elasticsearch and Kibana restart automatically if the Docker host is rebooted
- We expose the Kibana web interface via SSL using
  a [separate Nginx proxy](https://github.com/reside-ic/logs/blob/main/docker-compose.override.yml) container, so we
  don’t need to expose port 5601 to the host
- As we use [Vault](https://www.vaultproject.io/) for password management we pass the Kibana password as an environment
  variable rather than embedding it in the configuration file
- We only use the non-commercial features of the stack

Once you’ve got Elasticsearch up and running you can set up one or more [Beats](https://www.elastic.co/beats/) agents to
forward logs from your containers. These too can
be [run in containers](https://github.com/reside-ic/beats/blob/main/docker-compose.yml). Our applications use the
Docker `json-file` and `journald` logging drivers, so we use Filebeat and Journalbeat - our setup is
documented [here](https://github.com/reside-ic/beats). Again, we use Vault for credential storage, but for a simple
deployment you could store the secrets in a suitably secured Docker Compose `.env` file. These agents talk directly to
Docker (via volumes and/or socket) so don’t need to be on the Docker network as the relevant containers.

# Next steps

This will give you a minimal setup - it’s worth ensuring the following for a robust, scalable and secure system:

- Users/roles with access to Kibana are suitably restricted
- Your Elasticsearch and Kibana Docker volumes are backed-up
- Sensitive information is either not logged by your applications or is shipped with suitable security (e.g.
  [using SSL](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-ssl.html)) and appropriately access
  controlled. Obviously information such as credentials should never be logged.
- Log messages are suitably structured, so they can be easily searched/filtered
- Related containers/services share a common Docker Compose project name, Docker container tag etc, so that they can be
  grouped as one unit within Elasticsearch/Kibana.

# Acknowledgements

Thanks to Elasticsearch and the docker-elk contributors for making their respective projects freely available.

Images? Architecture?
