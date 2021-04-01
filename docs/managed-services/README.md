# Kafka Service Fleet Manager

Kafka Service Fleet Manager is a service for provisioning and managing fleets of Kafka instances.


## Kafka Service Architecture

[Kafka Service Architecture](https://drive.google.com/drive/u/0/folders/1Z8_DJ4oFrwjCGx9iGkc3WSNbkPd40uNX)

The architecture diagram is scoped to what will be in place for our public evaluation release at Red Hat Summit. 
Additional components such as *Connector Types Services* will be added in the control plane in the future. 

### Dependencies

This part will focus on what KAS Fleet Manager uses these dependencies
1. *Cluster Service*: 
   Used for OSD cluster creation, addon installation, IDP setup, trusted datapath (SyncSets) and scaling compute nodes
2. *Account Management Service*: 
   Access Control, Quota reconciliation, Quota consumption, Terms Acceptance, Export Control
3. *MAS-SSO*: 
   Authentication for subset of endpoints, creation of users service accounts, creation of clients for internal use and as the Kafka SRE identity provider
4. *Observatorium*: 
   Retrieving user facing metrics
5. *sso.redhat.com*:
   Authentication for subset of endpoints
6. *AWS Route 53*:
   Creation of CNAME records for Kafka instances
7. *AWS RDS*:
   PostgreSQL database to persists kafka instances records    

## Kafka Service Fleet Manager Component Architecture

![Kafka Service Fleet Manager Component Architecture](https://gitlab.cee.redhat.com/service/kas-fleet-manager/-/raw/master/docs/images/kas-fleet-manager-component-architecture.png)

The kas-fleet-manager offers three main core functions.

### API 

Customer endpoints for kafkas, service accounts and connectors. Internal endpoints for fleetshard operator communication. 

The API endpoints are exposed via a swagger-ui, see the below example images. 

1. Kafka user facing endpoints. 

These endpoints are used for Kafka Management, Kafka Metrics, Supported Cloud Providers and Regions. 
A live preview of the these endpoints is available on [api.stage.openshift.com swagger docs](https://api.stage.openshift.com/?urls.primaryName=managed-services-api%20service).
Authentication is provided via *sso.redhat.com* whilst authorization checks are done via AMS.

2. Service accounts user facing endpoints

These endpoints are used for Kafka Service Account Management.  
A live preview of the these endpoints is available on [api.stage.openshift.com swagger docs](https://api.stage.openshift.com/?urls.primaryName=managed-services-api%20service).
Authentication is provided via *sso.redhat.com*. Custom authorization checks for public evaluation.

3. Agents Endpoints

Direct communication endpoints from the data plane agent. 
Authentication is done via *MAS-SSO*. Authorization is done via Keycloak roles and custom claim checks. 
>NOTE: The Agents can be found in our [repo](https://gitlab.cee.redhat.com/service/kas-fleet-manager/-/blob/master/openapi/kas-fleet-manager-private.yaml) 

### Kafka reconciler

The Kafka reconciler is a background job that handles asynchronous operations for Kafka instances based on user API requests. 
The reconciler is responsible for handling provisioning and deprovisioning jobs of kafka instances. 
There is one leader across replicas. The leader is elected via the distributed leader election algorithm. 

### OSD cluster reconciler

The OSD cluster reconciler is responsible for dynamic OSD cluster provisioning, terraforming and scaling. 
It also handles deprovioning of OSD clusters when demands decreases.
There is one leader across replicas. The leader is elected via the distributed leader election algorithm. 

## Postgres Database

We use AWS RDS instance. Before each deployment, we perform migrations via [Gorm](https://gorm.io/), which are rolled back in case of failures. 
The services constitutes of the following tables:
1. `kafka_requests`
2. `clusters`
3. `leader_leases`
4. `migrations`

We use [Gorm](https://gorm.io/), for every interaction with the database.

## Alerts and SLOs

We have 7 alerts in total. 6 of them are based on the SLOs and cluster SLIs shown in tables below. One alert is based on if the service is down. 
Alerts definition are based on [multiwindow, multi-burn rate](https://sre.google/workbook/alerting-on-slos/) and are unit tested. 

Resources: 

1. https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/observability/prometheusrules all kas-fleet-manager-*
2. https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/managed-services/sop

### API SLIs and SLOs
   
| SLI Definition 	|  SLI Implementation	| SLO 	|
|-	|-	|-	|
|  **API Availability**: Based on the 5xx status code in the API responses 	| Count of non 5xx status code divided by count of all requests<br> *metric: haproxy_backend_http_responses_total* |  **99%**	|
| **API Latency**: The proportion of sufficiently fast successful requests 	|  Count of successful requests with a duration that are less or equal to 100ms (or 200ms) divided by the count of all requests<br>*metric: api_inbound_request_duration*|  **90% of requests < 100ms** <br>**99% of requests < 1000ms**|

<br>

### Kafka Cluster SLIs and SLOs
   
| SLI Definition 	|  SLI Implementation	| SLO 	|
|-	|-	|-	|
|  **Kafka Cluster Provisioning Latency**: The proportion of sufficiently fast successful Kafka cluster creation 	| Count of successful provisioning with a duration that are less or equal to 4m30s (or 6m) divided by the count of all provisioning <br>*metric: kas_fleet_manager_worker_kafka_duration* | **90% < 4 minutes, 30 seconds**<br>**99% < 6 minutes**|
| **Kafka Cluster Lifecycle Correctness**: The proportion of successful Kafka cluster provisioning or deletion  operations that are performed by our service background worker	|  Count of successful provisioning (or deletion) operations divided by the count of total Kafka provisioning operations <br>*kas_fleet_manager_kafka_operations_success_count*|  **99%**|

<br>

### OSD Cluster SLIs
   
| SLI Definition 	|  SLI Implementation	| SLO 	|
|-	|-	|-	|
|  **OSD Cluster Provisioning Latency**: The proportion of sufficiently fast successful OSD cluster creation | Count of successful provisioning with a duration that are less or equal to 40m (or 60m) divided by the count of all provisioning.  <br>*metric: kas_fleet_manager_worker_cluster_duration* | No SLO|
| **OSD Cluster Provisioning Correctness**: The proportion of successful OSD cluster provisioning operations that are performed by our service background worker |  Count of successful OSD cluster provisioning requests divided by the count of total OSD cluster provisioning requests <br>*kas_fleet_manager_cluster_operations_success_count*|  No SLO |

<br>

## Performance Testing

See the [performance testing guide in our repo](https://gitlab.cee.redhat.com/service/kas-fleet-manager/-/blob/master/test/performance/README.md) for more information.

## Support Rota for Stage

Support documentation and [rota](https://docs.google.com/spreadsheets/d/1ElYIlJ4YqhM7vxywH5Hmtej7vpPF6ggmv0e1pGZuN4M/edit#gid=0) in place to address issues in the stage environment. Each week there are two team members of rota. The first one as Primary and the second member as Secondary. 
At the end of the week, the Primary member sends out the report of what happened and becomes Secondary on the next week. 

The main responsibility of Primary are: 

1. To shield other team members from unplanned work
2. To perform daily health-check (action alerts, sentry, CI failures) and to action them whenever possible.
