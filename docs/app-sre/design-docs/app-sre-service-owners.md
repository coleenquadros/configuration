# Design doc: optimal location for app-interface schemas

## Author/date

Maor Friedman / 2022-04-05

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4805

## Problem Statement

The AppSRE team self-manages some services as part of the AppSRE offering. These services may get "neglected" over time and require maintenance (version upgrades, documentation, etc).

## Goals

The services AppSRE owns should be properly maintained.

## Non-objectives

Define service owners for qontract-reconcile / app-interface. This will remain the responsibility of the entire team.

## Proposal

Assign AppSRE streams as owners of services we own. Each stream owning a service will be responsible for the maintenance of that service.

The entire team will still be responsible for handling the day-to-day activities around that service, but the more involved parts will be owned by the responsible stream.

Some examples for what a stream is responsible for:
- Service upgrades
- Documentation updates
- Security updates

Some examples for what a stream is NOT responsible for:
- Debugging issues with the service (as part of IC for example)

The responsible stream, from the time of assignment, will be considered the service owners, just like we consider our tenants to be service owners of their own services.

The services we need to define ownership for:
1. Container Security Operator
1. Dashdot.DB
1. Deployment Validation Operator
1. Gabi
1. Github Mirror
1. Observability
1. OCM Quay
1. Rate Limiting
1. Unleash
1. Vault
