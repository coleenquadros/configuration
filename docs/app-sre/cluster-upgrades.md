# Cluster upgrades

The AppSRE clusters are automatically upgraded by an integration called `ocm-upgrade-scheduler`.

This document explains how the integration decides to upgrade a cluster.

Jira ticket: https://issues.redhat.com/browse/SDE-1376

## Overview



## Block upgrades to versions

In order to block upgrades to specific versions, follow these steps:

1. Disable `ocm-upgrade-scheduler` in [Unleash](https://app-interface.unleash.devshift.net) to prevent any new upgrades to this version from being scheduled.
1. Add the version to the `blockedVersions` list in the OCM instance file.

Notes:

- Regex expressions are supported.
- All AppSRE clusters are provisioned in the [OCM production instance](https://gitlab.cee.redhat.com/service/app-interface/-/blob/2860db033ff2cc88aadf6b655d8ced7ac66746d3/data/dependencies/ocm/production.yml#L18).
