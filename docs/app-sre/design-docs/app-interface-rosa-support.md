# Design doc: ROSA support in App-Interface

## Author/date

Jordi Piriz / 2022-04-18

## Tracking JIRA

[https://issues.redhat.com/browse/APPSRE-4268](https://issues.redhat.com/browse/APPSRE-4268)

## Problem Statement

As part of hypershift support, we need to be able to support openshift ROSA clusters through
app-interface.

ROSA deployment model uses the customer account to provision all the openshift components
(both control plane and data plane). Cluster's provisioning and administration are based on the
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

Steps to privision a `ROSA`cluster. All Steps are subcommands of `ROSA cli`.

1. Configure AWS Account

    The account where the cluster is going to be deployed needs some configuration like creating the IAM
    roles for the cluster installation along with some Quotas and Service Control policies verifications.

2. Launch Cluster Installation.

    Cluster Installation is orchestrated from `OCM`, but the request to install the cluster is implemented
    with `ROSA cli` too. The cli allows to set all the required parameters and then it requests the cluster
    creation to `OCM`. `OCM` uses the IAM roles created in the previous step to install the cluster (STS)

3. Post Installation Request Steps

    These steps are created after the cluster creation request. Cluster installation waits until these steps
    are done.

        - Create an OIDC provider. An OIDC provider is required for STS/openshift authentication.
        - Create the operator Roles. RedHat operator roles that will be used by RH to support the cluster.

4. Create the admin user
    The first admin user needs to be created with `ROSA cli`. An auth provider can be bound to the cluster
    to add user/roles too.

### Cluster configuration changes

Cluster configuration changes are a bit different than in `OSD`, for example, load balancers quota or storage
assignment do not apply in `ROSA` as all the components reside in the customer AWS account. The following list
enumerates the app-interface allowed cluster updates and if they are supported with `ROSA`

- instance_type: This is supported in our ocm code but does not seem possible without creating a new machine pool
  as described [here](https://docs.openshift.com/dedicated/osd_cluster_create/creating-an-aws-cluster.html)
- storage (Quota): N/A. The customer account provides the storage.
- load_balancers (Quota): N/A. Load balancers are deployed in the customer account
- private: Not supported in ROSA. After cluster creation, a cluster can not be changed to private
- channel: Supported. Updates are managed through `OCM`. We would use our current updates system
- autoscale: Supported (OCM)
- nodes(nodeCount): Supported (OCM)
- machinePools: Supported (OCM)

**IMPORTANT**: All the cluster modifications are available through `OCM`.

### Clusters location

We should consider using a separate AWS account to host our `ROSA` clusters. Splitting workloads into separate
accounts is a good and recommended practice from a security point of view. Taking into account that we will barely
need to access cluster infrastructure resources, it makes sense to deploy the clusters in a separate aws account
other than the AppSre main account.

By default `ROSA` uses 1 `vpc` per cluster. VPC quota can be increased to hundreds of vpcs per aws account,
so this is not going to be a problem for the public clusters.

## APP Interface management

`ROSA` installation is very tight to `ROSA cli` while the cluster modifications can be made with `OCM`.
As we need to do a cluster onboarding to support new clusters, the most logical approach to deploy new
clusters is to use `ROSA cli` **manually** and once the cluster is created,  create the cluster spec
file and manage the cluster operations through app-interface. Adding machinepools, changing nodecount
or autoscaling values are done with `OCM` and that is already implemented in app-interface.

Implementing a `ROSA cli` wrapper in app-interface to support the cluster creation is not worth IMO, we
are not going to create so many clusters to consider it worthwhile and we might need to adapt the code
to future releases of `ROSA cli`. So at first, just using the cli as final users to create clusters and
managing day-to-day tasks with `OCM` is the smarter approach.

An optional approach is to implement a golang integration leveraging the `ROSA cli` codebase (Golang).
Then the whole cluster's lifecycle would be managed by App-interface. This is desirable but should not
be prioritized and the creation is covered with `ROSA cli`.

## Changes needed to support ROSA in App-Interface

### Schema changes

The cluster spec needs updates to allow `ROSA` clusters.

- Add a `product` attribute to identify the cluster type.
    `product` is already part of `OCM` api spec and it identifies the openshift cluster type. This
    attribute will be added to our cluster spec with the same objective. This attribute will be
    backfilled from `OCM` to app-interface if is missing in the spec.

- Change cluster type to an interface type.
    As `OCM` supports varios types of clusters, it's worth changing the cluster spec to an interface and
    create an implementation for each supported type (OSD, ROSA, Hypershift?). The `product` attribute will
    be used to identify the cluster implementation to use.

### OCM code changes

Our OCM code is very tight to OSD-type clusters. Some changes are needed:

- Getting the clusters spec: Our current approach takes `OSD` related fields as mandatory but those are
  not set in `ROSA` or other types.

- Cluster Updates: Some updates that do not apply on `ROSA` such as quotas or making the cluster private.

- Cluster Creation: `OSD` clusters are created through `OCM` while `ROSA` are created with `ROSA cli` and
  is the supported way.

- AWSInfrastructureAccess: `ROSA` does not have this option through `OCM` because the aws account is
  fully managed by the customer.

The `OCM` code needs a refactor to allow different cluster types. At first, using an interface instead of
a single cluster type is the appropiate way to manage this. One cluster implementation will be created for
each type of cluster we need to support and each cluster could have a completely different implementation.

The code changes to do this seems located in the `ocm.py` file, the integrations get the `ocm` reference from
the `OCM_Map` class. This needs a more deep view but at first, seems that with the clusters' initialization
an additional object could be set to add the product implementation object.

Kafka clusters are a good candidate for an additional cluster type, right now they are managed separately with
its own integration and schema. But in the end, they are an additional cluster type and from a model point of
view, it would be more precise to manage them as clusters and let the implementation do the required steps.

About the AWSInfrastructureAccess, as the accounts are managed by us, we could mimic how we are managing
`OSD` aws accounts. Creating both `read-only` and `network-mgmt` roles in the destination account and adding
the IAM policies when new accesses need to be granted. This logic will need to be created with `AWScli`
instead of `OCM`. Following this path, all terraform integrations that use the role assumptions will still
work the same way as of now.

### Alternatives considered

#### Conditional branching

A possible way is to branch the code with if/else and manage `ROSA` clusters with additional paths. I consider this
a bad design as all the code would need to be modified if a new cluster type needs to be supported in the future.
On the contrary, adding separate implementations leads to a clean approach and adds maintainability to the code.

#### Separate integration

Such as kafka clusters, managing `ROSA` with an additional integration and adding additional methods its a viable way.
I think it's better for the sake of code comprehension, maintainability and coherence to just have different types
under the cluster meta type with its separate implementations. Following this path would end up messing a log the ocm
code as we need OCM for only certain parts of the `ROSA` administration.

### Changes list summary

- Change `cluster` schema to an interface. Each cluster type will be identified by the `product` attribute.
  Each cluster definition will only have its necessary attributes.
- Update `ocm` code to manage different cluster implementations (OSD and ROSA)
- Implement `AWS` STS roles management for `ROSA` cluster accounts with the `AWS api`
- Update SOPS to include `ROSA` type clusters onboarding to app-interface
- Implement a new integration to leverage `ROSA cli` codebase with a golang operator to manage ROSA
  cluster creation. **This can be worked on in parallel as we can onboard clusters created by `ROSA cli`.**
- Create an additional account to host AppSRE `ROSA` clusters

### Future work

- Addapt Kafka clusters to a Cluster implementation

### Resources

- [OCM API Spec](https://api.openshift.com/#/default/get_api_clusters_mgmt_v1_clusters)
