<!-- TOC -->

- [Provisioning the OSD clusters](#provisioning-the-osd-clusters)
- [Cluster VPC peerings](#cluster-vpc-peerings)
  - [ACM communication](#acm-communication)
  - [Bastion access](#bastion-access)
  - [app-interface managability](#app-interface-managability)
  - [Communication with Cluster Service](#communication-with-cluster-service)
- [Hypershift service cluster configuration](#hypershift-service-cluster-configuration)
  - [Cluster groups](#cluster-groups)
  - [Environment file](#environment-file)
  - [open-cluster-management](#open-cluster-management)
  - [ocm](#ocm)
  - [multicluster-engine](#multicluster-engine)
- [Hypershift management cluster configuration](#hypershift-management-cluster-configuration)
  - [Cluster groups](#cluster-groups-1)
  - [Environment file](#environment-file-1)
  - [Hypershift operator](#hypershift-operator)
- [Hypershift service cluster registration with OCM Cluster Service](#hypershift-service-cluster-registration-with-ocm-cluster-service)
- [Hypershift management cluster registration with service cluster](#hypershift-management-cluster-registration-with-service-cluster)

<!-- /TOC -->

This SOP serves as a step-by-step process on how to provision Hypershift from zero (no cluster) to a fully functioning Hypershift management cluster and Hypershift service cluster.


# Provisioning the OSD clusters

This section is about to provision the OSD cluters for Hypershift management and service clusters.

Follow the standard [Cluster Onboarding SOP](app-interface-onboard-cluster.md) using the following specs
   *Note*: some of these numbers need to be reviewed in the light of first hypershift usage (storage, load balancers, compute type .. )

    |                           | Staging       | Production    |
    |---------------------------|---------------|---------------|
    | Availability              | Multizone     | Multizone     |
    | Compute type              | m5.xlarge     | m5.xlarge     |
    | Compute count (autoscale) | 9 - 12        | 9 - 27        |
    | Persistent storage        | 1600 GB       | 1600 GB       |
    | Load balancers            | 12            | 12            |
    | UpgradePolicy wokloads    | hypershift    | hypershift    |
    | **Network type**          | OVNKubernetes | OVNKubernetes |
    | Machine CIDR              | See note      | See note      |
    | Private                   | true          | true          |
    | Internal                  | false         | false         |
    | VPC peerings              | see "Cluster VPC peerings" section |

# Cluster VPC peerings

This section is about creating the respective peerings so the Hypershift management and service cluster can communicate with each other. This also involves creating VPC peerings to other clusters running services that need to communicate with the service cluster, e.g. OCM Cluster Service

## ACM communication

ACM on the Hypershift service cluster must communicate with the API server of the Hypershift management clusters. Therefore create a cluster VPC peering between both.

## Bastion access

Both service and management clusters are currently private clusters, so in order to provide access via the bastion host (for AppSRE and the OCM dev team), add a `account-vpc` peering to the `/aws/app-sre/vpcs/app-sre-vpc-02-ci-ext.yml` VPC.

## app-interface managability

To make bother clusters managable via app-interface, add cluster VPC peerings to `/openshift/app-sre-prod-01/cluster.yml` and `/openshift/appsrep05ue1/cluster.yml`.

## Communication with Cluster Service

Cluster service needs to talk to the API server of the Hypershift service cluster, so create a cluster VPC peering with the cluster where Cluster Service is running, e.g. UHC integration runs on `/openshift/app-sre-stage-01/cluster.yml`

# Hypershift service cluster configuration

This section describes how to deploy components and configuration to an OSD cluster to make it a Hypershift service cluster. It also covers how such a service cluster is registered with OCM Cluster Service.

## Cluster groups

For non-production clusters, add the `dedicated-readers` and `ocm-developers` groups to the `managedGroups` list of the `cluster.yml` and update `data/teams/hypershift/roles/hypershift-dedicated-readers.yml` and `data/teams/ocm/roles/dev.yml` with a reference to the service cluster.

See the "Hypershift service cluster configuration > Hypershift service cluster registration with OCM Cluster Service" section for more information about the `ocm-developers` group.

## Environment file

Create an environment file at `data/products/hypershift/environments/$environment-$cluster.yml`, e.g. as defined in `data/products/hypershift/environments/integration-hsservicei01ue1.yml`

## open-cluster-management

This is about the installation of the ACM (Advanced Cluster Management) leveraging OLM.

Create a namespace in `data/services/hypershift/namespaces/$clustrer/open-cluster-management.yml`, e.g. as defined in `data/services/hypershift/namespaces/hsservicei01ue1/open-cluster-management.yml`. This prepares the namespace with required network policies and pull secrets for ACM upstream/downstream images from quay.io

TODO deploy ACM via SAAS file

## ocm

This is about providing access to OCM Cluster Service via the service account defined in `/services/hypershift/hypershift-ocm-bot.serviceaccount.yaml`.
todo: where come the permissions from?

Additionally this namespace holds `PlacementDecision` (an ACM CR) information to enable CS to decide what management clusters to place a `HostedCluster` on.

Create a namespace in `data/services/hypershift/namespaces/$cluster/ocm.yml`, e.g. as defined in `data/services/hypershift/namespaces/hsservicei01ue1/ocm.yml`.

## multicluster-engine

This namespace is holding the ACM Multicluster Engine (MCE) and the Hypershift Deployment Controller. Those components know how to create `HostedClusters` on Hypershift management clusters based on `HypershiftDeployment` CRs created by OCM Cluster Service.

This namespace also owns the S3 bucket used for OIDC. Right now this S3 bucket is shared by all Hypershift management clusers (the Hypershift operator running on them to be specific).

To create the namespace and the S3 bucket, create a file in `data/services/hypershift/namespaces/$cluster/multicluster-engine.yml`, e.g. as defined here `data/services/hypershift/namespaces/hsservicei01ue1/multicluster-engine.yml`. Make sure to name define the S3 bucket name and region as required.

Please note: the S3 access information will be available in Vault under XXX which will be necessary to know when configuring the Hypershift management cluster.

# Hypershift management cluster configuration

This section describes how to deploy components and configurations to an OSD cluster to make it a Hypershift management cluster.

## Cluster groups

For non-production clusters, add the `dedicated-readers` groups to the `managedGroups` list of the `cluster.yml` and update `data/teams/hypershift/roles/hypershift-dedicated-readers.yml` with a reference to the service cluster.

## Environment file

Create an environment file at `data/products/hypershift/environments/$environment-$cluster.yml`, e.g. as defined in `data/products/hypershift/environments/integration-hshifti01ue1.yml`

## Hypershift operator

The Hypershift operator is the work horse creating hosted control planes running as pods on management clusters out of `HostedClustger` CRs, including also worker nodes in another AWS account based on `NodePool` CRs.

Create a namespace for the hypershift operator in `data/services/hypershift/namespaces/$cluster/hypershift.yml`, e.g. as defined in `data/services/hypershift/namespaces/hshifti01ue1/hypershift.yml`

To deploy the operator to the freshly created namespace, register a new SAAS deployment target in `data/services/hypershift/cicd/saas-hypershift.yml`.

Make sure to reference the correct secrets for `OIDC_S3_NAME` and `OIDC_S3_REGION`, belonging to the Hypershift service cluster this management cluster is registered with.

# Hypershift service cluster registration with OCM Cluster Service

OCM CS needs a namespace to drive leadership election for its internal components on each provisioning shard. A Hypershift service cluster is also considered a provisioning shard. Define a namespace in `data/services/ocm/namespaces/v4/uhc-leadership-$environment-$servicecluster.yml`, e.g. as defined in `data/services/ocm/namespaces/v4/uhc-leadership-integration-hsservicei01ue1.yml`.

The service account provided in the provisioning shard secrets gets its permissions from a template in https://gitlab.cee.redhat.com/service/uhc-clusters-service/-/blob/master/hypershift-permissions-template.yaml that defines a `ClusterRole ocm`. This template is deployed via the saas file `data/services/ocm/cs/cicd/saas-uhc-hypershift-permissions.yml`, so add a new Hypershift servicecluster as a deploy target to that file.

Note: the `ClusterRole ocm` is also granted to the `Group ocm-developers` which is populated with the OCM dev team on non-production clusters only.

To make the Hypershift service cluster known to CS, it needs to be listed in the provisioning-shards secret of a CS environment, e.g. for the integration environment see the `hypershift_shards` section in `data/services/ocm/namespaces/uhc-integration.yml`. This will make the the service cluster known and provides the service account token of the `ocm` SA from the `ocm` namespace to CS.

Note: the `id` of a shard is a randomly generated UUID.

Details: https://issues.redhat.com/browse/APPSRE-4304

# Hypershift management cluster registration with service cluster

This section is about registering a Hypershift management cluster with the service cluster.

To register a Hypershift management cluster, a namespace named after the management cluster is created on the service cluster. Also a `ManagedCluster` CR (belongs to ACM) is created to make the management cluster known to ACM on the service cluster. ACM also needs to get a cluster-admin token for the management cluster to finish the registration process (which includes installing some components there, e.g. manifest-work controller, klusterlet, policy controllers, ...). This access information is placed by `resources/services/hypershift/cluster-registration/cluster-auto-import-secret.yaml` and registration is kicked of by a `Job` defined here `/services/hypershift/shared-resources/acm-cluster-registration-job.yml`

Create a namespace in `data/services/hypershift/namespaces/$service_cluster/$management_cluster.yml`, e.g. as defined in `data/services/hypershift/namespaces/hsservicei01ue1/hshifti01ue1.yml`. Make sure to correctly set the management cluster name for `openshiftResources.variables.cluster`.
