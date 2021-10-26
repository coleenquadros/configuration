# Design doc: optimal location for app-interface schemas

## Author/date

Maor Friedman / 2021-10-20

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-3946

## Problem Statement

Our schemas are currently located in the app-interface repo (schemas/, graphql-schemas/).

As new app-interface repositories pop up (dev environment, fedramp environment), we are realizing that the schemas are duplicated in every app-interface repository. schemas currently differ a bit between app-interface repos, mostly in enum values and required/optional values.

## Goals

The objective is to find a possible new location for the schemas, where we still gain the ease of development and maintenance work as we do now, while attempting to eliminate (or at least reduce) the duplication of schemas between different app-interface repos.

Another goal is to keep the development process of app-interface integrations almost as simple as it is today. Most importantly, we need to allow local development of schemas, data and logic in parallel.

## Non-objectives

* Automating the generation of the graphql schema based on the json schema ([APPSRE-155](https://issues.redhat.com/browse/APPSRE-155))
* Schema documentation and validation ([APPSRE-2694](https://issues.redhat.com/browse/APPSRE-2694), [APPSRE-3865](https://issues.redhat.com/browse/APPSRE-3865))
* Consolidate development documentation

## Proposal

Move schemas to a dedicated repository, qontract-schemas.

This repository will contain both schemas and graphql schemas and will be the single source of truth for all app-interface instances. On each merge to the repository, an image containing the schemas will be built and pushed.

The image may be public as long as we maintain an open source approach and not add any AppSRE specific enum values to it. A possible hurdle will be in keeping a single version of the schemas, as different app-interface repositories are in different phases, include different content and are running only some integrations. This means that we will likely find ourselves hardening our code where our schemas were protecting us until now.

This repository will be referenced from different app-interface repositories in the same way we reference qontract-server (`.env` file).

The bundling mechanism (`make bundle`) will need to be adjusted to first pull the schemas image and copy the directories locally. We will also need to adjust our development documentation to ease the transition of all team members and for new team members to come.

To allow local development, we will need to support two main workflows which team members are using. These workflows are essentially about where people start a local qontract-server from.

1. `make server` in app-interface itself: this command will need to still support starting a server with local schemas, including locally made changes.
1. `make dev` in qontract-server: this command will need to be changed to copy schemas from a local clone of the qontract-schemas repository.

To achieve this goal, we will add a `make schemas` command in app-interface and in qontract-server, which will be explicitly added to the `make server` / `make dev` commands. It will also need to be added to any script or document in app-interface (this is as simple as searching for `make bundle` and replacing it with `make schemas bundle`).

To make things consistent, `make server` will include pulling the schemas, and we will add a new `make dev` command that will generate the bundle based on the current schemas (including local changes). `make dev` will also allow configuring of the qontract-schemas local location.

## Alternatives considered

Move schemas to their code repositories.

This currently includes only qontract-reconcile and vault-manager, but may include additional repositories with app-interface related automations that may be created in the future.

This approach will be difficult to implement. With only 2 repositories at this time, it is already hard to imagine how to write the bundling process, and most importantly - how to adjust the development process.

It is true that keeping the schemas together with the code is the recommended way. We even recommend that to our tenants. The difference is that in our tenants' case there is a single code repository that works according to the schemas, and in our case there are N.

## Milestones

This work has to happen in a single iteration, as it is a "breaking change".
