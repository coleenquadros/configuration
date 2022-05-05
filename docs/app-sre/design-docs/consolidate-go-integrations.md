# Design doc: consolidate go integrations

## Author/date

Jan-Hendrik Boll / 2022-05

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-5489

## Problem Statement

Right now we have two integrations written in Go:

* https://github.com/app-sre/vault-manager 
* https://github.com/app-sre/user-validator 

These two share the same challenges, i.e. configuration, GraphQL queries, retries, vault-access, etc... However, they came up with different solutions for this.

This makes it hard to develop future integrations in Go, as it requires additional effort.


## Goals

Consolidate development of Go based integrations by providing capabilities required for all. Examples for these capabilities:

* GraphQL queries
* Configuration: cfg files, environment variables and command line options
* Vault access
* Unleash integration
* Sentry integration
* Structured logging
* Build infrastructure

Make managing dependencies as simple as possible

## Non-objectives


## Proposal

Move all Go based integrations into a single repository. The repository will not contain sub modules. A single artifact is produced, the integration running will depend on the command line parameters.
 
Repository layout:

* cmd: Contains CLI and integration bootstrapping related code
* internal/<integration_name>: Actual business logic of the concrete integration
* pkg: Shared capabilities, as per [golang-standards/project-layout](https://github.com/golang-standards/project-layout), this pkg could also be used outside this repository
  *  graphql
  *  unleash
  *  reconcile
  *  ...


## Alternatives considered

Creating a repository per integration makes managing the dependcies quite hard. It's not only the dependency from the Go Integration SDK, but also from the integrations towards qontract-schemas. Using a single repository also ensures integration will undergo maintenance and receive future refactorings in core components.


## Milestones

* Rename user-validator repository to go-reconcile
* Create end to end tests for vault-manager, based on container images
* Refactor vault-manager into go-reconcile