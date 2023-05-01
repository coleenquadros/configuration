# SOP : OSD Fleet Manager - Support a new region in production
 
[toc]
 
# 1 Introduction
 
This document defines the required steps to take to configure a new region in OSD Fleet Manager in order to support new
hypershift clusters in that region.
 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
OSD Fleet Manager is already deployed in production and has at least one region currently enabled.

## 1.3 Success Indicators
 
A new Service Cluster is created for the given region, enabling its support.
The following major components exist in the new region:
  - Service Cluster hosting ACM/MCE
  - At least one Management cluster as a chile of the Service Cluster running the Hypershift Operator and registered to
    the ACM hub as a hosting cluster
  - A provisoin shard in the clusters_mgmt API exposing the service cluster to consumers

Additionally, successful region enablement can be represented by the prescense of the region in the output of
any `rosa list regions` CLI command.
 
## 1.4 Stakeholders
 
N/A

## 1.5 Additional Details
 
Enabling a new region for hypershift cluster creation primarily consists of defining configuration for the new region
and allowing the OSD Fleet Manager application to create the necessary resources for that region enablement.

Enabling a new region should not be performed lightly - introducing new infrastructure for customer clusters results in
the inability to deprovision that infrastructure until the customer's cluster has been fully deprovisioned. The
infrastructure provisioned by OSD Fleet Manager is costly as it includes two privatelink OSD clusters of variable size
running nearly indefinitely.
 
# 2 Procedure
 
## 2.1 Plan
 
Define before-hand the requirements for the Service and Management clusters:
  - What AWS instance size should the Service cluster's compute nodes use?
  - What AWS instance size should the Managment cluster's compute nodes use?
  - Will the clusters be private? (this is almost certainly yes)
  - Will a new sector be added alongside the region?
  - In what order should the new sector, if added, be part of the progressive rollout of code changes?
 
## 2.2 Prerequisites
 
