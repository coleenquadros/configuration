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

Secondary goal is to make managing dependencies between components as simple as possible.

## Non-objectives

* Designing specifics of SDK repository
* Advocate usage of Go for all future integrations, using Go should be for specific use cases only, examples for this:

  * Usage of go native libraries, example: vault, terraform or other
  * Usage of Go's coroutine approach

## Proposal

Move all Go based integrations into a single repository. The repository will not contain sub modules. A single artifact is produced, the integration running will depend on the command line parameters.
 
Repository layout:

* cmd: Contains CLI and integration bootstrapping related code
* internal/<integration_name>: Actual business logic of the concrete integration and it's unit tests
* tests/<integration_name>: Any fixtures or test related data
* openshift, build, hack...: Other build and deploy related directories

Create a second repository containing the SDK. It will contain shared capabilities in a folder called `pkg`, as per [golang-standards/project-layout](https://github.com/golang-standards/project-layout), this pkg could also be used outside this repository
* pkg
  *  graphql
  *  unleash
  *  reconcile
  *  ...

Code that is shareable between multiple integrations and is not related to bootstrapping the CLI should be contained in the SDK repository,

## Alternatives considered

Creating a repository per integration makes managing the dependcies quite hard. It's not only the dependency from the Go Integration SDK, but also from the integrations towards qontract-schemas. Using a single repository for all integrations also ensures integration will undergo maintenance and receive future refactorings in the SDK components.


## Milestones

* Rename user-validator repository to go-qontract-reconcile
* Refactor vault-manager into go-reconcile, requires update to go 1.17
* Move shared capabilities into seperate repository qr-sdk-go
