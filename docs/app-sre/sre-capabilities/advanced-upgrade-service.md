# Declare Advanced Upgrade Service for SRE capabilities users

[TOC]

## Motivation

AppSRE manages a fleet of clusters with various workloads and various constraints on how these clusters continously receive Openshift updates. Years of experience, high automation and strong tooling allowed AppSRE to turn cluster upgrades into a no-toil process.

The Advanced Upgrade Service (AUS) SRE capability provides the same powerful policy based  upgrade experience for any cluster in <https://console.redhat.com/openshift>

## Requirements engineering

Before an upgrade policy can be defined, the requirements and constraints for cluster upgrades need to be elaborated with the tenant. Since AppSRE is going to create the policy in `app-interface` in most cases (see [Support model](#support-model)), proper discussion about the update requirements is crucial.

## Defining a policy

Extensive documentation about how policies work and how they can be defined, can be found in the [Cluster Upgrades](/docs/app-sre/cluster-upgrades.md) docs.

## Support model

### Reaching support

A request for policy setup or change needs to be files on the [AppSRE Jira Board](https://issues.redhat.com/projects/APPSRE). Also any other technical assistance for AUS needs to be requested by filing a ticket.

### AUS responsibilities

AUS *is responsible* to schedule cluster upgrades via OCM based on the defined policies.

AUS *is not responsible* for the success or failure of an upgrade.

AUS *is not responsible* for pre- or post upgrade cluster inspection. AUS uses the OCM semantics for upgradability and upgrade success/failure but does not connect to any clusters (nor is it having access credentials or a network path to do so).

### Escalations

For all support cases where AUS and AppSRE are not responsible, support is delegated as follows:

* Upgrade has been scheduled for a cluster but is not starting - reach out to [OCM Support](https://red.ht/ocm-support)
* Cluster upgrade is failing - reach out to [OHSS support](https://red.ht/ohss-incident)

### AUS Service Level Objectives

| Service Level Indicator (SLI)                            | SLO Time    |
|----------------------------------------------------------|-------------|
| AppSRE Jira ticket response                              | 24 BH       |
| Service degradation                                      | 24 BH       |

SLO times above are measured as the mean time to first response/action.
