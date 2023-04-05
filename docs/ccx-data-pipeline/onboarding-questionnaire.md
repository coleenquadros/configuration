# Onboarding Questionnaire

### Onboarding epic

<https://issues.redhat.com/browse/SDE-1820>

### Product/Service Name

CCX Data Pipeline

### Service Owners

Daniel Bílý
dbily


Daniele Pensiero
dpensier
Software engineer


Jan Frieser
Jan Frieser


Jiří Papoušek
Jiří Papoušek


Jose Luis Segura
joseluis


Juan Díaz
jdiazsua


Martin Zibricky
Software Quality Engineer


Martina Maťka Slabejová
mslabejo


Papa Bakary Camara
bacamara
CCX Processing SWE


Pavel Tisnovsky
ptisnovs

### Product Manager(s)
Radek Vokál


### Team Lead(s)
Pavel Tisnovsky

### Lead architect for hosted version of service
N/A

### Program Manager(s)
Jan Frieser

### CEE Contact
Jan Frieser

### Documentation Contact
any service owner

### QE Contact
Martin Zibricky

### Physical location of the team(s)
Czechia and Spain

### BU Contacts/Stakeholders
TODO

### JIRA Board
https://issues.redhat.com/projects/CCXDEV

### Team Contact Information (mailing list, slack channel, etc)
ccx@redhat.com

#ccx-processing-team channel on slack

@ccx-core-processing-team team on slack

### Is your team on CoreOS Slack?
Yes

