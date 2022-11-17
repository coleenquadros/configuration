# ROSA Clusters

[TOC]

## Overview

This document describes the `App-Interface` approach to Openshift `ROSA` clusters. `ROSA` clusters
use the CCS (Customer Cloud Subscription) deployment model which means that the clusters' infrastructure
is deployed into an `AWS` account owned by `App-Sre` (the customer).

`ROSA` also supports the concept of `hosted control plane` clusters (Hypershift). The main difference from
the base `ROSA` clusters is that the control plane is not deployed in the customer's account, but it is
hosted by RedHat. Check the `Hypershift` documentation for more details.

As per now, there are slightly differences when provisioning `Hosted-cp` clusters that will be described along
the sections of this document.

## ROSA Installation overview

`ROSA CLI` is the main tool to provision and manage `ROSA` clusters. This tool interacts with the target AWS
account and with the OCM ClustersService API to provision the clusters.

With `App-Interface` the account configuration is made with `ROSA CLI` but the cluster creation is requested
directly to the OCM API using the `ocm-clusters` integration.

Steps to provision a `ROSA`cluster:

- **Configure the AWS Account:** The target AWS account needs some configuration before hosting the clusters.
  `ROSA CLI` does all the required steps to configure the account. Basically, the configuration consists in a
  quota and service control policies verification and a creation of a set of IAM roles used by OCM to interact
  with the account. This step is required only once per account, then multiple clusters can be created in the
  same account.

- **[Hosted-cp Only] Create a VPC in the account:** Base ROSA clusters installation can create the VPC automatically
  with the cluster's network spec. With hosted clusters, the VPC must be created before creating the cluster. There
  is a [Terraform module](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/terraform/modules/rosa-hosted-cp-vpc)
  in the infra repo to create the VPCs.

- **Create the Cluster**: Launch the cluster installation with the `ROSA CLI` or by using the `OCM ClustersService API`.
  Both ways register the cluster in the OCM organization and start the cluster installation. There are 2 steps required
  before OCM starts starts the installation process.

  - Create an OIDC provider for the STS/openshift authentication.
  - Create the cluster's RedHat operator IAM Roles. RedHat operator roles that will be used by RH to support the cluster.

  These 2 steps are done automatically by the installation if the `auto-mode` flag is used. It's explained here just for
  informative purposes.

  With App-interface, this step consists in defining the cluster manifest with the ROSA hosted-cp required attributes, just
  the same way the OSD clusters are created.

## AWS Account configuration

Before hosting `ROSA` clusters in an account, some configuration steps must be done.

### Enable the ROSA Service

Log in into the AWS account, go to the AWS Marketplace and enable the `ROSA` service. If you want to use the `OCM` staging
environment, the account uid must be set under an AWS whitelist managed by AWS. This is needed because the staging `ROSA` service
uses a different set of AMIS to deploy the clusters. Ask the `OCM` team in `#service-development` or `#sd-hypershift` if you need
this feature.

### Create the ELB service linked role

This step is needed if the account is new and no ELB has been created in it.

```aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"```

This service-linked-role is created automatically in `AWS` when the first elb is created. If the service linked role does not exist
in the account, the `OCM` API will return an error.

### Check the pre-requisites with the `ROSA CLI`

