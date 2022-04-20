# Design doc: ROSA support in App-Interface

## Author/date

Jordi Piriz / 2022-04-18

## Tracking JIRA

[https://issues.redhat.com/browse/APPSRE-4268](https://issues.redhat.com/browse/APPSRE-4268)

## Problem Statement

As part of hypershift support, we need to be able to manage ROSA type openshift (ROSA) clusters through app-interface. ROSA deployment model uses the customer account to provision all the openshift components (both control plane and data plane). The provisioning is based on the `ROSA cli` tool and `OCM`.

A ROSA cluster is installed/deployed following these steps.

1. Configure AWS Account
The account where the cluster is going to be deployed needs some configuration like creating the IAM roles for the cluster installation along with some Quotas and Service Control policies verifications. This step is fully automated with `ROSA cli`.

2. Launch Cluster Installation.
Cluster Installation is orchestrated from OCM, but the request to install the cluster is implemented with `ROSA cli` too. The cli allows to set all the required parameters and then it requests the cluster creation to `OCM`. `OCM` uses the
IAM roles created in the previous step to install the cluster (STS)

3. Post Installation Request Steps
2 steps need to happen after the cluster installation is requested (they need the cluster Id?) and are provided by Rosa CLI.

- Create an OIDC provider. An OIDC provider is required for STS/openshift authentication.
- Create the operator Roles. RedHat operator roles that will be used by RH to support the cluster.

4. Create the admin user
The first admin user needs to be created with `ROSA cli`. An auth provider can be bound to the cluster to add user/roles too.

## Goals

- Identify the changes required by A-I and Q-R to support ROSA
- Define the implementation details on how to provision ROSA clusters.

## Non-Goals

- TBD

## Proposals

### Installation Mode

As `ROSA` supports STS operational mode which does not interfere with app-interface in any way, we are going to support this operational model only. This does not prevent to use of additional access keys by the services if needed.

### Clusters location

By default `ROSA` uses 1 `vpc` per cluster, we need to define where we are going to deploy the clusters managed by APPSre. VPC quota can be increased to hundreds of vpcs, so this is not going to be a problem for the public clusters.
We should consider using a separate AWS account to host our `ROSA` clusters. Splitting workloads into separate accounts is a good practice from a security point and is a recommended practice. Taking into account that we will barely need to
access the resources in this account, it makes sense to have the underlying clusters infrastructure isolated from our main account.

### Clusters Management

Are these clusters going to be supported by SRE-P in case of infra outages etc?

### Monitoring

Are these clusters being to be monitored the same way as we are monitoring OSD?

### Cluster day2 oeprations

Cluster configuration changes are a bit different than in OSD, for example, load balancers quota or storage assignment do not apply in `ROSA` as all the components reside in the customer AWS account.
The following list enumerates the  app-interface allowed updates by app-interface and if they are supported in `ROSA`

- instance_type: This is supported in our ocm code but does not seem possible without creating a new machine pool as described [here](https://docs.openshift.com/dedicated/osd_cluster_create/creating-an-aws-cluster.html)
- storage (Quota): It does not apply in ROSA, the customer account provides the storage.
- load_balancers (Quota): N/A load balancers are deployed in the customer account
- private: Not supported in ROSA. After cluster creation, a cluster can not be changed to private
- channel: Supported. Updates are managed through `OCM`. So we would use our current updates logic. (soak days)
- autoscale: Supported.
- nodes(nodeCount): Supported.
- machinePools: Supported.

**IMPORTANT**: All the cluster modifications are available through `OCM`.

## APP Interface management

`ROSA` installation is very tight to `ROSA cli` while the cluster modifications can be made with `OCM`. As we need to do a cluster onboarding to support new clusters, the most logical approach to deploy new clusters is to
use `ROSA cli` **manually**. Once the cluster is created we can create the cluster spec file and manage it through app-interface for the common management stuff like adding machine_pools, changing the autoscale values, nodecount, etc.

Implementing a `ROSA cli` wrapper in app-interface to support the cluster creation is not worth IMO, we are not going to create so many clusters to consider this worthwhile and we might need to adapt the code to future releases of `ROSA cli`. So at first, just using the cli as final users to create clusters and managing day-to-day tasks with `OCM`is the smarter approach.


## OCM Needed changes

Our OCM code is very tight to OSD-type clusters. Some changes need to be done in the `OCM` library to support ROSA.

- Getting the cluster spec: Getting the cluster specs method needs changes to support ROSA. Our current approach takes OSD related fields as mandatory but those aren't in ROSA.

- Cluster Updates: There are updates that do not apply with ROSA (quotas and making the cluster private)

- Cluster Creation: This step won't be implemented for ROSA.

The best way to update the code is to manage the OCM CRUD operations as an interface and move the implementation to dedicated Classes. The OCM Cluster spec has a `product` attribute object that identifies the cluster type. The starting idea is to leverage this field to instantiate the
desired interface implementation to do cluster operations such as update, retrieve the spec, create (OSD), etc.

This way if we need to support other types in the future the code will still work and we would just need to implement the new cluster type.

[API Spec](https://api.openshift.com/#/default/get_api_clusters_mgmt_v1_clusters)