## Service Description
### Recorded demos, on-stage demos, youtube videos
| Description                                        | Slides                                                                                                                | Recording                                                                                       |
|----------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| New networking data                                | [slides](https://docs.google.com/presentation/d/1lZ44h0n2v-iFS_nRqQamGkOGzo_LY3vSRPmamwG1jL8/edit?usp=sharing)        | [recording](https://drive.google.com/file/d/1eK5ccb_CSLsSKQVGsPOIF7qXMyC5ym5-/view?usp=sharing) |
| Parquet Factory refactoring                        | [slides](https://docs.google.com/presentation/d/1LfxI-6HDKRTvI5kwdU14yrGpNxX0y5AMYRQdLgSEfkU/edit?usp=sharing)        | [recording](https://drive.google.com/file/d/1mHWZKg_snNmA3NumPug_oqHVIVV07bxM/view?usp=sharing) |
| "RDS burst balances are depleted" adventure        | [slides](https://github.com/RedHatInsights/insights-results-aggregator/tree/master/docs/presentations/DB-write-speed) | [recording](https://drive.google.com/file/d/1w4FIuBpx8LqUzoap88PVlPfHIQx5KqD4/view?usp=sharing) |
| Processing time metadata available in ext pipeline | [slides](https://docs.google.com/presentation/d/1CKGlfcNc8Se47CAd_SGAB3k9CtH82PBscuwfyJMpu8w/edit#slide=id.p)         | [recording](https://drive.google.com/file/d/13Nbp4YEtnn5LTC2F39V5ETuQyrNmKLgw/view?usp=sharing) |
| Data gathering service                             |                                                                                                                       | [recording](https://drive.google.com/file/d/1A_hyiEqdWkiqPGWOIv-8mx3CHxwDG8W1/view?usp=sharing) |
| New Parquet Files                                  | [slides](https://docs.google.com/presentation/d/1FtmhTKK9LQPzV65LS4QXWufqRJardbDVQdEKjSIWkno/edit?usp=sharing)        | [recording](https://drive.google.com/file/d/1uCAaNVpPi9fnFyhuOON3fF2XnJXDI4Zd/view)             |
| SHA Extraction service PoC                         | [docs](https://supreme-garbanzo-c43cccab.pages.github.io/)                                                            | [recording](https://drive.google.com/file/d/17_0Nxv7zIMzd1qhC4fEm683jMB5HPQRm/view)             |
| SHA extraction: status + plan                      |                                                                                                                       | [recording](https://drive.google.com/file/d/1X50tnSYTwsODL1f-y5P0A6JjmiqCO0Uv/view)             |
| Advisor Unification Update                         |                                                                                                                       | [recording](https://drive.google.com/file/d/18_AU4OM-CcqsCH-TL0bWwGguEm2dPjjL/view)             |
| Table-driven RESP API testing                      | [docs](https://tisnik.github.io/poc-table-driven-rest-api-tests/)                                                     | [recording](https://drive.google.com/file/d/1k2evUYa1_KRT-nCwY4zUXrfyL8rPgIbQ/view)             |
| Vulnerability app design                           | [docs](https://docs.google.com/document/d/1FDCo3ejJ2d-a2wKz6SFeq-Rx2eQCK81BZe1sWvJi7lg/edit#)                         | [recording](https://drive.google.com/file/d/16QPpxjdzIAZEsdG6uWSso-o0WS70dwED/view)             |

### Service Diagram
<https://ccx.pages.redhat.com/ccx-docs/docs/processing/customer/external-data-pipeline/external_data_pipeline_architecture/>

### Service Documents
<https://ccx.pages.redhat.com/ccx-docs/docs/processing/customer/>

## Service Status

Live

### Basic Informations

* **Does your Service currently run on OpenShift Dedicated v4?**

yes

* **Does the service require cluster-admin to run?**

no

* **Is a single instance of the service a monolithic pod or multiple pods?**

multiple pods with different tasks (pods built from different images)

* **How does the service scale to meet increased load?**

we must apply an ad hoc solution for different situations: sometimes we increase the pod count, 
when it's not possible we increase MEM or CPU

* **Does the service use a language stack (including code dependencies) that is supported by Red Hat?**

the service is build with Python and Go

* **Does the service use any third party tools or services as part of the offering?**

no

* **Is your service supported by CEE?**

no

* **Do you have any non-OSD requirements? (ie VM’s, Data Center, Labs, etc)**

no

* **Do you have any existing customers that are looking to convert to a hosted solution?**

no

* **Do you need any additional work from Service Delivery? (ie. OCM features)**

no

* **Can the service handle OSD upgrades while satisfying the business needs?**

yes

### Deployment

* **What kind of service is this? SaaS, Bin-packed, Addon?**

SaaS

* **Does the service use any operators?**

Clowder

* **Are they Red Hat certified operators?**

yes

* **Is the development team engaged with the Operator Enablement Team?**

no

### Data Model

* **How does the service store and access data?**

S3, Postgres, Kafka

* **Does the service require in-cluster storage?**

yes

* **Does this storage need to be persisted?**

yes

* **If yes, how & where is the data backed up?**

in a postgres database, more info about backup policies
in the [continuity document](continuity.md)

* **Does the service require external storage? S3, Redis, etc.**

yes, S3

* **Does the service use CRDs to store application data/state?**

no

* **Does the application use a database?**

yes

* **Does it support postgres?**

yes

* **Is the service DB version dependent?**

no

* **How will database schema migrations be performed?**

an [initContainer](https://github.com/RedHatInsights/insights-results-aggregator/blob/master/deploy/clowdapp.yaml#L207) that runs every deployment. If this pod finds a database version that's older than the latest one it performs the migration, does nothing otherwise

* **Are schema changes made with forward/backward compatibility?**

yes

* **Do SQL Queries use indexes and appropriate secondary indexes?**

yes

* **Does the service connect to the database over an SSL connection?**

yes

* **Does the database contain any sensitive information (like being able to identify a customer)?**

We process _only_  Insights Operator data and all the IO data was vetted with a [PIA]
(https://issues.redhat.com/browse/CCXDEV-75), documented [here](https://redhat-assess.truste.com/#/report/c1f3fd87-fc25-4f26-be05-944f94649369/summary). Relevant data such us IP and user identifiable infos are not sent to us in clear because it's anonymized and/or obfuscated at the source([discussion](https://docs.google.com/document/d/18Ba3vB-T_MX4of89wmIlIIvyBazkkOqb2P4mAg0HZec/edit)).

* **Does the service need any other external cloud services?**

no

* **How is the data backed up?**

refer to [continuity document](continuity.md)

* **Does the service have a Disaster Recovery procedure?**

like above, refer to [continuity document](continuity.md)

### Configuration

* **Can the service be configured with environment variables?**

yes

* **Does the service use a configuration file?**

yes

* **monolithic config or multiple/layered?**

generally multiple/layered

### Networking

* **Does your application expose any protocol other than https?**

no

* **Can the service handle an external dependency being unreachable for a short period of time without requiring a restart? (ie RDS, S3, etc)**

yes

* **Can an openshift router handle the expected traffic load?**

we must go through ingress/3Scale

### Security

* **Will the service run with letsencrypt certificates?**

no

* **Does the service need to meet any security compliance certifications?**

no

* **Has this service gone through the Enterprise Security Standard assessment**

no

### Quality

* **Describe the service testing strategy (unit, functional, integration, e2e, etc)**

we implement unit, functional, integration, e2e, BDD and load tests

* **What is the release process for the service?**

We deploy with app-sre already, our [deploy.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ccx-data-pipeline/deploy.yml)

* **Is there an independent QE team?**

yes

* **Are there automated tests they can provide the QE team to run during release sign off?**

yes

* **What criteria must be met for QE to begin testing?**

our testing is continuous 

### Observability

* **Describe the metrics to monitor and evaluate the service performance**

we monitor the archives we process in a given period of time, number of errors, and kafka lag

* **Does the service expose a prometheus exporter?**

yes, serveral

* **Is there a dashboard to track overall service health?**

Yes, there is an SLO dashboard with the main metrics that can be found at:

* [CCX-Processing SLO Stage](https://grafana.stage.devshift.net/d/ccxprocessingslo/ccx-processing-slo?orgId=1)
* [CCX-Processing SLO Prod](https://grafana.app-sre.devshift.net/d/ccxprocessingslo/ccx-processing-slo?orgId=1)

It is recommended to use the stage one as the prod panels have some frontend related errors.

Apart from this dashboard, there are dashboards per service:

* <https://grafana.app-sre.devshift.net/d/jRluM4NMz/ccx-data-pipeline>
* <https://grafana.app-sre.devshift.net/d/ruvKwhqWk/ccx-insights-results-aggregator>
* <https://grafana.app-sre.devshift.net/d/C4vK5h2Wk/ccx-insights-results-db-writer>
* <https://grafana.app-sre.devshift.net/d/s9xNxABnz/ccx-insights-content-service>
* <https://grafana.app-sre.devshift.net/d/5RvvwGqW0/ccx-smart-proxy>
* <https://grafana.stage.devshift.net/d/shaextractor/ccx-insights-sha-extractor> (deployed to stage grafana due to known problems)
* <https://grafana.app-sre.devshift.net/d/playground/ccx-gathering-service>

### Business Goals

* **Service Success Criteria**
* **How many customers/users do you anticipate?**
* **Service Level Agreement (SLA)**
* **Do you have a Business Continuity Plan (BCP)? Have you engaged the Red Hat Business Continuity Program team**

all this points will be discussed and formalized during our onboarding [link to the epic](https://issues.redhat.com/browse/CCXDEV-7238)

* **Which offering are you planning to run your product/service at launch - OSD, AMRO, ARO, all?**
* **Do you have any time pressures that Service Delivery should be aware of? (ie. Summit Launch)**
* **What is your desired time to market for this product as a managed service?**

We're already live and [deploying with app-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/ccx-data-pipeline/deploy.yml)

* **What is your engineering escalation policy?**
* **How can RFEs/SRE issues be fast tracked?**
* **Are any existing SREs running the service?**

refer to the [sops document](outages-sops.md)

### Upstream Repositories

#### Services
* <https://gitlab.cee.redhat.com/ccx/ccx-data-pipeline>
* <https://gitlab.cee.redhat.com/ccx/ccx-sha-extractor>
* <https://github.com/RedHatInsights/insights-results-smart-proxy/>
* <https://github.com/RedHatInsights/insights-results-aggregator/>
* <https://github.com/RedHatInsights/insights-results-aggregator-cleaner/>
* <https://github.com/RedHatInsights/insights-results-aggregator-data/>
* <https://github.com/RedHatInsights/insights-content-service/>
* <https://github.com/RedHatInsights/insights-operator-gathering-conditions-service>
* <https://github.com/RedHatInsights/insights-operator-gathering-conditions>
* <https://github.com/RedHatInsights/ccx-notification-writer/>
* <https://github.com/RedHatInsights/ccx-notification-service/>
* <https://github.com/RedHatInsights/insights-kafka-monitor>
#### Tests
* <https://github.com/RedHatInsights/insights-behavioral-spec>
* <https://github.com/RedHatInsights/insights-results-aggregator/tree/master/tests>
* <https://github.com/RedHatInsights/ccx-notification-service/tree/master/bdd_tests>
* <https://github.com/RedHatInsights/ccx-notification-writer/tree/master/bdd_tests> 
* <https://gitlab.cee.redhat.com/insights-qe/iqe-ccx-plugin>

### Technology Stack

aws S3, Ceph, Ingress, Kafka, Postgres

### Container Images

* <https://quay.io/repository/cloudservices/ccx-notification-service>
* <https://quay.io/repository/cloudservices/ccx-notification-writer>
* <https://quay.io/repository/cloudservices/insights-results-aggregator>
* <https://quay.io/repository/cloudservices/ccx-data-pipeline>
* <https://quay.io/repository/cloudservices/ccx-smart-proxy>
* <https://quay.io/repository/cloudservices/io-gathering-conditions-service>
* <https://quay.io/repository/cloudservices/io-gathering-conditions>
* <https://quay.io/repository/cloudservices/ccx-insights-content-service>
* <https://quay.io/repository/cloudservices/ccx-sha-extractor>
* <https://quay.io/repository/cloudservices/insights-results-aggregator-cleaner>
* <https://quay.io/repository/cloudservices/ccx-kafka-monitor>
* <https://quay.io/repository/cloudservices/io-gathering-conditions>

### Routes

* What API is being exposed over each route?

https://console.redhat.com/docs/api/insights-results-aggregator and

https://console.redhat.com/api/gathering/gathering_rules

https://console.redhat.com/api/gathering/openapi.json

those APIs are documented [here](https://console.redhat.com/docs/api)
under `OpenShift Insights`


### Capacity
* **Amount of CPU/Memory per pod required to run at current and future load requirements**
* **Number of pods required to run at current and future load requirements**
* **Amount of storage (DB, S3, local, etc) required to run at current and future load requirements**

[capacity planning document](capacity-planning.md)
### Internal Dependencies

![internal dependencies](img/internal-dependencies.png)

### External Dependencies

crc, crc kafka, app-sre, ingress, 3Scale, Clowder, iqe plugin

### Application Requirements in OpenShift

* **Openshift features this service relies upon**

standard ones

* **Deployment constraints**

none

* **Co-location requirements**

none

### Service Level Indicators

### Service Level Objectives

SLIs and SLOs are summariazed in this dashboard:

* [CCX-Processing SLO Stage](https://grafana.stage.devshift.net/d/ccxprocessingslo/ccx-processing-slo?orgId=1)
* [CCX-Processing SLO Prod](https://grafana.app-sre.devshift.net/d/ccxprocessingslo/ccx-processing-slo?orgId=1)

### Logging, Metrics, Monitoring, & Alerting
#### Logging

* **Service log level is set to INFO for above**

no, we rely on DEBUG messages, even in production

* **Errors are valid and contain stack traces or could be made to via adjustable debug levels**

yes

* **Does the service support json logging?**

yes

* **Does it use defined fields?**

yes

* **How long should logs be retained?**

current retention is fine

* **Does the service support using sentry for error handling?**

yes, [here](https://sentry.devshift.net/sentry/) in the #ccx-data-pipeline project

#### Metrics

* **Are metrics exported for all SLIs?**

yes

* **What alert rules will be used to alert when an SLO is breached?**

alerts are defined [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/observability/prometheusrules/insights-ccx-processing-slo.prometheusrules.yaml)

### Testing

* **What kind of load testing has been done on the application?**

load testing is performed multiple times a day with a
[jenkins job](https://jenkins.ccx-dev.engineering.redhat.com/job/ccx-load-test/)

* **Are there unit tests with negative cases?**

yes

