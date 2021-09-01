# Splunk & app-sre

## Table of Contents

* [Overview](#overview)
* [Current Application](#current-application)
* [Corporate Guides](#corporate-guides)
* [Implementation Details](#implementation-details)

## Overview

[Splunk Enterprise](https://splunk.corp.redhat.com/) is a data search / analysis / visualization tool that is administered by Red Hat Corporate IT. Raw event data is sent to one of multiple event collectors and is made available to multiple Splunk applications for consumption. One common application is Splunk search, allowing users a time-based parameter search to find occurences of an event with specified search parameters. See more details about Splunk Enterprise on their [documentation website](https://docs.splunk.com/Documentation/Splunk/8.2.2/Overview/AboutSplunkEnterprise).

## Current Application

Considering the multitude of monitoring and logging solutions that app-sre uses and implements, app-sre has a single, specific use case in mind for Splunk logging activity: **postmortem intrusion detection and forensics**. In the case of a security breach in our deployment systems, security teams at Red Hat would use Splunk Enterprise to construct a who / what / when / where timeline of a suspected breach, and follow code and deployment changes through our stack via Splunk events.

There is a company mandate that any system that has the ability to touch code must be logged to Splunk. As such, app-sre sends Splunk events for the following services:

* ci-int
* ci-ext
* tekton-pipelines (for all tenants)

## Corporate Guides

* [Splunk Documentation](https://source.redhat.com/departments/it/splunk/splunk_wiki/)
* [Splunk HEC Event Collector Endpoints](https://source.redhat.com/departments/it/splunk/splunk_wiki/splunk_fy20_architecture_blueprint#splunk-http-event-collectors-hec-)
* [Splunk Access / Support Requests](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=ed13c6af1b2a2c50e43942a7bc4bcbc3)

### Getting Support / Working with IT

IT manages Splunk access requests through a ServiceNow portal, ["Access to Monitoring Platform"](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=ed13c6af1b2a2c50e43942a7bc4bcbc3).

For critical needs or continuing established direct support threads, there is a direct communication channel through Google Chats. The direct link to the chat space is [here](https://mail.google.com/chat/u/0/#chat/space/AAAAvuMOFCY). Alternatively, you can visit [Google Chat](https://mail.google.com/chat/), find the "Rooms" section in the left navigation pane, and click the "+" add icon, and search for the "Splunk" chat room.

## Implementation Details

Adding Splunk logging to an exisitng application is technically straightforward. Events are sent over HTTP to a HTTP Event Collector (HEC) endpoint with a required JSON format and application-specific index. 

Collector endpoint selection depends on the volume of data consumed by that collector and where the submitter lives in relation to the VPN. Internal and external endpoints are available.

Indexes are the core pivot for data flowing into Splunk and must be created through collaboration with Corporate IT before said events will show in Splunk searches.

Splunk collectors require an access token to send an event payload to the collector. Access tokens are bound to specific indicies. Future applications wishing to send events to Splunk must work with IT to generate a token that allows writing events to a specified index. If an existing index makes sense for the application, then an existing token/index combination can be used.

### Vault Secrets

Splunk secrets are housed in Vault at this path: `app-sre/creds/splunk/<application-name>`.

### Indexes

A Splunk [index](https://docs.splunk.com/Splexicon:Index) is a repository for data. Indexes allows partitioning of data on index keys, allowing efficient retrieval of data associated with a given index. For app-sre applications, we have two separate indices for our current use cases. Future expansion of app-sre Splunk usage means additional indicies must be created to partition data properly. Alternatively, we can use an existing index that matches the application, given we have access tokens that permit writing to an index.

* ci-int / ci-ext: `index="jenkins"`
* tekton-pipelines: `index="rh_tekton_pipeline"`

### Events

Events are JSON formatted strings which contain the event payload, metadata about the event, and indexing information.

Example Human Readable Payload

```
{
   "event":{
       ...
   },
   "time":"$(date +%s)",
   "host":"<>",
   "source":"<>",
   "sourcetype":"json",
   "index":"rh_tekton_pipeline"
}
```

Example Curl Payload

```
{"event":{"saas_file_name":"${saas_file_name}","env_name":"${env_name}","aggregate_task_status":"${aggregate_task_status}","tkn_cluster_console_url":"${tkn_cluster_console_url}","tkn_namespace_name":"${tkn_namespace_name}","pipelinerun_name":"${pipelinerun_name}"},"time":"$TIMESTAMP","host":"${tkn_cluster_console_url}","source":"app-sre-tekton-pipelines-$SOURCE_POSTFIX","sourcetype":"json","index":"rh_tekton_pipeline"}
```

Example implemenation

```
#!/usr/bin/env bash
#
# This script pushes pipeline execution metadata
# to Splunk.

function log() {
    echo "`date '+%Y-%m-%d %H:%M:%S'` -- $@" 1>&2
}

log "PUTting Tekton Pipeline Run Metadata to $SPLUNK_URL"

if [ "$INTERNAL" = true ]; then
SOURCE_POSTFIX="internal"
else
SOURCE_POSTFIX="production"
fi

TIMESTAMP=$(date +%s)

HTTP_RESPONSE_CODE=$(curl -k -w '%{http_code}' -o /dev/null -H "Authorization: Splunk ${SPLUNK_TOKEN}" --header "Content-Type: application/json" "$SPLUNK_URL/services/collector/event" --data-binary @- <<DATA
{"event":{"saas_file_name":"${saas_file_name}","env_name":"${env_name}","aggregate_task_status":"${aggregate_task_status}","tkn_cluster_console_url":"${tkn_cluster_console_url}","tkn_namespace_name":"${tkn_namespace_name}","pipelinerun_name":"${pipelinerun_name}"},"time":"$TIMESTAMP","host":"${tkn_cluster_console_url}","source":"app-sre-tekton-pipelines-$SOURCE_POSTFIX","sourcetype":"json","index":"rh_tekton_pipeline"}
DATA
)

EXIT_RC=$?

log "HTTP RESPONSE CODE: $HTTP_RESPONSE_CODE"
log "exiting with return code $EXIT_RC"
exit "$EXIT_RC"
```
