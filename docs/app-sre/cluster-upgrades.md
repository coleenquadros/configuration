# Cluster upgrades

The AppSRE clusters are automatically upgraded by an integration called `ocm-upgrade-scheduler`.

This document explains how the integration decides to upgrade a cluster.

Jira ticket: https://issues.redhat.com/browse/SDE-1376

## Overview

To enable upgrades for a cluster, add an `upgradePolicy` section to the cluster file:
```yaml
upgradePolicy:
  # types of workloads running on this cluster
  workloads:
  - workload1
  - workload2
  # cron expression to determine when upgrades should be scheduled
  schedule: 0 12 * * 1-5
  # conditions to decide if upgrade should be scheduled
  conditions:
    # number of days this version has been running in clusters with the same workloads
    soakDays: 0
```

## How it works

For each cluster with an `upgradePolicy`, we check that the following conditions are met:
- the cluster has no current upgrade pending.
- there are available versions to upgrade to.
- the upgrade schedule is within the next 2 hours.
- the version has been soaking in other clusters with the same workloads (more than `soakDays`).

The versions to upgrade to are iterated over in reverse order, so it is assumed that the latest version that meets the conditions is chosen.

## Version history

Information on how long a version has been running in our clusters can be found in the `version-history` app-interface-output page: https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/version-history.md

This page can be used to debug why certain upgrades are scheduled or not or to help with providing a signal for pre-release OCP versions.

## Block upgrades to versions

In order to block upgrades to specific versions, follow these steps:

1. Disable `ocm-upgrade-scheduler` in [Unleash](https://app-interface.unleash.devshift.net) to prevent any new upgrades to this version from being scheduled.
1. Add the version to the `blockedVersions` list in the OCM instance file.

Notes:

- Regex expressions are supported.
- These steps will also cause existing upgrades to be cancelled if time allows.
- All AppSRE clusters are provisioned in the [OCM production instance](https://gitlab.cee.redhat.com/service/app-interface/-/blob/2860db033ff2cc88aadf6b655d8ced7ac66746d3/data/dependencies/ocm/production.yml#L18).
