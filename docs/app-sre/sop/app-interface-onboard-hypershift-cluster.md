<!-- TOC -->

- [Provisioning the cluster](#provisioning-the-cluster)
- [Hypershift deployment](#hypershift-deployment)
- [New Hypershift environment](#new-hypershift-environment)

<!-- /TOC -->

This SOP serves as a step-by-step process on how to provision Hypershift from zero (no cluster) to a fully functioning Hypershift management cluster


# Provisioning the cluster

1. Follow the standard [Cluster Onboarding SOP](app-interface-onboard-cluster.md) using the following specs
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
    | VPC peerings              | `ci-ext`, `appsrep05ue1`, `app-sre-prod-01`, service-cluster |

2. For stage `cluster.yml`, add `dedicated-readers` under `managedGroups` and update `data/teams/hypershift/roles/hypershift-dedicated-readers.yml` with a reference to our new cluster:
    ```yaml
    access:
    ...
    - cluster:
        $ref: /openshift/<cluster_name>/cluster.yml
    group: dedicated-readers
     ```

# Hypershift deployment

When a Hypershift management cluster is introduced to an existing environment (e.g. integration), follow these steps

1. Create an environment file (note: that is not the same as creating a new environment) at `data/products/hypershift/environments/$environment-$cluster.yml`

```yaml
---
$schema: /app-sre/environment-1.yml


labels:
  service: hypershift
  type: $environment

name: hypershift-$environment-$cluster

description: |
  The $environment environment for Hypershift

product:
  $ref: /products/hypershift/product.yml

```

Note: a new environment file is not the same as a new environment. multiple environment files can declare the same environment name.

2. Add a namespace to `data/services/hypershift/$cluster/hypershift.yml` to host the Hypershift operator.

```yaml
---
$schema: /openshift/namespace-1.yml

labels: {}

name: hypershift
description: $environment namespace for hypershift

cluster:
  $ref: /openshift/$cluster/cluster.yml

app:
  $ref: /services/hypershift/app.yml

environment:
  $ref: /products/hypershift/environments/$environment-$cluster.yml

managedResourceTypes:
- Secret

openshiftResources:
- provider: resource-template
  type: extracurlyjinja2
  path: /services/hypershift/$environment/oidc-s3-creds.yml

networkPoliciesAllow:
- $ref: /services/observability/namespaces/openshift-customer-monitoring.$cluster.yml

```

3. To deploy the operator to the namespace, register a new target in `data/services/hypershift/cicd/saas-hypershift.yml`.

4. TODO describe the `ServiceAccount` token registration via the provisioning-shard secret - https://issues.redhat.com/browse/APPSRE-4304

5. TODO describe how integration clusters should manage the special group for the OCM team - https://issues.redhat.com/browse/APPSRE-4335

# New Hypershift environment

When a new Hypershift environment is introduced (in the sense of `/app-sre/environment-1.yml#labels.type`), some additional steps are required. These evolve mostly around the creation of an S3 bucket and the resource to put the S3 access information to clusters.

Note: a single S3 bucket can serve multiple Hypershift operators, but we decided to introduce dedicated buckets per environment.

1. Create a namespace as described in the "Hypershift deployment" section but make sure to include also the declaration for the S3 bucket. The first cluster of an environment holds the bucket.

```yaml
managedTerraformResources: true

terraformResources:
- provider: s3
  account: app-sre
  identifier: hypershift-oidc-$environment
  region: us-east-1
  defaults: /terraform/resources/s3-public-read-1.yml
  output_resource_name: hypershift-oidc-s3-creds
```

Make sure the `openshiftResources` section is commented out for now, open an MR and make sure the bucket is created before you continue, otherwise certain integrations will fail.

2. Create resource file at `resources/services/hypershift/$environment/oidc-s3-creds.yml`. Use an example from another environment to get started but make sure to replace the mentioned cluster name in the vault secret references.

3. Remove the comments from the `openshiftResources` section of the namespace file

4. Continue on the step about saas file target from the "Hypershift deployment" section
