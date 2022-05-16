# Design doc: ROSA support in App-Interface

[toc]

## Author/date

Jordi Piriz / 2022-04-18

## Tracking JIRA

[https://issues.redhat.com/browse/APPSRE-4268](https://issues.redhat.com/browse/APPSRE-4268)

## Problem Statement

As part of hypershift support, we need to be able to support openshift ROSA clusters through
app-interface.

ROSA deployment model uses the customer account to provision all the openshift components
(both control plane and data plane). Clusters' provisioning and administration are based on the
`ROSA cli` tool along with `OCM`.

App-interface only supports `OSD` clusters with the current implementation. Some enhancements are
needed to support `ROSA` clusters.

## Goals

- Identify changes required by A-I and Q-R to support ROSA clusters
- Define `ROSA` clusters provisioning details

## Non-Goals

- Define Hypershift topology/deployments

## ROSA provisioning details

### ROSA Installation overview

As `ROSA` supports STS operational mode which does not interfere with app-interface in any way, we are going
to support this operational model only. This does not prevent using additional access keys by the services
if needed.

Steps to provision a `ROSA`cluster. All Steps are subcommands of `ROSA cli`.

1. Configure AWS Account

    The account where the cluster is going to be deployed needs some configuration like creating the IAM
    roles for the cluster installation along with some Quotas and Service Control policies verifications.

2. Launch Cluster Installation.

    Cluster Installation is orchestrated from `OCM` but the installation request and some additional steps
    need `ROSA cli`. `OCM` is being improved right now to support `ROSA` and it's possible `ROSA` could be
    fully managed through `OCM` in the future.

3. Pre-Installation Steps

    These steps are created just after the cluster creation request. Cluster installation waits until these steps
    are done.

        - Create an OIDC provider. An OIDC provider is required for STS/openshift authentication.
        - Create the operator Roles. RedHat operator roles that will be used by RH to support the cluster.

4. Create the admin user
    The first admin user needs to be created with `ROSA cli`. An auth provider can be bound to the cluster
    to add user/roles too.

### Cluster configuration changes

Cluster configuration changes are a bit different than in `OSD`, for example, load balancers quota or storage
assignment do not apply to `ROSA` as all the components reside in the customer AWS account. The following list
enumerates the app-interface allowed cluster updates and if they are supported with `ROSA`

- instance_type: This is supported in our ocm code but does not seem possible without creating a new machine pool
  as described [here](https://docs.openshift.com/dedicated/osd_cluster_create/creating-an-aws-cluster.html)
- storage (Quota): N/A. The customer account provides the storage.
- load_balancers (Quota): N/A. Load balancers are deployed in the customer account
- private: Not supported in ROSA. After cluster creation, a cluster can not be changed to private
- channel: Supported. Updates are managed through `OCM`. We will use our current updates system
- autoscale: Supported (OCM)
- nodes(nodeCount): Supported (OCM)
- machinePools: Supported (OCM)

**IMPORTANT**: All the cluster modifications are available through `OCM`.

### Clusters location

We should consider using a separate AWS account to host our `ROSA` clusters. Splitting workloads into separate
accounts is a good and recommended practice from a security point of view. Taking into account that we will barely
need to access cluster infrastructure resources, deploying clusters in a separate aws account other than the AppSre
main account makes sense.

`ROSA` recommendation is to install one cluster per vpc but is possible to share a vpc among various clusters
using different subnetworks. As VPC quota can be increased to hundreds, 1 cluster per vpc is the way to go
for us. It simplifies the network configuration.

Even though it's possible, having multiple clusters per account adds complexity in the AWS resource permissions
management. For example, tenants access to Cloudwatch in shared accounts would need to be improved to efficiently
separate access to logroups of other tenants. This can be extended to all the resources in the accounts.
2
For coherence and to continue using the same approach, we will use a cluster per account like in OSD. Accounts
do not add additional costs and we would have the resources isolation without the need of changing the permissions
management.

## APP Interface management

### Cluster Installation

`ROSA` installation `OCM` support is being improved right now, there were changes in the process even while
writing this doc.

As we need to do a cluster onboarding to support new clusters, the most logical approach is to use `ROSA cli`
**manually** and once the cluster is created, add the cluster spec file and manage the cluster operations through
app-interface. Adding machinepools, changing nodecount or changing autoscaling values are available with `OCM` and
that is already implemented in app-interface.

There are various paths forward to implement the cluster creation such as adding golang integration leveraging
the `ROSA cli` codebase or creating a `ROSA cli` wrapper integration. But, as it seems `OCM` will end up supporting
the whole process, we could just hold off and wait until the `OCM` support is completed.

If we have the urge to provision a lot of clusters we can re-evaluate this approach.

### Roles

ROSA works the same way as `OSD`. `cluster-admin` and `dedicated-admin` exist in the cluster.

### Schema changes

- Convert `Cluster` type to an interface. As `OCM` supports various types of cluster types and there is a need in AI
  to support some of them, it's worth having diferentiated specs for each cluster type. We will have `OSD` and `ROSA`
  but this could be extended with future offerings (Hypershift, KCP...), so adding separate types makes sense at
  this point.

- Add a `product` attribute to identify the cluster type. `product` is already part of `OCM` api spec and is used to
  identify the cluster type. We could use the same approach in our cluster specs. This attribute will be used to identify
  the graphql subtypes and to instantiate the right OCM implementation.

### OCM code changes

Our OCM code is very tight to OSD-type clusters. Some changes are needed:

- Getting the clusters spec: Our current approach takes `OSD` related fields as mandatory but those are
  not set in `ROSA` or other types.

- Cluster Updates: Some updates that do not apply on `ROSA` such as quotas or making the cluster private.

- Cluster Creation: TBD. `OCM` support for ROSA is happening right now. Maybe is better to hold off until
  the support is done instead of implementing this with `ROSA cli`.

- AWSInfrastructureAccess: `ROSA` does not have this option through `OCM` because the aws account is
  fully managed by the customer.

The `OCM` code needs to be refactored to allow different cluster types. At first, using an interface instead
of a single cluster type is the appropriate way to manage this. A cluster implementation will be created for
each type of cluster we need to support.

The code changes to do this seems located in the `ocm.py` file, the integrations get the `ocm` reference from
the `OCM_Map` class. This needs a more deep view but at first, seems that with the clusters' initialization
an additional object could be set to add the product implementation object.

Kafka clusters are a good candidate for an additional cluster type, right now they are managed separately with
its integration and schema. But in the end, they are an additional cluster type and from a model point of
view, it would be more precise to manage them as clusters and let the implementation do the required steps.

About the AWSInfrastructureAccess, as the accounts are managed by us, we could mimic how we are managing
`OSD` aws accounts. Creating both `read-only` and `network-mgmt` roles in the destination account and adding
the IAM policies when new accesses need to be granted. This logic will need to use `AWScli` instead of `OCM`.
Following this path, all terraform integrations that use the role assumptions will still work the same way as
of now.

<img src="../assets/rosa_ocm_diagram.png" width="600"/>

#### Alternatives considered

##### Conditional branching

A possible way is to branch the code with if/else and manage `ROSA` clusters with additional paths. I consider this
a bad design as all the code would need to be modified if a new cluster type needs to be supported in the future.
On the contrary, adding separate implementations leads to a clean approach and adds maintainability to the code.

##### Separate methods in the OCM module

Such as kafka clusters, managing `ROSA` with additional methods is a viable way. I think it's better for the sake of
code comprehension, maintainability and coherence to just have different types under the cluster meta type with its
separate implementations. Following this path does not completely fit, because not all `ROSA` required logic is
implemented or brought by OCM.

### Current OCM integrations

- ocm_additional_routers: Not supported in ROSA.
- ocm_addons: Supported
- ocm_aws_infrastructure_access: Implement the same roles as in OSD, network-mgmt, and read-only.
- ocm_clusters: Split integration to per-cluster type.
- ocm_external_configuration_labels: Supported.
- ocm_github_idp: Supported. We could use the same approach as in OSD.
- ocm_groups: Supported. dedicated-admin could be assigned the same way.
- ocm_machine_pools: Supported
- ocm_upgrade_scheduler: Needs to be updated to support STS version gates. [REF](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/utils/ocm.py#L856)

## Decissions made

- Cluster installation logic will be set on hold until the OCM implementation is done.
- We will use 1 AWS account per cluster like in OSD. This way we will have the clusters isolated.
- We are going to manage the clusters with the same roles we are using for `OSD`. `dedicated-admin` and `cluster-admin`
- Aws infra access logic will be the same used with `OSD`. `read-only` and `network-mgmt` roles. This logic will be
  implemented with AWS api directly (Not supported by OCM)
- 1 level of abstraction will be added to the ocm code to support multiple types of clusters.
- ROSA will have its own clusters integration

## Changes list summary

- Change the `cluster` schema to be an interface. Each cluster type will be identified by the `product` attribute.
  Each cluster definition will only have its necessary attributes.
- Update the `ocm` code to manage different cluster implementations (OSD and ROSA). This step will open the way to
  support other `ocm` cluster implementations in the future.
- Split `ocm_clusters` integration into `osd_clusters` and `rosa_clusters`.
- Implement `AWS` STS roles management for `ROSA` cluster accounts with the `AWS api`
- Create an additional account to host AppSRE `ROSA` clusters.
- Update SOPS to include `ROSA` type clusters onboarding to app-interface

## Milestones
1.- Adapt OCM library and integrations to work with different OCM implementations
1.1.- Add OSD OCM Implementation
2.- Add ROSA OCM Implementation. Test all functionalities
3.- Update OCM documentation, SOPS, etc to include ROSA clusters.
3.- Add a ROSA Cluster to APP-Interface.

## Resources

- [OCM API Spec](https://api.openshift.com/#/default/get_api_clusters_mgmt_v1_clusters)
- [Discussion Meeting](https://drive.google.com/file/d/1gq3R3LyTFihxBScmwXrhYpq-KR0CHNiV/view?usp=sharing)
