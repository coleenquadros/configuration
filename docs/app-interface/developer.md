# App-Interface Developer Guide

## Overview

App-Interface is composed by the following repositories:

- https://gitlab.cee.redhat.com/service/app-interface - contains the actual data (YAML) and JSON schemas and GraphQL Schemas (NodeJS / JSON / YAML).
- https://github.com/app-sre/qontract-server - GraphQL Server.
- https://github.com/app-sre/qontract-reconcile - Python based integration framework (Python 2 and Python 3).
- https://github.com/app-sre/qontract-validator - Checks the data against the JSON schemas (Python 2 and Python 3).

## Current App-Interface Pipeline

When someone submits MR to change the data in `service/app-interface` this is what happens:

- MR sent to `service/app-interface` with some kind of modification to the datafiles.
- [PR check Jenkins job](https://ci.int.devshift.net/view/app-interface/job/service-app-interface-gl-pr-check/) runs executing [pr_check.sh](https://gitlab.cee.redhat.com/service/app-interface/blob/master/pr_check.sh), which in turn does the following:
  - Bundles app-interface into a single JSON file and validates it (`make bundle validate`, uses [qontract-validator](https://github.com/app-sre/qontract-validator)).
  - Generates a report.
  - Runs [manual_reconcile.sh](https://gitlab.cee.redhat.com/service/app-interface/blob/master/manual_reconcile.sh):
    - Starts a local qontract-server (which allows using a tag newer than the one in production by specifying it in the [service/app-interface/.env](https://gitlab.cee.redhat.com/service/app-interface/blob/master/.env) file).
    - Runs all the defined [integrations](https://gitlab.cee.redhat.com/service/app-interface/blob/7f8a15444fab01fbd3467e32e8d4ff00a4d61032/manual_reconcile.sh#L109-112)
  - Runs the reporting engine again to append to the previous report the output of integrations.
- The AppSRE engineer looks at the report and decided whether to merge.
- If merged, [production app-interface Jenkins Job](https://ci.int.devshift.net/view/app-interface/job/service-app-interface-gl-pr-check/view/app-interface/job/service-app-interface-gl-build-master/) is executed, which runs [build_deploy.sh](https://gitlab.cee.redhat.com/service/app-interface/blob/master/build_deploy.sh)
  - Bundles the data and uploads to `app-interface.stage.devshift.net` and reloads the service.
  - Bundles the data and uploads to `app-interface.devshift.net` and reloads the service.
  - It waits and ensures that the data was correctly loaded (by looking at the sha256)
  - Runs the [defined integrations](https://gitlab.cee.redhat.com/service/app-interface/blob/7f8a15444fab01fbd3467e32e8d4ff00a4d61032/build_deploy.sh#L105-108).

**Note**: the Quay repos and tags are maintaned in the [service/app-interface/.env](https://gitlab.cee.redhat.com/service/app-interface/blob/master/.env) file.

## Creating a new integration

An integration is **any** piece of software that has the following properties:

- Its goal is to configure a third-party service or tool to match whatever is defined in the app-interface datafiles.
- It can query a running `qontract-server` using a GraphQL client library to obtain the DESIRED state.
- It can retrieve the CURRENT state by using APIs or whatever technique of the third-party service that needs to be configured.
- Capable of diffing the CURRENT and DESIRED state.
- It can perform any required actions to evolve the CURRENT state into the DESIRED state.
- Supports `--dry-run` option (or similar) to simulate any changes without applying them.
- It MUST be developed using IDEMPOTENCY principles, so if the integration is run several times, it will not fail.

[qontract-reconcile](https://github.com/app-sre/qontract-reconcile) is a Python 2 / Python 3 framework to create sub-commands that satisfy the above requirements.

This is an example of a PR that creates a new subcommand of `qontract-reconcile` to reconcile Quay repositories: https://github.com/app-sre/qontract-reconcile/pull/9/files

## Running the App-Interface components locally

- [Create the data, schema and resource bundles](https://github.com/app-sre/qontract-server#creating-the-schema-data-and-resources-bundle).
- [qontract-server](https://github.com/app-sre/qontract-server#development-environment).
- [qontract-reconcile](https://github.com/app-sre/qontract-reconcile/tree/master#installation)
