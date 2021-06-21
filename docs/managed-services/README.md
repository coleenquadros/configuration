# Kafka Service Fleet Manager

Kafka Service Fleet Manager is a service for provisioning and managing fleets of Kafka instances. 


## Kafka Service Architecture
The Kafka service fleet manager is a Golang service which exposes an API using mux for users to create and delete Kafka instances. It also exposes endpoints for the fleetshard data plane components to communicate, similar to the k8s agent/control plane architecture. It also serves as the public API for users to create, delete and reset credentials for service accounts in MAS-SSO.

### Service Diagram
![Kafka Service Fleet Manager Component Architecture](https://gitlab.cee.redhat.com/service/kas-fleet-manager/-/raw/main/docs/images/kas-fleet-manager-component-architecture.png)

### Routes
All user routes are viewable from the [swagger UI in api.openshift.com](https://api.openshift.com/?urls.primaryName=kafka%20service%20fleet%20manager%20service)

All fleetshard routes are viewable from the [private-api OpenAPI spec](https://gitlab.cee.redhat.com/service/kas-fleet-manager/-/blob/main/openapi/kas-fleet-manager-private.yaml). This endpoints are public but the authentication is through MAS-SSO instead of sso.redhat.com
### Dependencies

This part will focus on what KAS Fleet Manager uses these dependencies
1. *Cluster Service*: 
   Used for OSD cluster creation, addon installation, IDP setup, trusted datapath (SyncSets) and scaling compute nodes
2. *Account Management Service*: 
   Quota reconciliation, Quota consumption, Terms Acceptance, Export Control
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



### Components 
#### Envoy container
All traffic goes through the envoy container, which sends requests to the 3scale limitador instance for global rate limiting across all API endpoints

**Impact if not available:**
If limitador is unavailable, the envoy configuration is setup to forward all requests to the kas-fleet-manager container. If the envoy container itself was unavailable, the API would be unavailable.

#### Kas-fleet-manager container
Customer endpoints for kafkas, service accounts. Internal endpoints for fleetshard operator communication. 

##### API
The API endpoints are exposed via the swagger-ui in [api.openshift.com](https://api.openshift.com/?urls.primaryName=kafka%20service%20fleet%20manager%20service).

**Impact if not available:**
If any of the portion of the API is unavailable, the service would be unavailable for all users. There is an API availability SLO which measures this.

###### Kafka user facing endpoints. 

These endpoints are used for Kafka Management, Kafka Metrics, Supported Cloud Providers and Regions. 
A live preview of the these endpoints is available on [api.stage.openshift.com swagger docs](https://api.openshift.com/?urls.primaryName=kafka%20service%20fleet%20manager%20service).
Authentication is provided via *sso.redhat.com* whilst authorization checks are done internally in kas-fleet-manager.

###### Service accounts user facing endpoints

These endpoints are used for Kafka Service Account Management.  
A live preview of the these endpoints is available on [api.stage.openshift.com swagger docs](https://api.openshift.com/?urls.primaryName=kafka%20service%20fleet%20manager%20service).
Authentication is provided via *sso.redhat.com* whilst authorization checks are done internally in kas-fleet-manager.

###### Fleetshard data plane endpoints

Direct communication endpoints from the data plane fleetshard component. 
Authentication is done via *MAS-SSO*. Authorization is done via Keycloak roles and custom claim checks. 
>NOTE: The agnet endpoints can be found in our [repo](https://gitlab.cee.redhat.com/service/kas-fleet-manager/-/blob/main/openapi/kas-fleet-manager-private.yaml) 

#### Reconcilers
In order to check which pod is the leader of a specific reconciler, you can check the leader pods panel in the [Grafana dashboard](https://grafana.app-sre.devshift.net/d/WLBv_KuMz/kas-fleet-manager-metrics?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-consoleurl=https:%2F%2Fconsole-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com)

**Impact if not available:**
If any of the reconcilers are unavailable, parts of the service would be unavailable for all users. For example, if the preparing Kafka reconciler is unavailable, all new Kafka instances would be stuck in a `preparing` status. the Kafka creation latency SLO will pick up on this scenario.
##### Kafka reconcilers

The Kafka reconcilers are a background job that handles asynchronous operations for Kafka instances based on user API requests.
There is one leader per reconciler across all replicas. The leader is elected via the distributed leader election algorithm. 

There are 6 Kafka reconcilers in total, each covering a particular Kafka instance state.
- accepted worker
- preparing worker
- provisioning worker
- ready worker
- deleting worker
- general worker

##### OSD cluster reconciler
The OSD cluster reconciler is responsible for dynamic OSD cluster provisioning, terraforming and scaling. 
It also handles deprovioning of OSD clusters when demands decreases.
There is one leader across all replicas. The leader is elected via the distributed leader election algorithm. 

Terraforming in this context is the provisioning of all additional Managed Kafka components on the OSD cluster after cluster service reports it is ready. This mainly includes the fleetshard operator, observability operator and Kafka SRE IDP.

### Application Success Criteria
- Successfully instantiate a Kafka cluster on the data plane OSD clusters
- Allow a Kafka owner to retrieve Kafka cluster details such as the bootstrap server host
- Allow a Kafka owner to delete their Kafka cluster which will trigger the associated instantiated resources on the data plane OSD clusters to be modified/deleted.
- Allow a Kafka owner to create, delete and reset credentials of service accounts which are used for authenticating with their Kafka instance
- Ensure there is always at least one cluster available in each cloud provider region with enough capacity to meet the demand of incoming Managed Kafka creation requests
- Successful scaling of nodes on the data plane OSD clusters
- Successfully terraform the OSD clusters so they are ready for Kafka clusters to be instantiated. Terraforming includes but is not limited to installing the Strimzi operator and the necessary monitoring resources on the OSD cluster.

### State
#### Postgres Database 
We use AWS RDS instance. Before each deployment, we perform migrations via [Gorm](https://gorm.io/), which are rolled back in case of failures. 
The services constitutes of the following tables:
1. `kafka_requests`
2. `clusters`
3. `leader_leases`
4. `migrations`

We use [Gorm](https://gorm.io/), for every interaction with the database.

#### Persistent Volumes
None are used
### Performance Testing

See the [performance testing guide in our repo](https://gitlab.cee.redhat.com/service/kas-fleet-manager/-/blob/main/test/performance/README.md) for more information.

## Support Rota for Stage

Every control plane team member will take support responsibility for two weeks. The 1st week, they act as the primary, in the 2nd week, they will act as a secondary. The schedule for the rota is in [PagerDuty](https://redhat.pagerduty.com/teams/P7FY0UF). Please refer to the is [comprehensive suport guide](https://docs.google.com/document/d/1xklhSgyWZKcxv2_PV2KIhreIpAtnGnoXS-3D_nXs6xA/edit#) for the full responsibilities, daily health checks and debugging issues

The main responsibility of Primary are: 
1. To shield other team members from unplanned work
2. To perform daily health-check (action alerts, sentry, CI failures) and to action them whenever possible.
