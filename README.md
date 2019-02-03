# App-Interface

This repository serves as a central coordination point for hosted services being
run by the Application SRE team. Many or all of the portions of the contract
defined herein will be handled through automation after changes are accepted to
this repository by the appropriate parties.

The Application SRE team is responsible of fulfilling the contract defined in
this repository.

## Overview

This repository contains of a collection of files under the `data` folder.
Whatever is present inside that folder constitutes the App-SRE contract.

These files can be `yaml` or `json` files, and they must validate against the some
[well-defined json schemas][schemas].

The path of the files do not have any effect on the integrations (automation
components that feed off the contract), but the contents of the files do. They
will all contain:

- `$schema`: which maps to a well defined schema [schema][schemas].
- `labels`: arbitrary labels that can be used to perform queries, etc.
- Additional data specific to the resource in question.

## Components

Main App-Interface contract components:

- <https://gitlab.cee.redhat.com/service/app-interface>: datafiles (schema
  implementations) that define the contract.
- <https://github.com/app-sre/qontract-server>: json schemas of the datafiles
  submitted to the `app-interface` repository. The GraphQL component developed
  in this repository will make the datafiles queryable.

Additional components and tools:

- <https://github.com/app-sre/qontract-validator>: Python script that validates
  the datafiles against the json schemas hosted in `qontract-server`.
- <https://github.com/app-sre/qontract-reconcile>: automation component that
  reconciles the state of third-party services like `github`, with the contract
  definition.

The word _qontract_ comes from _queryable-contract_.

## Workflow

The main use case happens when an interested party wants to submit a contract
amendment. Some examples would be:

- Adding a new user and granting access to certain teams / services.
- Submitting a new application to be hosted by the Application SRE team.
- Modifying the SLO of an application.
- etc.

All contract amendments must be formally defined. Formal definitions are
expressed as json schemas. You can find the supported schemas here:
[schemas][schemas].

1. The interested party will:

- Fork the [app-interface](<https://gitlab.cee.redhat.com/service/app-interface>
) repository.
- Submit a MR with the desired contract amendment.

2. Automation will validate the amendment and generate a report of the desired
   changes, including changes that would be applied to third-party services like
   `OpenShift`, `Github`, etc, as a consequence of the amendment.

3. The Application-SRE team will review the amendment and will determine whether
   to accept it by merging the MR.

4. From the moment the MR is accepted, the amended contract will enter into
   effect.

## Local validation of datafile modifications / contract amendment

Before submitting a MR with a datafile modification / contract amendment, the
user has the option to validate the changes locally.

Two things can be checked: (1) JSON schema validation (2) run integrations with
`--dry-run` option.

Both scripts rely on a temporary directory which defaults to `temp/`, but can be
overridden with the env var `TEMP_DIR`. The contents of this directory will
contain the results of the manual pr check.

### JSON schema validation

Instructions to perform JSON schema validation on changes to the datafiles.

**Requirements**:

- docker
- git

**Instructions**:

Run the actual validator by executing:

```sh
# make sure you are in the top dir of the `app-interface` git repo
source .env
./manual_schema_validator.sh data
```

The output will be JSON document, so you can pipe it with `jq`, example:
`./manual_schema_validator.sh data | jq .`

### Running integrations locally with `--dry-run`

Instructions to run the integrations locally to simulate what would happen if it
was merged into the app-interface repo.

**NOTE**: This is only available to the SD team, as it requires access to this
vault secret: `app-sre/ci-int/qontract-reconcile-toml`.

**Requirements**:

- Having executed `manual_schema_validator.sh` previously as explained in the
  previous section.
- docker
- git

**Instructions**:

Obtain the `config.toml` file required to run the integrations.

```sh
# make sure you are in the top dir of the `app-interface` git repo
vault read -field=data_base64 app-sre/ci-int/qontract-reconcile-toml | base64 -d > config.toml
```

Now you can run the integrations by executing:

```sh
# make sure you are in the top dir of the `app-interface` git repo
./manual_reconcile.sh temp/validate/data.json config.toml
```

The output of the integrations will be displayed in-line, but it will also be
saved in files: they can be located with `find temp/reports/reconcile_reports_*
-type f`.

## Querying the App-interface

