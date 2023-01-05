# Design doc: AWS resource sharing

## Author/date

Maor Friedman / 2023-01-05

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-6756

## Problem Statement

To assist in increasing HyperShift development velocity, we want to trigger OCM API tests (implemented as jobs in Jenkins) following an ACM Addon upgrade.

## Goals

Automatically trigger tests upon a complete upgrade of the ACM Addon.

## Non-objectives

- Migrate OCM to use [Continuous Testing in App-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-testing-in-app-interface.md)

## Proposal

The condition to trigger the tests in that all Service/Management clusters in an environment (integration / stage) have been upgraded to a new ACM Addon version. All such clusters are within a single OCM organization.

Once all clusters within an OCM organization have been upgraded, we should trigger a specified job in Jenkins.

The proposed schema to support this effort is: https://github.com/app-sre/qontract-schemas/pull/363

In this schema we define an Addon, a Jenkins instance and a job name. Whenever this Addon gets upgraded (compared to a last known version) - we should trigger the specified job.

The implementation would be a qontract-reconcile integration. The proposal is: https://github.com/app-sre/qontract-reconcile/pull/3099

## Alternatives considered

1. Use a Jenkins job to poll OCM and trigger the job instead of an integration. Since we want to progress quickly, and composing such a job is likely quite messy:
  - last known version == state mamangement
  - OCM polling == credentials management, OCM cli container pre-built

## Milestones

Make it work.

## Disclaimer

The OCM organization files for [osd-fleet-manager](/data/dependencies/ocm/osd-fleet-manager) are already used for cluster upgrades. This data does not naturally belong to app-interface, since the integrations running in this context are not directly related to services run by AppSRE.

Although we are continuting to add more data which is not a natural fit, HyperShift is a priority and we will find time in the future to repay this "technical debt" (this may be related to "Capabilities").
