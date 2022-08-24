# Design doc: Vault replica integration

## Author/date

Andreu Gallofré / 2022-08-16

## Tracking JIRA

[Design doc tracking](https://issues.redhat.com/browse/APPSRE-6130)
[Implementation tracking ticket](https://issues.redhat.com/browse/APPSRE-6137)

## Problem Statement

This work is a part of [Vault migration inside the VPN](https://issues.redhat.com/browse/APPSRE-4791).

Part of the effort of moving Vault inside the VPN includes mantain the access to Vault from the current systems that acessing Vault, including ci-ext.

To accomplish that, initially we thought about setting a peering between appsrep05ue1 cluster and ci-ext VPC, with that we allow communication between the two systems, but in a later assestment we found that exposing the internal VPN to internet was not a good option.

The idea to mantain the access between ci-ext and the vault secrets needed is to have a "small" Vault instance outside the VPN where the secrets needed by ci-ext will be replicated automatically via an integration.

## Goals

Create an integration to replicate the content from a vault instance to another one, implementing a provider for jenkins, that will copy all secrets needed by a given Jenkins instance.

## Non-objectives

## Proposal

Enhance the Vault instance file schema with a new section called `replication`. This section will be placed in the source Vault instance and will define the provider and the target for the replication and which contents should be copied.

For this specific use case, we will implement the base of the integration and using the [provider pattern](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-interface/qontract-reconcile-patterns.md#the-provider-pattern) Jenkins Provider, that will replicate all secrets needed by an specific instance of Jenkins that match a given policy paths.

```yaml
---
$schema: /vault-config/instance-1.yml

labels:
  service: vault.devshift.net

name: "vault-devshift-net"
description: "App SRE Vault instance"

address: "https://vault.devshift.net"

replication:
- instance:
    $ref: /services/vault.devshift.net/config/instances/secondary-ext-vault.yml
  paths:
  - provider: jenkins
    instance:
      $ref: /dependencies/ci-ext/ci-ext.yml
    policy:
      $ref: /services/vault.devshift.net/config/policies/app-sre-ci-ext-approle-policy.yml
```

This schema change will be picked up by an integration responsible for extracting the list of secrets that needs to be replicated from the Jenkins job deifintions, and replicating the content between the two Vault instances.

As we will have the complete list of secrets, for now we won't be needing any changes on the current vault client implementation.

## Future implementations

As part of future use cases for this integration, it can be extended to replicate entire approle policy secrets using the provider pattern. The schema will be something similar to:

```yaml
replication:
- instance:
    $ref: /services/vault.devshift.net/config/instances/secondary-ext-vault.yml
  paths:
  - provider: jenkins
    instance:
      $ref: /dependencies/ci-ext/ci-ext.yml
  - provider: policy
      $ref: /services/vault.devshift.net/config/policies/app-sre-ci-ext-approle-policy.yml
```
## Alternatives considered

- VPC Peerings between ci-ext and appsrep05ue1
- Removing ci-ext completely

## Milestones

Make it work.