Ensure sure you have access to create merge requests and the ability to have merge requests reviewed/merged in
[app-interface](https://gitlab.cee.redhat.com/service/app-interface).

Gain approval to enable the new region from the Hypershift BU (TODO - who exactly and where to contact?).

Engage with SREP to ensure the AWS transit account for the hypershift infrastructure is properly configured to support
the new region. Example: https://issues.redhat.com/browse/OSD-15746

Engage with SREP to ensure that the AWS Accounts in the AWS Account Operator pools have the necessary increased quota
in the new region required for service/mgmt cluster functionality. Additional complexity is introduced if the region
being enabled is an "opt-in" region in AWS. For details see https://issues.redhat.com/browse/OSD-13615

Ensure the OSD Fleet Manager OCM Service Account Organization has enough quota granted to support an additional region.
See https://gitlab.cee.redhat.com/service/ocm-resources/-/blob/master/data/uhc-production/orgs/15991019.yaml

## 2.3 Execute
 
### 2.3.1 Define a new sector
It is reccomended, although not explicitly necessary, for each region to be within their own defined sector. This was
originally decided as part of [SDA-8302](). Creating a separate sector for the new region will ensure the region is
managed by a separate OSD Fleet Manager application instance with its own set of reconcilers. This will also allow you 
to establish the order in which the rollout of new features or changes will hit various regions.

If the global `CLUSTER_TEMPLATES` do not support the required configuration for the new service/management clusters, 
it is necessary to redefine the `CLUSTER_TEMPLATES` in the new sector. This will ensure newly created clusters use the 
template details defined in this sector only. For example, if the globally defined instance size for managemnet clusters
is not appropriate for this region, the correct size will need to be specified.

In the app-inteface SAAS file for OSD Fleet Manager, add a new target defining the new sector, including any parameters 
that should be specific to this new sector. Defined parameters within a target will override the global parameters 
defined for that environment. In this example MR, this change is made alongside the progressive rollout order, the 
next step in this SOP: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/66313

Once the sector is defined, pod(s) for the sector should exist in the osd-fleet-manager namespace for the environment.

Additionally, ensure that the alerts for the OSD Fleet Manager environment you've added a sector to are enabled for
the new sector. Specifically, alerts aiming to ensure that at least one pod is available at all times for each sector
need to be updated to specify the new sector. Example: 
https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/66479

### 2.3.3 Update sector progressive rollout order

The `promotion` definition of each sector defines the automatic promotion of code changes between sectors. The goal
of this promotion ordering is to ensure code changes that break the application land in the least strategic sectors 
first, with the last sectors only receiving code changes that have been validated in every previous sector.

Upon introducing a new sector, ensure the `subscribe` of other sectors is accurate to ensure that the order of sector
rollout is appropriate with the new sector added.

Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/66446

### 2.3.3 Configure automatic OCP upgrades
Upgrades for the OCP clusters service and management clusters are created on top of are automated through app-interface.
When adding a new sector/region, automatic upgrades need to be enabled/configured for that region. Example: 
https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/66479

Upgrade output can be viewed in the [app-interface-output file](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/ocm-fleet-upgrade-policies.md).

NOTE: Upgrades should be rolled out through sectors in the same order that code changes are rolled out. Ensure the 
ordering in the automatic upgrade configuration is consistent with the order of code change rollouts in the SAAS file.

### 2.3.2 Update sector predicates
In OSD Fleet Manager, the sector predicate list is an ordered list of predicates evaluated one-at-a-time by a global
reconciler running in a single deployment target. The target running this can be identified with the target containing
the parameter and value: `ENABLE_GLOBAL_WORKERS: true`. This worker will regularly evaluate all existing clusters to
ensure they are assigned to the proper sector based on the predicate list, with the final entry in the list containing
all clusters not matching any predicate. New service cluster creations are evaluated against the list as well, ensuring
clusters are created using the right sector's configuration and pods.

To ensure the new service clusters that will be created land in the correct sector, the list of sector predicates needs
to be updated after the sector is defined. If a new region + sector are being added together, a simple region predicate
can be added to the list. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/66446

### 2.3.3 Enable the new region in configuration

In the global configuration for an environment in the SAAS file for OSD Fleet Manager, there is a parameter
`SUPPORTED_CLOUD_PROVIDERS` that defines the list of regions enabled for a given cloud provider. As of this writing,
only AWS regions are supported. Enable the new region by adding it to this list. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/66451

A single reconciler runs in the target with `ENABLE_GLOBAL_WORKERS: true` that will consume this list and ensure that
at least one service cluster in ready or maintenance state exists in the region with at least one ready or maintenance
state child management cluster.

NOTE: Adding a supported region will result in immediate creation of a service and management cluster in that region.
These clusters can be large and incur high cost.

NOTE: Removing a region from this list will _not_ cause the deletion of any service or managment clusters. To disable
a region, the region should be removed from this list and then the infrastructure deleted via API.

### 2.3.4 Monitor cluster creation

Once the region list is updated with the new region, OSD Fleet Manager will automatically create a service and
management cluster in the new region. The service cluster is created first and put into a "waiting_on_child_cluster" 
state once a management cluster has started to be created. Once the management cluster is created successfully, the 
service cluster is put into "ready" state and the provision shard created in clusters-service is enabled.

To view service clusters:
```
# Get all service clusters
$ ocm get /api/osd_fleet_mgmt/v1/service_clusters

# Search service clusters by region
$ ocm get /api/osd_fleet_mgmt/v1/service_clusters -p search="region is 'us-east-2'"

# Identify and get a provision shard for a given service cluster
$ shard=ocm get /api/osd_fleet_mgmt/v1/service_clusters/${id} | jq .provision_shard_reference
$ ocm get $shard
```

To view management clusters:
```
# Get all management clusters
$ ocm get /api/osd_fleet_mgmt/v1/management_clusters

# Search management clusters by region
$ ocm get /api/osd_fleet_mgmt/v1/management -p search="region is 'us-east-2'"

# Search management clusters by parent service cluster
$ ocm get /api/osd_fleet_mgmt/v1/management -p search="parent.id = 'SERVICE_CLUSTER_ID}'"
```

Logs from the pods for the new sector can be reviewed to monitor the reconcilers working to create the service and 
management clusters.

## 2.4 Validate
 
- Review the newly created provision shard
- Review service/mgmt clusters in OSDFM API
- Run `rosa list regions` to ensure the new region appears as a supported region
- Create an HCP in the new region
  - See https://redhat:redhat@docs.openshift.com/rosa-hcp/rosa_hcp/rosa-hcp-sts-creating-a-cluster-quickly.html
- Review related grafana dashboards
 
## 2.5 Issue All Clear
 
N/A
 
# 3 Troubleshooting
 
N/A

# 4 References
 
OSD Fleet Manager API reference: https://api.stage.openshift.com/?urls.primaryName=OSD%20Fleet%20Manager%20service
OSD Fleet Manager Codebase: https://gitlab.cee.redhat.com/service/osd-fleet-manager
Clusters Management API reference: https://api.openshift.com/?urls.primaryName=Clusters%20management%20service

App-interface files:
  - OSD FM SAAS Deploy: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm/osd-fleet-manager/cicd/deploy.yaml
