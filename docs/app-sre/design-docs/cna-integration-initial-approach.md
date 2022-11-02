# Design document - First qontract-reconcile integration for CNA

## Author / Date

Karl Fischer
November 2022

## Problem statement

Cloud Native Assets (CNA) is an API to ease provisioning of cloud assets such as RDS databases from within the Openshift Cluster Manager (OCM) ecosystem.
app-interface is a declarative DSL to describe desired state of infrastructure, without the need to imperatively define the order or kind of operation required to reach that state.
This design-doc lists requirements towards our first qontract-reconcile (QR) to be able to properly integrate with CNA from app-interface perspective.

## Goals

Concept to consume CNA with app-interface workflow

## Proposal

In order to solve some missing features of CNA, we must implement the concept of state on the client side.
State can be used to calculate differences between real-world state and desired app-interface defined state.
Those differences can then be used to implement dry-run and life-cycle management on the client side.

### Life-cycle Management

As of now CNA does not offer a mechanism for life-cycle management of assets. It must be implemented on the client-side.

#### Decommissioning

First, we declare a new asset.

```yaml
cna_assets:
- provider: null-asset
  identifier: my-first-asset
  addr_block: 127.0.0.1/32
```

We expect app-interface to create `my-first-asset`
Next, we remove the above asset:

```yaml
cna_assets: []
```

We expect app-interface to delete `my-first-asset`.
Due to lack of life-cycle management, we need to implement the decommissioning tracking on the client side for now.

#### Patching / Creating

First, we declare a new asset.

```yaml
cna_assets:
- provider: null-asset
  identifier: my-first-asset
  addr_block: 127.0.0.1/32
```

We expect app-interface to create `my-first-asset`.
Next, we want to update that asset

```yaml
cna_assets:
- provider: null-asset
  identifier: my-first-asset
  addr_block: 192.168.178.1/32
```

We expect app-interface to update the already existing asset `my-first-asset`.
app-interface does not know the internal CNA uuid of the already existing asset.
I.e., the client must distinguish between sending either a create (POST)
or update (PATCH) request.

### Dry-run

CNA does not provide a dry-run option. app-interface heavily relies on a dry-run
mechanism in order to evaluate if a change can be considered safe.

### Dependency Management

TODO
