# Design document - Cloud Native Assets (CNA) Integration

## Author / Date

Karl Fischer
November 2022

## Problem statement

Cloud Native Assets (CNA) is an API to ease provisioning of cloud assets such as RDS databases from within the Openshift Cluster Manager (OCM) ecosystem.
Apart from creating the assets, CNA also takes care of establishing connectivity dependencies such as required VPC peerings between cluster and RDS instance.
Also, CNA will push the assets output into the namespace as a secret. This concept is called **binding** an asset to a namespace.
app-interface is a declarative DSL to describe desired state of infrastructure, without the need to imperatively define the order or kind of operation required to reach that state.
This design-doc lists requirements towards our first qontract-reconcile (QR) to be able to properly integrate with CNA from app-interface perspective.

## Goals

A new integration that consumes CNA in app-interface

## Proposal

### Schema Details

The CNA integration uses `ExternalResources` like `terraform-resources` or `terraform-cloudflare-resources` do.

#### Namespace

The namespace is the place in which we define CN assets within an `externalResources` block.

**namespace.yml:**

```yaml
externalResources:
- provider: cna-experimental
  provisioner:
    $ref: /cna/app-sre.yml
  resources:
  - provider: aws-rds
    identifier: kfischer-test-11
    overrides:
      engine_version: "13.4"
    defaults:
      $ref: /aws/ter-int-dev/cna/aws-rds-postgres.yml
```

#### Provisioner

A provisioner is defining a CNA API endpoint.

**provisioner.yaml**

```yaml
---
$schema: /cna/experimental-provisioner-1.yml

name: app-sre
description: CNA API access for app-sre

ocm:
  $ref: /dependencies/ocm/stage.yml
```

Currently, the provisioner is merely a wrapper around an OCM object. However,
CNA is in an early stage and it is not absolutely clear yet how the API will
be exposed in the future. Using a custom object around OCM gives us more freedom
for changes later on.

Further, it could be used to implement sharding once https://issues.redhat.com/browse/OSDEV-887 is completed.

#### Defaults

Unlike other integrations, we define a concrete schema for every asset's defaults file.
CNA does not have any parameter validation, i.e., we need a concrete schema to catch
bad parameters on client side for now.

**defaults.yml:**

```yaml
$schema: /cna/aws-rds-config-1.yml
engine: postgres
username: postgres
instance_class: db.t3.small
engine_version: '11.13'
backup_retention_period: 7
db_subnet_group_name: default
allocated_storage: 20
max_allocated_storage: 100
multi_az: false
vpc:
  $ref: /aws/ter-int-dev/vpcs/ter-int-dev-default-vpc.yml
```

Further, this approach allows crossrefs, like the vpc pointer above.

Like other integrations, every asset offers an `overrides` section to override values from the defaults file.
The `overrides` section does not have a strict GQL schema. However, the integration validates that parameters
mentioned in the `overrides` section are compliant to the defaults file schema.
Further, the `overrides` section has a jsonpath schema, which will show errors during bundling phase.

### Non-Schema Implementation Details

CNA is imperative, i.e., the order of API calls is important. This knowledge must be coded in the integration,
to keep app-interface declarative.

In order to make CNA compliant with the app-interface way, we must also implement the concept of state on the client side.
Lucky for us, the CNA API can be used to fetch the real-world state.
State can be used to calculate differences between real-world state and desired app-interface defined state.
Those differences can then be used to implement dry-run and life-cycle management on the client side.

#### Life-cycle Management

As of now the [CNA API](https://gitlab.cee.redhat.com/service/cna-management/-/blob/main/openapi/openapi.yaml#/) does not offer a mechanism for **declarative** life-cycle management of assets. It must be implemented on the client-side.
In the following we explain what we mean with declarative life-cycle management.

##### Decommissioning

First, we declare a new asset.

```yaml
externalResources:
- provider: cna-experimental
  provisioner:
    $ref: /cna/app-sre.yml
  resources:
  - provider: null-asset
    identifier: my-first-asset
    addr_block: 127.0.0.1/32
```

We expect app-interface to create `my-first-asset`
Next, we remove the above asset:

```yaml
externalResources:
- provider: cna-experimental
  provisioner:
    $ref: /cna/app-sre.yml
  resources: []
```

We expect app-interface to delete `my-first-asset`.
Due to lack of declarative life-cycle management, we need to implement the decommissioning tracking on the client side for now.

##### Patching / Creating

First, we declare a new asset.

```yaml
externalResources:
- provider: cna-experimental
  provisioner:
    $ref: /cna/app-sre.yml
  resources:
  - provider: null-asset
    identifier: my-first-asset
    addr_block: 127.0.0.1/32
```

We expect app-interface to create `my-first-asset`.
Next, we want to update that asset

```yaml
externalResources:
- provider: cna-experimental
  provisioner:
    $ref: /cna/app-sre.yml
  resources:
  - provider: null-asset
    identifier: my-first-asset
    addr_block: 192.168.178.1/32
```

We expect app-interface to update the already existing asset `my-first-asset`.
CNA currently has a different API call for creating and patching assets, so
the integration must be able to distinguish it.

#### Dry-run

CNA does not provide a dry-run option. app-interface heavily relies on a dry-run
mechanism in order to evaluate if a change can be considered safe.
For that reason, we implement the concept of state on the client side, to compare
current and desired state.

#### Fetching CNA current state

CNA offers API calls to fetch information about assets. In order to get the full picture of
what is already provisioned, we need to query all the assets including their bindings.
This requires one API call to query the assets + one API call per asset to retrieve all bindings.
I.e., the amount of calls required to fetch current state is linear to the amount of assets.
This is a scaling issue.

