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

Create an integration to replicate the content of one or multiple app-role policies between different Vault instances.

## Non-objectives

## Proposal

Enhance the AWS account file schema with a new section called `replication`. This section will be placed in the target Vault instance and will define the source for the replication and which contents should be copied using a approle polices list.

```yaml
---
$schema: /vault-config/instance-1.yml

labels:
  service: vault.devshift.net

name: "vault-ext-devshift-net"
description: "Secondary ci-ext App SRE Vault instance"

address: "https://vault.ext.devshift.net"

replication:
- instance:
    $ref: /services/vault.devshift.net/config/instances/devshift-net.yml
  policies:
  - $ref: /services/vault.devshift.net/config/policies/app-sre-ci-ext-approle-policy.yml
```

This schema change will be picked up by an integration responsible for replicating the content between the two Vault instances.

We will use part of the existing vault implementation adding the capabilites to list secrets from a given path in order to replicate the contents between two different instances.

## Alternatives considered

- VPC Peerings between ci-ext and appsrep05ue1
- Removing ci-ext completely

## Milestones

Make it work.