The contract can be queried programmatically using a
[GraphQL](<https://graphql.org/learn/>) API.

The GraphQL endpoint is reachable here:
<https://app-interface.devshift.net/graphql>.

You need to authenticate to access the service. Please request the credentials
to the App-SRE team.

**IMPORTANT**: in order to use the GraphQL UI you need to click on the Settings
wheel icon (top-right corner) and replace `omit` with `include` in
`request.credentials`.

## Features

### Existing Features

- [GraphQL API](<https://github.com/app-sre/qontract-server>).
- Ability to validate all schemas as valid JSON-Schema and compliant with the
  integration metaschema.
- Ability to validate all datafile (schema implementations) that implement a
  schema.
- Validation of datafiles on MRs to the `app-interface` repository.
- Simulation of third-party service changes on MRs to `app-interface`
  repository.
- Automated deployment of the new contract to the production GraphQL endpoint.
- Automated execution of the supported integration components to reconcile other
  services with the desired state as represented in the contract.

### Planned Features

- Automatically generate GraphQL schemas from the JSON schemas.
- Automated reporting based on the contract via GraphQL API.
- Auditability and traceability. Being able to easily track down when and why an
  amendment was submitted.

## Integrations

### Existing integrations

- GitHub org and team syncing. With this integration we can leverage any service
  that is configured to use GitHub as the authentication platform. For example:
  - <https://ci.int.devshift.net/>
  - <https://ci.ext.devshift.net/>
  - <https://vault.devshift.net/ui/>
  - Many openshift.com clusters:
    - `dsaas`, `dsaas-stg`, `evg`, `app-sre`, `app-sre-dev`.
  - OpenShift.io Feature Toggles
- Management of OpenShift rolebindings
- Management of Quay repos.
- Management of Quay organisation members.

### Planned integrations

- Top level tracking of managed services, their contact points, and work
  streams.
- Automatically managing a Vault installation and federating access.
- Management of OLM catalog entries for managing service operators.
- Ownership of OpenShift Kubernetes namespace resources.
- Management of cluster monitoring, such as zabbix, prometheus, and alert
  manager.
- Cloud (AWS) resource provisioning.

## Howto

### Add or modify a user (`/access/users-1.yml`)

You will want to do this when you want to add a user or grant / revoke
permissions for that user.

Users are typically stored in the `teams/<name>/users` folder. Note that the
actual file path will not condition the integrations, you can consider the
directory structure as something that is only useful for human consumption.

Write the file in yaml format with `.yml` extension. The contents must validate
against the current [user schema][userschema].

Make sure you define `$schema: /access/users-1.yml` inside the file.

The `roles` property is the most complex property to understand. If you look at
the `/access/users-1.yml` you will see that it's a list of [crossrefs][crossref].
The `$ref` property points to another file, in this case it must be a
[role][role]. The role file is essentially a collection of
[permissions][permission]. Permissions contain a mandatory property called
`service` which indicate what kind of permission they are. The possible values
are:

- `aws-analytics`
- `github-org`
- `github-org-team`
- `openshift-rolebinding`
- `quay-org-team`

In any case, you typically won't need to modify the roles, just find the role
you want the user to belong to. Roles can be associated with the services:
`service/<name>/roles/<rolename>.yml`, or to teams:
`teams/<name>/roles/<rolename>.yml`. Check out the currently defined roles to
know which one to add.

### Create a Quay Repository for an onboarded App (`/app-sre/app-1.yml`)

Onboarded applications are modelled using the schema `/app-sre/app-1.yml`. This schema allows any application to optionally define a list required Quay repositories.

The structure of this parameter is the following:

```yaml
quayRepos:
- org:
    $ref: <quay org datafile (`/dependencies/quay-org-1.yml`), for example `/dependencies/quay/openshiftio.yml`>
  items:
  - name: <name of the repo>
    description: <description>
    public: <true | false>
  - ...
```

In order to add or remove a Quay repo, a MR must be sent to the appropriate App datafile and add the repo to the `items` array.

**NOTE**: If the App or the relevant Quay org are not modelled in the App-Interface repository, please seek the assistance from the App-SRE team.

Examples as of 2019-01-30:

- An example of a MR: https://gitlab.cee.redhat.com/service/app-interface/merge_requests/75/diffs
- [/services/uhc/app.yml](https://gitlab.cee.redhat.com/service/app-interface/blob/c22670e84ef19c5ce1192ea7c62948b1db69036a/data/services/uhc/app.yml#L21): `uhc` application, including `quayRepos` parameter.
- [/services/openshift.io/app.yml](https://gitlab.cee.redhat.com/service/app-interface/blob/c22670e84ef19c5ce1192ea7c62948b1db69036a/data/services/openshift.io/app.yml#L20): `openshiftio` application, including `quayRepos` parameter.
- [/dependencies/quay/app-sre.yml](https://gitlab.cee.redhat.com/service/app-interface/blob/c22670e84ef19c5ce1192ea7c62948b1db69036a/data/dependencies/quay/app-sre.yml): `app-sre` Quay org.
- [/dependencies/quay/openshiftio](https://gitlab.cee.redhat.com/service/app-interface/blob/c22670e84ef19c5ce1192ea7c62948b1db69036a/data/dependencies/quay/openshiftio.yml): `Openshifio` Quay org.
- [/app-sre/app-1.yml](https://github.com/app-sre/qontract-server/blob/8fafb7c24188645c099c0ee7a9f6806b178158dd/assets/schemas/app-sre/app-1.yml): JSON schema for App modelling.
- [/dependencies/quay-org-1.yml](https://github.com/app-sre/qontract-server/blob/8fafb7c24188645c099c0ee7a9f6806b178158dd/assets/schemas/dependencies/quay-org-1.yml): JSON schema for Quay organization.

## Design

Additional design information: [here](docs/design.md).

[schemas]:
<https://github.com/app-sre/qontract-server/tree/master/schemas/app-sre>
[userschema]:
<https://github.com/app-sre/qontract-server/blob/master/schemas/access/user-1.yml>
[crossref]:
<https://github.com/app-sre/qontract-server/blob/beb70a68334f49581c3656e2a223998965ee19c1/schemas/common-1.json#L58-L86>
[role]: <https://github.com/app-sre/qontract-server/blob/master/schemas/access/role-1.yml>
[permission]: <https://github.com/app-sre/qontract-server/blob/master/schemas/access/permission-1.yml>

## Developer Guide

More information [here](docs/developer.md).
