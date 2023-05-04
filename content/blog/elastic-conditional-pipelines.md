---
author: "Emma Russell"
date: 2023-05-04
title: Conditionally running Ingest Pipelines with Filebeat, Docker and Elastic
tags:
 - Elastic
 - Filebeat
 - Docker
 - logging
 - DevOps
---

*TL;DR - if you want to apply an Ingest Pipeline conditionally in Elastic, consider defining it as a processor in another 
pipeline and setting its `if` property.*

# Background #

We use [Filebeat](https://www.elastic.co/beats/filebeat) to ship application logs to [Elastic](https://www.elastic.co/) 
from our [Docker](https://www.docker.com/nginx) containers. Since we dockerise anything that moves, 
we have many types of docker container, including containers for Kotlin and JavaScript web applications, for APIs written 
in R, and for [NGINX](https://www.nginx.com/) web proxies. Each type of container logs messages in a different format. 
Some of our applications ship JSON logs with the fields nicely separated out, however many of our logs have raw `message` 
fields in various formats.

Filebeat is also running in a Docker container, and is configured via `filebeat.docker.yml`, with `autodiscover` switched 
on - so we ship logs from all other docker containers using this common configuration.

# The requirement: process NGINX logs #

For our [MINT](https://mint.dide.ic.ac.uk/) application, we wanted to produce some fairly basic analytics reports on
usage of the app, segmented by url route and by user country. All the raw information we needed to construct these 
reports (client IP address and request url) are available in the standard NGINX logs, so it seemed like we should just 
harvest the data from these rather than needing to do any custom logging in the application containers.

Without any further processing, a raw logged message from nginx looks something like this:
```
128.32.22.63 - - [18/Jan/2023:12:11:36 +0000] "GET /favicon.ico HTTP/1.1" 404 757 "-" "Mozilla / 5.0(Windows NT 10.0; &) Gecko / 20100101 Firefox / 62.0" "-"
```

We needed to deconstruct this format into useful values which can be used in reports or visualisations.

# The problem: a single pipeline configuration option #

Luckily, an `nginx` [Ingest Pipeline](https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html) is 
already defined out of the box on Elastic server, which can do all the processing we need. Furthermore, we can specify an Ingest 
Pipeline in `filebeat.docker.yml` which will be applied when logs are ingested:
```
output.elasticsearch
  hosts: logs.dide.ic.ac.uk:9200
  username: elastic
  password: ${ELASTIC_PASSWORD}
  pipeline: "nginx"
filebeat.autodiscover:
...      
```

However, we wanted the pipeline to be applied only to logs from our NGINX proxy containers, and not to any others. But 
once it is defined in the yml, there is no way to conditionally apply this pipeline - it's all or nothing,


# An apparent solution: define a conditional dissect processor in Filebeats config #

This issue apparently ruled out using an Ingest Pipeline - but there was another straw to clutch at. Instead of 
specifying a global pipeline, we can also define an array of [processors](https://www.elastic.co/guide/en/elasticsearch/reference/8.7/processors.html) 
in the yml, and these can be applied conditionally. As mentioned above, some of our containers log in JSON format, and 
we are already conditionally using the `decode_json_fields` processor when a document is being logged by a container
with a given name:
```
...
filebeat.autodiscover:
  providers:
    - type: docker
      hints.enabled: true
processors:
  - if:
      equals:
        container.name: "hint_hint"
    then:
    - decode_json_fields:
        fields: ["message"]
        process_array: false
        max_depth: 1
        target: ""
        overwrite_keys: false
        add_error_key: true
...        
```

So it seemed that it should be possible to do something similar to process the NGINX logs. We tried this approach,
using the `dissect` processor to pull apart the NGINX log messages and direct the individual parts into new fields 
prefixed `nginx.` e.g. `nginx.clientip`, `nginx.status`:

```
processors:
...
 if:
    equals:
      container.image.name: reside/proxy-nginx:master
    then:
    - dissect:
        tokenizer: "%{IPORHOST:source.ip} %{USER:user.id} %{USER:user.name} \\[%{HTTPDATE:@timestamp}\\] \"%{WORD:http.request.method} %{DATA:url.original} HTTP/%{NUMBER:http.version}\" %{NUMBER:http.response.status_code:int} (?:-|%{NUMBER:http.response.body.bytes:int}) %{QS:http.request.referrer} %{QS:user_agent}"
        field: "message"
        target_prefix: "nginx"
...        
```

# The problem #2: not enough processing! #

In fact this worked pretty nicely - the `dissect` processor did what it was supposed to, and we ended up with the new nginx fields
appearing in the ingested logs. 

The problem was that the IP addresses ingested in this way stayed as monolithic strings and could not be used in this 
form to create a nice report segmented by country since the facilities for building reports and visualisations in elastic 
really require all fields to be fully processed in advance.

We can define multiple processors in the yml file, but these cannot be chained in the manner of a pipeline. So we could 
not include e.g. a `GeoIP` processor after the `dissect` processor to use the `nginx.clientip` field generated by the 
`dissect` processor to generate geographical information - each processor defined in `processors` in the yml file can
only work on the fields present in the unprocessed logs.

# Another dead end: Index patterns #

Index patterns allow post-ingestion processing of data to generate new fields which could be used in further reporting.
So it is possible that we could have done further processing of the `nginx.clientip` IP addresses in an index pattern. We wanted to use 
the `GeoIP` processor to map IP addresses to geographical data, which should have been possible using the "Painless" (!) 
scripting language's ability to invoke processors 
(described [here](https://www.elastic.co/guide/en/elasticsearch/painless/master/painless-ingest.html#painless-ingest)),
again combined with conditional application.

However, using index patterns is expensive at query time, and Elastic limits what fields can be used in index patterns.
Furthermore, we really didn't want to have to recreate the existing `nginx` pipeline with some combination of configured
and scripted processors - we just wanted to use the pipeline for some documents and not others.

# A better solution: use nginx pipeline conditionally from a second pipeline #

Ingest pipelines consist of a chain of processors e.g. the `nginx` pipeline includes a `Grok` processor to break apart the
message field, and the `GeoIP` processor already described. However, pipelines can also be used as processors in other
pipelines. And this `Pipeline` processor type has an `if` field, allowing us to specify the condition on which we want
the pipeline to run (where the condition is expressed as a Painless script).

In our case we wanted to run the pipeline when the unprocessed log's field `container.image.name` matched our nginx
proxy docker image's name, "reside/proxy-nginx:master". We are able to access the original document fields on the `ctx`
object, so here we set the `if` condition to: `ctx?.container?.image?.name == 'reside/proxy-nginx:master'`.

This allows us to achieve our goal of generating useful information from nginx logs on ingestion, including IP country,
without attempting to apply processing to logs for which it will be irrelevant.

We created a new pipeline called `nginx-conditional` with a single `Pipeline` processor as described above. Here's the 
full definition of the Processors for that pipeline:
```
[
  {
    "pipeline": {
      "name": "nginx",
      "if": "ctx?.container?.image?.name == 'reside/proxy-nginx:master'",
      "ignore_failure": true
    }
  }
]
```            

We also updated `filebeat.docker.yml` to specify the new pipeline:
```
output.elasticsearch:
  hosts: logs.dide.ic.ac.uk:9200
  username: elastic
  password: ${ELASTIC_PASSWORD}
  pipeline: "nginx-conditional"
```

The configured pipeline does not interfere with any configured `processors` in the yml file, whose
output continues to appear in the ingested logs.

This approach could also be generalised. We could potentially make a similar pipeline which could be a general
processing entry point if we find that we want to process more types of logs using further processing pipelines.
For example, to process Apache logs and SQL logs too, we could have `apache` and `sql` processing pipelines as well as
`nginx`, rename `nginx-conditional` to something like `process-all`, and define a `Pipeline` processor for each
processing pipeline, each of which applies that pipeline in its `if` field based on `container.image.name`, or some other 
relevant field value.

This whole journey was a path that would not have been trodden by someone with a deeper knowledge of Elastic than I have.
It's an extensive and powerful ecosystem, with many potential ways to approach most requirements, and the best choice is
not always obvious to the occasional user. But from my limited experience, it seems that Pipeline processors with `if`
conditions are a very useful thing to know about!