For this step you need the latest `ROSA CLI` available, it can be downloaded from the [Openshift ROSA support website](https://docs.openshift.com/rosa/rosa_cli/rosa-get-started-cli.html).

- Load the aws account profile with an IAM user access keys (terraform). STS credentials are not supported at the time of
  writing this doc.
- Log in to OCM with the `ROSA cli`. OCM organization credentials are required for this step (App-sre-ocm-bot)

```rosa login --client-id=.. --client-secret=...```

- [Optional] Check your connection data:

```bash
rosa whoami  --region us-east-1

AWS Account ID:               366871242094
AWS Default Region:           us-east-1
AWS ARN:                      arn:aws:iam::366871242094:user/terraform
OCM API:                      https://api.openshift.com
OCM Account ID:               1ZTXsejUlKITmOrQsXBYz1kgcp9
OCM Account Name:             App SRE OCM bot
OCM Account Username:         sd-app-sre-ocm-bot
OCM Account Email:            sd-app-sre+ocm@redhat.com
OCM Organization ID:          1OXqyqko0vmxpV9dmXe9oFypJIw
OCM Organization Name:        Red Hat
OCM Organization External ID: 12147054
```

- Run the `ROSA cli` init command to init the account.

```bash
rosa init

I: Logged in as 'sd-app-sre-ocm-bot' on 'https://api.openshift.com'
I: Validating AWS credentials...
I: AWS credentials are valid!
I: Verifying permissions for non-STS clusters
I: Validating SCP policies...
I: AWS SCP policies ok
I: Validating AWS quota...
I: AWS quota ok. If cluster installation fails, validate actual AWS resource ...
I: Ensuring cluster administrator user 'osdCcsAdmin'...
I: Admin user 'osdCcsAdmin' created successfully!
I: Validating SCP policies for 'osdCcsAdmin'...
I: AWS SCP policies ok
I: Validating cluster creation...
I: Cluster creation valid
I: Verifying whether OpenShift command-line tool is available...
I: Current OpenShift Client Version: 4.10.15
```

- Create the OCM Role. In this guide the role is set with admin permissions to let `OCM` create the required
  `AWS` components needed by the clusters. Add the `OCM` environment in the prefix, this will allow configure
  multiple OCM environments on the account.

```bash
rosa create ocm-role --admin

I: Creating ocm role
? Role prefix: ManagedOpenShift-OCM-Prod
? Permissions boundary ARN (optional):
? Role creation mode: auto
I: Creating role using 'arn:aws:iam::366871242094:user/terraform'
? Create the 'ManagedOpenShift-OCM-Prod-OCM-Role-12147054' role? Yes
I: Created role 'ManagedOpenShift-OCM-Role-12147054' with ARN 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-OCM-Role-12147054'
I: Linking OCM role
? OCM Role ARN: arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Role-12147054
? Link the 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-OCM-Role-12147054' role with organization '1OXqyqko0vmxpV9dmXe9oFypJIw'? Yes
I: Successfully linked role-arn 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-OCM-Role-12147054' with organization account '1OXqyqko0vmxpV9dmXe9oFypJIw'
```

- Create the account roles for ROSA STS clusters. Add the `OCM` prefix as in the last step.

```rosa create account-roles
I: Logged in as 'sd-app-sre-ocm-bot' on 'https://api.openshift.com'
I: Validating AWS credentials...
I: AWS credentials are valid!
I: Validating AWS quota...
I: AWS quota ok. If cluster installation fails, validate actual AWS resource usage against https://docs.openshift.com/rosa/rosa_getting_started/rosa-required-aws-service-quotas.html
I: Verifying whether OpenShift command-line tool is available...
I: Current OpenShift Client Version: 4.10.15
I: Creating account roles
? Role prefix: ManagedOpenShift-OCM-Prod
? Permissions boundary ARN (optional):
? Role creation mode: auto
I: Creating roles using 'arn:aws:iam::366871242094:user/terraform'
? Create the 'ManagedOpenShift-OCM-Prod-Installer-Role' role? Yes
I: Created role 'ManagedOpenShift-OCM-Prod-Installer-Role' with ARN 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-Installer-Role'
? Create the 'ManagedOpenShift-OCM-Prod-ControlPlane-Role' role? Yes
I: Created role 'ManagedOpenShift-OCM-Prod-ControlPlane-Role' with ARN 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-ControlPlane-Role'
? Create the 'ManagedOpenShift-OCM-Prod-Worker-Role' role? Yes
I: Created role 'ManagedOpenShift-OCM-Prod-Worker-Role' with ARN 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-Worker-Role'
? Create the 'ManagedOpenShift-OCM-Prod-Support-Role' role? Yes
I: Created role 'ManagedOpenShift-OCM-Prod-Support-Role' with ARN 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-Support-Role'
? Create the operator policies? Yes
I: Created policy with ARN 'arn:aws:iam::366871242094:policy/ManagedOpenShift-OCM-Prod-openshift-image-registry-installer-cloud-creden'
I: Created policy with ARN 'arn:aws:iam::366871242094:policy/ManagedOpenShift-OCM-Prod-openshift-ingress-operator-cloud-credentials'
I: Created policy with ARN 'arn:aws:iam::366871242094:policy/ManagedOpenShift-OCM-Prod-openshift-cluster-csi-drivers-ebs-cloud-credent'
I: Created policy with ARN 'arn:aws:iam::366871242094:policy/ManagedOpenShift-OCM-Prod-openshift-cloud-network-config-controller-cloud'
I: Created policy with ARN 'arn:aws:iam::366871242094:policy/ManagedOpenShift-OCM-Prod-openshift-machine-api-aws-cloud-credentials'
I: Created policy with ARN 'arn:aws:iam::366871242094:policy/ManagedOpenShift-OCM-Prod-openshift-cloud-credential-operator-cloud-crede'
```

- Create the User Role. The user role is used to allow the interaction with `OCM`. Add the `OCM` prefix as in the last step.

```bash
❯ rosa create user-role
I: Creating User role
? Role prefix: ManagedOpenShift-OCM-Prod
? Permissions boundary ARN (optional):
? Role creation mode: auto
I: Creating ocm user role using 'arn:aws:iam::366871242094:user/terraform'
? Create the 'ManagedOpenShift-OCM-Prod-User-sd-app-sre-ocm-bot-Role' role? Yes
I: Created role 'ManagedOpenShift-OCM-Prod-User-sd-app-sre-ocm-bot-Role' with ARN 'arn:aws:iam::366871242094:role/ManagedOpenShift-User-sd-app-sre-ocm-bot-Role'
I: Linking User role
? User Role ARN: arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-User-sd-app-sre-ocm-bot-Role
? Link the 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-User-sd-app-sre-ocm-bot-Role' role with account '1ZTXsejUlKITmOrQsXBYz1kgcp9'? Yes
I: Successfully linked role ARN 'arn:aws:iam::366871242094:role/ManagedOpenShift-OCM-Prod-User-sd-app-sre-ocm-bot-Role' with account '1ZTXsejUlKITmOrQsXBYz1kgcp9'
```

### Configure other OCM environments

If you want to use the `OCM` staging environment or other `OCM` environments you need to repeat the previous steps
but using a different `OCM` credentials. `ROSA` CLI uses the `OCM` credentials stored in `~/.config/ocm/<config>.json`.
Before creating the roles, just login with the `OCM` CLI in the environment you want to use with the `url` parameter.

```ocm login --client-secret="<secret>" --client-id=<id> --url=stage```

Once logged, do the previous steps but setting a different Prefix:

- Create the OCM role (OCM-Stage)
- Create the Account roles (OCM-Stage)
- Create the User account (OCM-Stage)

### Configure the IAM roles in the AWS account

Fill the `/dependencies/rosa-ocm-1.yml` schema under the app-interface's aws account and link it to the AWS account.
Check the [`app-sre-rosa` account](/data/aws/app-sre-rosa) for an example.

## Cluster Creation and and Management

### Create a new cluster

To install a cluster in app-interface just follow the [cluster onboarding SOP](/docs/app-sre/sop/app-interface-onboard-cluster.md). To request a `ROSA` cluster these
values must be used:

```yaml
# /data/openshift/<cluster_name>/cluster.yml
---
$schema: /openshift/cluster-1.yml

# [...]

# The OCM environment to deploy the cluster
ocm:
  $ref: /dependencies/ocm/production.ym
spec:
  product: rosa
  # The linked account must have a valid rosa configuration.
  account:
    $ref: /aws/app-sre-rosa/account.yml
  # If a hosted control plane cluster (hypersfhit) is required:
  hypershift: true
  # Subnet Ids of the VPC (public and private)
  subnet_ids:
    - subnet-0c3b7d88a0e54f859
    - subnet-0e2f0999d9c276e6f
  # Subnets' availability zones
  availability_zones:
    - us-west-2a
```

### Cluster configuration changes

Cluster configuration is a bit different than with `OSD`, for example, load balancers quota or storage
assignment do not apply to `ROSA` as all the components reside in the customer AWS account. The following list
enumerates the app-interface allowed cluster changes and if they are supported with `ROSA`.

- instance_type: This is supported in our ocm code but does not seem possible without creating a new machine pool
  as described [here](https://docs.openshift.com/dedicated/osd_cluster_create/creating-an-aws-cluster.html)
- storage (Quota): N/A. The customer account provides the storage.
- load_balancers (Quota): N/A. Load balancers are deployed in the customer account
- private: Not supported in ROSA. After cluster creation, a cluster can not be changed to private
- channel: Supported. Updates are managed through `OCM`. We will use our current updates system
- autoscale: Supported (OCM)
- nodes(nodeCount): Supported (OCM)
- machinePools: Supported (OCM)

**IMPORTANT**: All the cluster modifications are available through `OCM`. Not all the changes are yet available with `ROSA`
  hosted control plane.

### Cluster Roles

`ROSA` works the same way as `OSD`. `cluster-admin` and `dedicated-admin` exist in the cluster.

## Hypershift

### Enable the hypershift capability in the OCM organization

This step is required while Hypershift is not GA.

```bash
ORG_ID=1jZFKKYau9YS4ROF1LbtwwMdzHI

ocm post /api/accounts_mgmt/v1/organizations/$ORG_ID/labels <<.
  {
    "key": "capability.organization.hypershift",
    "value": "true",
    "internal": true
  }
.
```

### Get cluster credentials

Configuring an IDP and adding the users to the available admin roles is the recommended and expected procedure, but
admin credentials (kubeconfig) can be obtained from fleet manager:

```bash
CLUSTER_ID=<a_cluster_id>

ocm get /api/clusters_mgmt/v1/clusters/$CLUSTER_ID/credentials  | jq -r .kubeconfig
```

### Extending cluster expiration

Cluster deployed in `OCM` staging have a 2 days expiration. After the epiration time, the clusters will get deleted.
The expiration can be extended using `OCM`

```bash
# Max 168h (1 week)
ocm edit cluster --expiration 168h
```

### Getting organization / account labels

Some configuration is set in the `OCM` organization or account labels, like the sts_user_role or the `OCM` capabilities.
To query the labels:

```bash
ORG_ID=1QxuZ9DyDkGuTuijEXoncha6QTq

ocm get /api/accounts_mgmt/v1/organizations/$ORG_ID/labels
```
