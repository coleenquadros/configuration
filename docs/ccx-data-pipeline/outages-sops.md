# SOPs for outages

The following document contains the response process used by the CCX engineering organization to deal with incidents affecting operation of external data pipeline. 

## Incident Preliminary action

1. Acknowledge the incident
1. Verify the incident: reproduce the issue, check the monitoring, check the logs, check the pods
1. Notify @ccx-core-processing-team in the #ccx channel, making sure the team is aware of the incident
1. Send an e-mail to ccx@redhat.com and #ccx Slack channel describing the issue using the [E-mail incident announcement template](#E-mail-incident-announcement-template)

## Resolve the incident

First is necessary to check if the incident is actually cause by the pipeline and it's not due to
external factors (such as dependent system down). 

### Outage due to external factor

monitor the application, mostly [this dashboard](https://grafana.app-sre.devshift.net/d/jRluM4NMz/ccx-data-pipeline?orgId=1&from=now-1h&to=now&viewPanel=24) 

1. identify what system is down (can be oauth, ingress, 3scale, insights Operator)
    1. the pod logs that can be found in [kibana](https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover/d33b9f80-3e18-11ec-92fa-2f665ecb5ea0) or from the 
    [openshift web ui](https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/ccx-data-pipeline-prod/pods) are a good source of information on what is not working
    1. check [this dashboard](https://grafana.app-sre.devshift.net/d/jRluM4NMz/ccx-data-pipeline?orgId=1&viewPanel=24) if the lag is not consistenly growing it's very likely
    a problem with ingress 
1. notify the #ccx about your guess on what system is not working
1. nothing left to do

### Data Pipeline Outage

1. connect to the [openshift web ui](https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/ccx-data-pipeline-prod/pods) and check for terminated, crashed or 
frequently restarted pods (it's recommended to read those pods logs)
1. if you find such pods:
    1. restart them
    1. if the restart does not work, roll them back to a previous version, our deploy are 
performed with [app-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ccx-data-pipeline/deploy.yml)
1. if those pods do not exist
    1. look at the grafana dashboards, each service has one
        * [data pipeline](https://grafana.app-sre.devshift.net/d/jRluM4NMz/ccx-data-pipeline)
        * [results aggregator](https://grafana.app-sre.devshift.net/d/ruvKwhqWk/ccx-insights-results-aggregator?orgId=1)
        * [db-writer](https://grafana.app-sre.devshift.net/d/C4vK5h2Wk/ccx-insights-results-db-writer?orgId=1)
        * [smart proxy](https://grafana.app-sre.devshift.net/d/5RvvwGqW0/ccx-smart-proxy?orgId=1)
        * [sha extractor](https://grafana.stage.devshift.net/d/shaextractor/ccx-insights-sha-extractor?orgId=1) this service is unlikely to cause wide-spread outages
        * [gathering service](https://grafana.app-sre.devshift.net/d/playground/ccx-gathering-service?orgId=1&var-datasource=crcp01ue1-prometheus&var-namespace=ccx-data-pipeline-prod) this service is unlikely to cause wide-spread outages
    1. if you find anomalies such as high error rate, very slow response time, high kafka lag you identified the malfunctioning service 
        1. restart it
        1. if the restart does not work, roll it back to a previous version, our deploys are 
performed with [app-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ccx-data-pipeline/deploy.yml)

#### Notes:

Should escalation be needed refer to 
[Contacts](#contacts) and 
[List of people to reach out in case of urgency](#list-of-people-to-reach-out-in-case-of-urgency).
Follow console.redhat.com [escalation procedure](https://docs.google.com/document/d/1cv55VZaxmJp_LkE-SSk54S6IXASnGM05dSonQXiqN9k/edit), or 
direct [platform engineering contacts](https://docs.google.com/spreadsheets/d/1D4p7ZbO6C4DVrZjPV9H_au8kPEWrKMX6e4_-GJpvjHc/edit#gid=0). 
If you are not part of the #clouddot-incident channel, please ask Chris Moore (cmoore) or Bill Nottingham (notting)

### Outage resolved

1. Notify the proper channels that the issue is resolved
    * ccx@redhat.com
    * #ccx and #ccx-processing-team slack channels
    * (if applicable) #ccx-outage-YYYYMMDD slack channel (and archive the channel)

2. Follow Up Action Items

    * Plan for port mortem session
        * Example post mortem: [CCX data pipeline outage](https://docs.google.com/document/d/1qeOGdycu_pw-zd527ebhc7E7L25jg2-6mPu56Pl_Vig/edit#heading=h.p2plwqv8mg74)
    * Share the post mortem notes to ccx@redhat.com
    * Convert post mortem actions into CCX backlog

## Measuring impact

Apart from the abvious (System is not accessible, API are not accessible) our users can experience
outdated or delayed data. The delay depends on how much 
[kafka lag](https://grafana.app-sre.devshift.net/d/jRluM4NMz/ccx-data-pipeline?viewPanel=24) 
the pipeline has cumulated.
Very approximately 1000 units of lag result in users receiving data that is 30 minutes old.
Data loss happens very rarely: 

1. if the outage lasts more than 3 days our kafka retention policy does not allow to store
more message, the lag will not grow anymore and subsequent data will not be processed
1. if there's an ongoing outage and the lag DOES NOT increase but it's zero or mostly constant
data loss is occurring (lag is expected to grow during outages)
   
it's important to register the time frame (data loss start time and end time) during data loss 
because our tooling to recover data in those scenario requires it. There no need for minutes 
or seconds precision, the day and the hour are enough. Moreover the need to register the 
time frame is needed only in case the kafka lag dashboard was malfunctioning as well.


##  underlying/integrated services

| Service                       | Usage                                                        | Owners     | Access URL                                                                                                                                                                                                                                                                                   | Access Method            | Documentation                                                       |
| ----------------------------- | ------------------------------------------------------------ | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ | ------------------------------------------------------------------- |
| Openshift PSI (v3 or v4)      | Used to deploy all of our services                           | PnT DevOps | [V3 Prod](https://paas.psi.redhat.com/console/project/ccx-prod/overview) / [V4 Dev](https://console-openshift-console.apps.ocp4.prod.psi.redhat.com/k8s/cluster/projects/ccx-dev) / [V4 Prod](https://console-openshift-console.apps.ocp4.prod.psi.redhat.com/k8s/cluster/projects/ccx-prod) | Openshift Login          |                                                                     |
| Jenkins                       | Used to run our E2E tests                                    | CCX        | [Dashboard](https://dev-jenkins-csb-ccx.cloud.paas.psi.redhat.com/)                                                                                                                                                                                                                          | LDAP credentials         |                                                                     |
| Sentry                        | Used to collect errors (monitoring tool)                     | ?          | [BaseOs Org](https://sentry.engineering.redhat.com/baseos/)                                                                                                                                                                                                                                  | Red Hat SSO              |                                                                     |
| GitLab                        | Used to store our source code                                | PnT DevOps |                                                                                                                                                                                                                                                                                              | Red Hat SSO              |                                                                     |
| GitLab CI                     | Used to run tests and trigger builds that deploy to our envs | PnT DevOps |                                                                                                                                                                                                                                                                                              | Red Hat SSO              |                                                                     |
| Red Hat SSO                   | Used to authenticate users in Kraken                         | IAM        | N/A                                                                                                                                                                                                                                                                                          |                          | [SSO Information](https://mojo.redhat.com/docs/DOC-1150936)         |
| AWS S3                        | Used to store archives for short term                        | App SRE    | N/A                                                                                                                                                                                                                                                                                          | Credentials              |                                                                     |
| AWS SQS                       | Used to receive alerts of incoming archives in S3            | App SRE    | N/A                                                                                                                                                                                                                                                                                          | Credentials              |                                                                     |
| Ceph                          | Used to store archives and processed data for long term      | DataHub    | N/A                                                                                                                                                                                                                                                                                          | Credentials              | [DataHub Help](https://help.datahub.redhat.com/)                    |
| Kafka                         | Used as message broker in the pipeline                       | DataHub    | N/A                                                                                                                                                                                                                                                                                          | Certificate              | [DataHub Help](https://help.datahub.redhat.com/)                    |
| Thanos                        | Used to query cluster information (owners, alerts, etc)      | DataHub    | [Query Explorer](https://telemeter-lts.datahub.redhat.com/graph)                                                                                                                                                                                                                             | Openshift Login          | [DataHub Help](https://help.datahub.redhat.com/)                    |
| Grafana                       | Used only to monitor services                                | DataHub    | [Dashboard](https://grafana.datahub.redhat.com/dashboard/db/ccx-kafka)                                                                                                                                                                                                                       | Openshift Login          | [DataHub Help](https://help.datahub.redhat.com/)                    |
| Kibana                        | Used only to query logs from pods                            | DataHub    | [Explorer](https://kibana.datahub.redhat.com/)                                                                                                                                                                                                                                               | Openshift Login          | [DataHub Help](https://help.datahub.redhat.com/)                    |
| Insights Core Messaging (ICM) | Framework used to build some of the services                 | Insights   | [GitHub](https://github.com/RedHatInsights/insights-core-messaging)                                                                                                                                                                                                                          | N/A                      | [GitHub](https://github.com/RedHatInsights/insights-core-messaging) |
| Insights Core                 | Framework used to process archives                           | Insights   | [GitHub](https://github.com/RedHatInsights/insights-core)                                                                                                                                                                                                                                    | N/A                      | [GitHub](https://github.com/RedHatInsights/insights-core)           |
| RHEL UBI                      | Base image for most of our services                          | RHEL UBI   | [Pulp Repository](https://cdn-ubi.redhat.com/content/public/ubi/dist/)                                                                                                                                                                                                                       | N/A                      | [UBI Portal](https://developers.redhat.com/products/rhel/ubi)       |
| Quay.io                       | Pull some images for CI                                      | Quay.io    | [Quay Website](https://quay.io/)                                                                                                                                                                                                                                                             | Red Hat SSO / user Login |                                                                     |

## Contacts

| **Team**                        | **How to report an issue?**                                                                                                                                                                                                             | **GChat**                                                                                                                | **Slack**                                                                           | **IRC** | **Mailing List**                                                                                                                                                                                                                      | **Escalation procedure**                                                                                                                                                                                                                                                                                                              |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PSI Infra (Formerly PnT DevOps) | [ServiceNow](https://redhat.service-now.com/help?id=catalogs_home)                                                                                                                                                                      | [exd-infra-escalation](https://chat.google.com/room/AAAA6BChWkY) / [exd-infra](https://chat.google.com/room/AAAAUYvaAAk) |                                                                                     | #psi    | [psi-ocp-users](https://groups.google.com/a/redhat.com/g/psi-ocp-users/about)                                                                                                                                                         | Open a ticket and ping on GChat                                                                                                                                                                                                                                                                                                       |
| IAM                             | [ServiceNow](https://redhat.service-now.com/help?id=catalogs_home)                                                                                                                                                                      |                                                                                                                          |                                                                                     | #iam    |                                                                                                                                                                                                                                       | Open a ticket and ping on IRC                                                                                                                                                                                                                                                                                                         |
| App SRE                         | [Jira](https://issues.redhat.com/projects/RHCLOUD)                                                                                                                                                                                      |                                                                                                                          | [#sd-app-sre](https://redhat-internal.slack.com/archives/CCRND57FW) at @app-sre-ic           |         |                                                                                                                                                                                                                                       | [Follow this Guide](https://docs.google.com/document/d/1cv55VZaxmJp_LkE-SSk54S6IXASnGM05dSonQXiqN9k/edit#heading=h.8tc4lctof9qa)                                                                                                                                                                                                      |
| OSD                             | [ServiceNow](https://mojo.redhat.com/external-link.jspa?url=https%3A%2F%2Fredhat.service-now.com%2Fnav_to.do%3Furi%3D%252Fcom.glideapp.servicecatalog_cat_item_view.do%253Fv%253D1%2526sysparm_id%253D200813d513e3f600dce03ff18144b0fd) |                                                                                                                          | [#sd-sre-platform](https://redhat-internal.slack.com/archives/CCX9DB894) at @sre-platform-ic |         |                                                                                                                                                                                                                                       | [Follow this Guide](https://docs.google.com/document/d/1cv55VZaxmJp_LkE-SSk54S6IXASnGM05dSonQXiqN9k/edit#heading=h.gkqy7uutypoa)                                                                                                                                                                                                      |
| Quay.io                         | ?                                                                                                                                                                                                                                       |                                                                                                                          | See App SRE                                                                         |         | [quay-devel](https://groups.google.com/a/redhat.com/g/quay-devel)                                                                                                                                                                     | [Follow this Guide](https://docs.google.com/document/d/1cv55VZaxmJp_LkE-SSk54S6IXASnGM05dSonQXiqN9k/edit#heading=h.f8amdxlulzif)                                                                                                                                                                                                      |
| DataHub                         | [ServiceNow](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=4c66fd3a1bfbc4d0ebbe43f8bc4bcb6a) ([Must read before](https://help.datahub.redhat.com/))                                                                         | [DataHub](https://chat.google.com/room/AAAAiODw-Fc)                                                                      | [#ccx](https://redhat-internal.slack.com/archives/CLABA9CHY) at @data-hub                    |         | [data-hub-users](https://groups.google.com/a/redhat.com/g/data-hub-users/about) (general questions / announcements)<br>[data-hub](https://mailman-int.corp.redhat.com/mailman/listinfo/data-hub) (internal mailing list, escalations) | Team coverage 8x5 (business hours, NA timezone), no on-call duty. Best effort outside of business hours.<br>Ping on GChat, better if with a ticket<br>Escalation manager: [Alex Corvin](https://rover.redhat.com/people/profile/acorvin)                                                                                              |
| Console.redhat.com              |                                                                                                                                                                                                                                         |                                                                                                                          | **[#forum-clouddot](https://redhat-internal.slack.com/archives/C022YV4E0NA) **               |         | [insights-platform](https://mailman-int.corp.redhat.com/mailman/listinfo/insights-platform)                                                                                                                                           | **_@crc-escalation - escalation point for ConsoleDot core services as needed  <br>@ma-escalation-team - troubleshooting assistance for the services listed within the M&A organization in this [sheet](https://docs.google.com/spreadsheets/d/1D4p7ZbO6C4DVrZjPV9H_au8kPEWrKMX6e4_-GJpvjHc/edit#gid=1886825234) (see Tenants tab)._** |
| Insights                        | [GitHub](https://github.com/RedHatInsights/)                                                                                                                                                                                            |                                                                                                                          |                                                                                     |         |                                                                                                                                                                                                                                       | [Follow this Guide](https://docs.google.com/document/d/1cv55VZaxmJp_LkE-SSk54S6IXASnGM05dSonQXiqN9k/edit#heading=h.cd8jybyzfsa5)                                                                                                                                                                                                      |
| CEE                             | ?                                                                                                                                                                                                                                       |                                                                                                                          | [#ccx](https://redhat-internal.slack.com/archives/CLABA9CHY) at @cee-team                    |         |                                                                                                                                                                                                                                       |                                                                                                                                                                                                                                                                                                                                       |
| OpenShift                       | [Bugzilla](https://bugzilla.redhat.com/) (find the right component for your issue)                                                                                                                                                      |                                                                                                                          | [#office-brno](https://redhat-internal.slack.com/archives/CBNU4GLKH)                         |         | [aos-devel](https://groups.google.com/a/redhat.com/g/aos-devel/about)                                                                                                                                                                 |                                                                                                                                                                                                                                                                                                                                       |
| RHEL UBI                        | [Bugzilla](https://bugzilla.redhat.com/) (under Red Hat Enterprise Linux)                                                                                                                                                               |                                                                                                                          |                                                                                     |         |                                                                                                                                                                                                                                       | Open a ticket and ping Josh                                                                                                                                                                                                                                                                                                           |
| Go-Toolset                      | [Bugzilla](https://bugzilla.redhat.com/) (under Red Hat Enterprise Linux, DevTools)                                                                                                                                                     | [Alejandro Saez](mailto:asaezmor@redhat.com)                                                                             |                                                                                     |         |                                                                                                                                                                                                                                       | Chat with him before opening a ticket (sometimes he is already working on a fix or a new version)                                                                                                                                                                                                                                     |

## List of people to reach out in case of urgency

| Team      | Person            | Role     | Location      | Can help with                                          | Found at                                       |
|-----------|-------------------|----------|---------------|--------------------------------------------------------|------------------------------------------------|
| PSI Infra | Alex Pariz        | Infra    | CZ - Brno     | PSI related questions regarding infra, versions, so on | GChat (exd-infra) / IRC                        |
|           | Keith Fryklund    | Infra    | US - Boston   | Escalate issues                                        | GChat (exd-infra)                              |
| Data Hub  | Alex Corvin       | Infra    | US - Raleigh  | Outages, service change, upgrades                      | DataHub GChat or CoreOS Slack                  |
|           | Maulik Shah       | Infra    | US - Boston   | Data Hub infra (Kafka, Ceph)                           | DataHub GChat or CoreOS Slack                  |
| App SRE   | Christopher Moore | Manager  | US - Virginia | Escalate issues, find right people                     | Ansible Slack                                  |
|           | Feng Huang        | SRE      | US - Boston   | AWS S3 / SQS                                           | Ansible Slack / CoreOS Slack                   |
|           | Asa Price         | Engineer | US - Raleigh  | AWS S3 / SQS                                           | Ansible Slack                                  |
|           |  Kyle Lape        | Engineer | US - Texas    | AWS S3 / SQS, new AWS credentials                      | Ansible Slack / CoreOS Slack, channel clouddot |
|           | Stephen Adams     | Engineer | US - Raleigh  | AWS S3 / SQS, new AWS credentials, Ingress             | Ansible Slack / CoreOS Slack, channel clouddot |
| Insights  | Chris Sams        | Engineer | US - Arkansas | Features, bugs, questions around Insights              | Ansible / CoreOS Slack                         |
|           | Jesse Jaggars     | Engineer | US - Raleigh  | Features, bugs, questions around Insights              | Ansible / CoreOS Slack                         |
| OpenShift | Michal Fojtik     | Engineer | CZ - Brno     | Operators, many other topics, find right people        | CoreOS Slack                                   |
|           | Clayton Coleman   | Engineer | US - Raleigh  | Insights Operator                                      | CoreOS Slack                                   |
|           | Vadim Rutkovsky   | Engineer | CZ - Brno     | Usage of IO data in Kraken by OCP team                 | CoreOS Slack                                   |
| RHEL UBI  | Josh Boyer        | Engineer | US - Miami    | Problems and requests for UBI                          | GChat                                          |





## E-mail incident announcement template

Hi,

this e-mail is to inform you about an incident in the CCX data pipeline.

**Summary:** [Simple sentence describing the outage/incident]

**Impact:** [describe the impact of the outage / incident] 

**Impact on customers:** [describe the impact of the outage / incident on the customers, something like "outdated reports will be shown"]

**Incident Date - Time:** [known time/date since we are facing the incident]

**Expected data loss:** [yes/no]

**Expected data availability delay:** [estimate of resume the data processing and the data availability]

**Contact person:** [usually the person who handled the outage]

**Communication channels:** [@ccx-core-processing-team in #ccx slack channel / #outage-war-room-for-given-outage / JIRA card to follow] 

Should you have any questions, feel free to reach out.
