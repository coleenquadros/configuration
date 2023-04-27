# App-Interface

This repository serves as a central coordination point for hosted services
operated by the Application SRE team. Once the appropriate parties accept changes to this repository, many or all portions of the contract defined herein are automated.

If you are a team looking to run your service with the App SRE team, please follow the [onboarding-app](/docs/app-sre/onboarding-app.md) guide.

The Application SRE team is responsible for fulfilling the contract defined in
this repository.

[TOC]

## Overview

This repository contains of a collection of files under the `data` folder.
This folder contains everything that constitutes the APP SRE contract.

These files can be `yaml` or `json` files, and they must validate against some
[well-defined json schemas](https://github.com/app-sre/qontract-schemas).

The files' path does not affect the integrations (automation
components that feed off the contract), but the contents of the files do. They
will all contain the following:

- `$schema`: which maps to a well defined [schema](https://github.com/app-sre/qontract-schemas).
- `labels`: arbitrary labels that can be used to perform queries, etc.
- Additional data specific to the resource in question.

Continuous delivery is managed using the
[SaaS files](docs/app-sre/continuous-delivery-in-app-interface.md).

## Components

Main App-Interface contract components:

- <https://gitlab.cee.redhat.com/service/app-interface>: data files
  that implement the contract.
- <https://github.com/app-sre/qontract-schemas>: schema file
  that define the contract. JSON and GraphQL schemas of the data files.
- <https://github.com/app-sre/qontract-server>: The GraphQL component developed
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
amendment. Here are some examples:

- Adding a new user and granting access to certain teams / services.
- Submitting a new application to be hosted by the Application SRE team.
- Modifying the SLO of an application, etc.

All contract amendments must be formally defined. Formal definitions are
expressed as json schemas. You can find the supported schemas here:
https://github.com/app-sre/qontract-schemas.

1. The interested party will:

- Fork the [app-interface](<https://gitlab.cee.redhat.com/service/app-interface>
) repository.
- [Share their fork](https://docs.gitlab.com/ee/user/project/members/share_project_with_groups.html#sharing-a-project-with-a-group-of-users) of the `app-interface` repository with the [devtools-bot](https://gitlab.cee.redhat.com/devtools-bot) user as `Maintainer`.
- Submit a MR with the desired contract amendment.

2. Automation will validate the amendment and generate a report of the desired
   changes, including changes that would be applied to third-party services like
   `OpenShift`, `Github`, etc, as a consequence of the amendment.

3. The Application-SRE team will review the amendment and will determine whether
   to accept it by merging the MR.

4. From the moment the MR is accepted, the amended contract will enter into
   effect.

## App-Interface Etiquette

- When you create a MR, it's not necessary to immediately ping the @app-sre-ic in #sd-app-sre. The IC will eventually see it and merge it. It's only necessary to ping the IC if the MR is urgent or if a day has passed and the IC has not commented anything.
- If your PR only contains changes to saas-files, you can auto-approve, see here: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md#approval-process
- Even if you have rights to merge the PR, please refrain from doing so. If you need it merged urgently, ping @app-sre-ic in #sd-app-sre.
- If an AppSRE team member adds the `lgtm` label, it will be automerged by a bot.
- The AppSRE team members will also refrain from manually merging PRs and will use labels instead to allow the bot to automatically merge them. In App-Interface the order of the PRs is important, and if we manually merge, it will affect waiting times for other users.
- Please remove the comment from the MR description template and fill in the information, this is crucial for MR reviewing. The easier reviewers can understand your intention, the faster your MR will get a response.
- Please follow Git [best practices](https://service.pages.redhat.com/dev-guidelines/docs/appsre/git/)

## Local Validation of Datafile Modifications / Contract Amendment

Before submitting a MR with a datafile modification / contract amendment, you have the option to validate the changes locally.

Two things can be checked: (1) JSON schema validation (2) run integrations with
`--dry-run` option.

Both scripts rely on a temporary directory which defaults to `temp/`, but can be
overridden with the env var `TEMP_DIR`. The contents of this directory contain the results of the manual pr check.

### JSON schema validation

Instructions to perform JSON schema validation on changes to the datafiles.

**Requirements**:

- docker (or podman)
- git

**Instructions**:

Run the actual validator by executing:

```sh
# make sure you are in the top dir of the `app-interface` git repo
source .env
make schemas bundle validate # output is data.json
```

The output will be JSON document, so you can pipe it with `jq`, example:
`cat data.json | jq .`

### Running integrations locally with `--dry-run`

Instructions in [this document](/docs/app-sre/sop/running-integrations-manually.md).

## Visual App-interface

Visual App-interface is a visual representation of the data in this repository.
Source code can be found here: https://github.com/app-sre/visual-qontract

An internal instance is reachable (behind the VPN) here:
<https://visual-app-interface.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/graphql>.

A public instance is reachable (authentication via GH) here:
<https://visual-app-interface.devshift.net>.

## Querying the App-interface

The contract can be queried programmatically using a
[GraphQL](<https://graphql.org/learn/>) API.

The GraphQL internal endpoint is reachable (behind the VPN) here:
<https://app-interface.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/graphql>.

The GraphQL public endpoint is reachable (with authentication) here:
<https://app-interface.devshift.net/graphql>.

If you are querying app-interface, help us avoid breaking your queries by submitting a `query-validation` to let us know what schemas you are relying on. Here is an [example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/39455/diffs?commit_id=5964ea57ebefbe8cc309233457ce356f9897d873). We try to make our schemas backwards compatible, but in case of any issues, we expect a response within 1-2 business days.

**IMPORTANT**: To use the GraphQL UI, select the Settings
wheel icon (top-right corner) and replace `omit` with `include` in
`request.credentials`.

To get credentials to query app-interface, submit a Credentials Request form in a merge request.
The request is a file with the following structure:
* `$schema` - must be `/app-interface/credentials-request-1.yml`
* `labels` - labels to be added to the request (currently not used by automation)
* `name` - name of the request object. must be unique
* `description` - what will these credentials that you are requesting be used for
* `user` - a reference to a user file who this request is for. user file must contain a public gpg key. [instructions](#adding-your-public-gpg-key)
* `credentials` - the credentials which you are requesting
  * current options:
    - app-interface-production-dev-access
    - app-interface-production-cicd-access

Complete example:

```yaml
---
$schema: /app-interface/credentials-request-1.yml

labels: {}

name: example-request-20200512

description: |
  request description

user:
  $ref: /teams/path/to/user/file.yml

credentials: app-interface-production-dev-access

```

Please create the request file [here](/data/app-interface/requests).

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
  - Many OpenShift [clusters](/data/openshift)
  - OpenShift.io Feature Toggles
- Management of OpenShift rolebindings
- Management of Quay repos.
- Management of Quay mirrors.
- Management of Quay organization members.
- Management of Glitchtip organizations, projects, teams, and users.
- Management of OpenShift Namespaces.
- Management of OpenShift Groups.
- Management of OpenShift LimitRanges.
- Management of OpenShift resources.
- Management of OpenShift Secrets using Vault.
- Management of OpenShift Routes using Vault.
- Management of Vault configurations.
- Management of cluster monitoring, such as prometheus and alert manager.
- Management of AWS resources.
- Management of AWS users.
- Management of Slack User Groups.
- Management of Jenkins jobs configurations.
- Management of Jenkins roles association.
- Management of Jenkins plugins installation.
- Deletion of orphan AWS resources.
- Deletion of AWS keys per AWS account.
- House keeping of GitLab issues.
- Compliance validation of GitHub user profiles.
- Management of GitLab groups.
- Creation of GitLab projects.
- Deletion of OpenShift users.
- Management of notification e-mails.
- Management of SQL Queries.
- Creation of SLI related performance parameters recording rules.
- Management of layer 7 service networks (Skupper networks).

### Planned integrations

- Top level tracking of managed services, their contact points, and work
  streams.
- Management of OLM catalog entries for managing service operators.

## Entities and relations

App-interface data is represented by files that correspond to a schema. Files of one schema may reference files of another schema.

To learn more about the different entities and their relations:

- [Products, Environments, Namespaces and Apps](/docs/app-interface/api/entities-and-relations.md#products-environments-namespaces-and-apps)

## Our How-To Guides

### Add or modify a user (`/access/user-1.yml`)

You will want to do this when you want to add a user or grant / revoke
permissions for that user.

Users are typically stored in the `teams/<name>/users` folder. Note that the
actual file path will not condition the integrations, you can consider the
directory structure as something that is only useful for human consumption.

Write the file in yaml format with `.yml` extension. The contents must validate
against the current [user schema][userschema].

Make sure you define `$schema: /access/user-1.yml` inside the file.

The `roles` property is the most complex property to understand. If you look at
the `/access/user-1.yml` you will see that it's a list of [crossrefs][crossref].
The `$ref` property points to another file, in this case it must be a
[role][role]. The role file is essentially a collection of
[permissions][permission]. Permissions contain a mandatory property called
`service` which indicate what kind of permission they are. The possible values
are:

- `github-org`
- `github-org-team`
- `quay-org-team`

In any case, you typically won't need to modify the roles, just find the role
you want the user to belong to. Roles can be associated with the services:
`service/<name>/roles/<rolename>.yml`, or to teams:
`teams/<name>/roles/<rolename>.yml`. Check out the currently defined roles to
know which one to add.

#### Enabling Temporary Roles in App-Interface

One of the cases a tenant will want to modify a role yaml file is if you want to add an `expirationDate` field, in order for tenants to gain temporary access for any debugging purposes.

The [openshift rolebindings](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/openshift_rolebindings.py) and [openshift groups](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/openshift_groups.py) section of our [qontract-reconcile](https://github.com/app-sre/qontract-reconcile) integration will pick up on the change through [app-interface](https://gitlab.cee.redhat.com/service/app-interface) and a check will run to see if the date is valid. The date specified in the `expirationDate` field must be in `YYYY-MM-DD` format and it must not be older than today's date. If the value for the field is not correct, the integration will fail alerting you about the date format and if the `expirationDate` value has past today's date then the access will be removed.
<br>

##### Example on how it will look in a role file

Schema can be found [here](https://github.com/app-sre/qontract-schemas/blob/main/schemas/access/permission-1.yml).

```
---
$schema: /access/role-1.yml

labels: {}
name: prod-debugger

expirationDate: '2023-02-01'

permissions: []

access:
- cluster:
    $ref: /openshift/telemeter-prod-01/cluster.yml
  group: observatorium-allow-port-forward-group
```
<br>

#### User off-boarding / revalidation loop

The
[ldap-users](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/ldap_users.py)
integration continuously checks the presence of users in the corporate LDAP
(ldap.rdu.redhat.com). If the user does no longer exist in LDAP, this process
will submit a MR removing the affected user's file from App-Interface. This MR
will be automatically merged.

Once the user file is removed from App-Interface all access granted to the user
will be immediately revoked. Since all access granted by AppSRE is granted
through the presence of this file, this effectively removes all access.

This integration currently runs as a CronJob every hour.

### Get notified of events involving a service, or its dependencies

There are three ways a user or group can get notified of service events (e.g. planned maintenance, outages):

* `serviceOwner`:  Point of contact for communications from Service Delivery to service owners.  Where possible, this should be a development team mailing list (rather than an individual developer).  This field is Required.
* `serviceNotifications`:  This is a list of additional email addresses of employees who would like to receive notifications about a service.  This field is Optional.
* Subscribe to the `sd-notifications@redhat.com` [mailing list](https://post-office.corp.redhat.com/mailman/listinfo/sd-notifications). This list receives all event communications.

Find out more about App-SRE Incident Procedures [here](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/AAA.md#incident-procedure).

Example usage for [Hive](https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/hive/app.yml):

```
serviceOwners:
- name: Devan Goodwin
  email: dgoodwin@redhat.com

serviceNotifications:
- name: Hive Mailing list
  email:  aos-hive@redhat.com
```

### Define an escalation policy for a service

There are two steps to defining an escalation policy for a given service:

#### Prerequisites: The team's slack channel and Pagerduty schedule are defined in app-interface

In case you don't meet the prerequisites, please follow:
- [Manage Slack User groups via App-Interface](#manage-slack-user-groups-via-app-interface)

#### Step 1: Define escalation policies for the team:

Each team can have multiple escalation policies defined. This is useful in case the team divides the ownership of developed services. For a single escalation policy, create a general.yml under `teams/<teamname>/escalation-policies/`. An example can be seen [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/9bcb0b1c07d79ef164c552b2b970bc0247e9c1fa/data/teams/telemeter/escalation-policies/general.yaml)

Here's a template you can copy-paste and edit as needed:

```yaml


---
$schema: /app-sre/escalation-policy-1.yml

labels: {}

name: <teamname>-general-escalations

description: |
  Here, you should note whether the team has developer oncall support and what the reaction times for each of the escalation channels is.

  Also, we expect some information on escalation criteria.

  In case the team does not have an oncall rotation, it is required to add a `nextEscalationPolicy` -
  a reference to the next escalation policy to follow in case of an incident.
  This can be a Manager escalation for example.

channels:
  slackUserGroup:
  - $ref: /teams/<teamname>/permissions/<teamname>-coreos-slack.yml

  email:
  - <teamname>@redhat.com

  jiraBoard:
  - $ref: /teams/<teamname>/jira/<boardname>.yml

  pagerduty:
    $ref: /dependencies/pagerduty/<teamname>-oncall.yml

  nextEscalationPolicy:
    $ref: /teams/<teamname>/escalation-policies/<next>.yml

```

#### Step 2: Link the service to a team's escalation policy

The next step is to link the defined escalation policy to the service. In order to do that, we add a new `escalationPolicy` reference within the `app.yml`. For example, see [this PR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/13851/diffs?commit_id=9bcb0b1c07d79ef164c552b2b970bc0247e9c1fa)

### Create a Quay Repository for an onboarded App (`/app-sre/app-1.yml`)

Onboarded applications are modelled using the schema `/app-sre/app-1.yml`. This schema allows any application to optionally define a list required Quay repositories.

The structure of this parameter is the following:

```yaml
quayRepos:
- org:
    $ref: <quay org datafile (`/dependencies/quay-org-1.yml`), for example `/dependencies/quay/openshiftio.yml`>
  teams: # optional
  - permissions:
    - $ref: <quay-membership permission datafile (`/access/permission-1.yml`), for example `/dependencies/quay/permissions/quay-membership-app-sre-managed-services.yml`>
    role: read
  items:
  - name: <name of the repo, e.g. 'centos'>
    description: <description>
    public: <true | false>
  - ...
```

In order to add or remove a Quay repo, a MR must be sent to the appropriate App datafile and add the repo to the `items` array.

The `teams` section should be added if you want to have `read` access to your team's repos. This access will be added to the teams specified in the `permissions` section for each repo in the `items` section.

**NOTE**: If the App or the relevant Quay org are not modelled in the App-Interface repository, please seek the assistance from the App-SRE team.


#### Mirroring Quay Repositories

If you are creating a Quay Repository that is not used for publishing you
application on, but instead is used for mirroring an external repository,
you can automate the mirroring by adding `mirror` section to your `quayRepo`
specification:

```yaml
quayRepos:
- org:
    ...
  items:
  - name: my-private-repo
    ...
    mirror:
      $ref: /dependencies/image-mirrors/docker.io/me/my-private-repo.yml
```

The `$ref` file content would then be:

```yaml
---
$schema: /dependencies/container-image-mirror-1.yml

url: docker.io/me/my-private-repo

pullCredentials:
  path: app-sre/creds/mirror-images/docker-io_me_my-private-repo
  field: all

tags:
  - "latest"
```

The supported fields in the container-image-mirror specification are:

* `url` (mandatory): the url for the image we are to mirror from.
* `pullCredentials` (optional): the path for the vault secret containing the
  `user` and the `token` for the repository.
* `tags` (optional): list of tags to limit the mirroring to. Regular
  expressions are supported. When defined, `tagsExclude` is ignored.
* `tagsExclude` (optional): list of tags to exclude from the mirroring. Regular
  expressions are supported.

---
### Create a Glitchtip Organization (`/dependencies/glitchtip-organization-1.yml`)

A glitchtip project is related to a glitchtip organization, and all projects in an organization can be accessed by all organization members.

To define your glitchtip organization, create a file in `/data/dependencies/glitchtip/organizations/` with a structure like the following:
```yaml
$schema: /dependencies/glitchtip-organization-1.yml

labels:
  service: glitchtip

name: <name of the organization - lower case max 64 characters>
description: <description of the organization>
instance:
  $ref: /dependencies/glitchtip/glitchtip-production.yml

```
Please note that the organization's name must be unique.

### Create a Glitchtip Project for an onboarded App (`/dependencies/glitchtip-project-1.yml`)

To define your glitchtip project, create a file in `/data/dependencies/glitchtip/projects/` with a structure like the following:
```yaml
name: <name of the project - lower case max 64 characters>
description: <description of the project>
app:
  $ref: <app datafile (`/app-sre/app-1.yml`)>
platform: <project language>
teams:
- $ref: <glitchtip team datafile (`/dependencies/glitchtip-team-1.yml`), for example `/dependencies/glitchtip/teams/app-sre.yml`>
- ...
organization:
  $ref: <glitchtip organization datafile (`/dependencies/glitchtip-organization-1.yml`), for example `/dependencies/glitchtip/glitchtip-production.yml`>

```

The name, app, description, platform, teams, and organization fields are required. The name must be unique.

Now that the project is defined, you have to include it in an openshift namespace (`/openshift/namespace-1.yml`):

```yaml
$schema: /openshift/namespace-1.yml

...

glitchtipProjects:
- $ref: <glitchtip project datafile (`/dependencies/glitchtip-project-1.yml`), for example `/dependencies/glitchtip/projects/glitchtip-production/app-interface-prod.yml`
```

By referencing the project in a namespace, the **Glitchtip project DSN** can be consumed via a Kubernetes secret. The secret has the following structure:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <project name>-dsn
data:
  dsn: <base64 encoded DSN>
  security_endpoint: <base64 encoded security endpoint>
```
E.g., the [app-interface-prod](data/dependencies/glitchtip/projects/glitchtip-production/app-interface-prod.yml) is referenced in [the app-interface-production-int namespace](data/services/app-interface/namespaces/app-interface-production-int.yml), so the DSN can be retrieved via the `app-interface-production-dsn` secret in the namespace.

> **Note** :information_source:
>
> You can also reference the project in an `app` datafile (`/app-sre/app-1.yml`) but this won't generate the Glitchtip project DSN secret and isn't recommended for the most use-cases.


### Create a Glitchtip Team (`/dependencies/glitchtip-team-1.yml`)

Glitchtip projects are associated with glitchtip teams. Teams are used for notification purposes only!

To define a glitchtip team, create a file in `/data/dependencies/glitchtip/teams`.

```yaml
---
$schema: /dependencies/glitchtip-team-1.yml

labels:
  service: glitchtip

name: <name of the team - lower case max 64 characters>
description: <description of the team>
```

Please note that the team name must be unique within an organization.

### Manage Glitchtip team membership via App-Interface (`/access/role-1.yml`)

Glitchtip users and glitchtip team members can be entirely self-serviced via App-Interface.

Define or create a `role` that includes a `glitchtip_roles` and a `glitchtip_teams` sections.

```yaml
glitchtip_roles:
- organization:
    $ref: <glitchtip organization datafile (`/dependencies/glitchtip-organization-1.yml`), for example `/dependencies/glitchtip/glitchtip-production.yml`>
role: admin

glitchtip_teams:
- $ref: <glitchtip team datafile (`/dependencies/glitchtip-team-1.yml`), for example `/dependencies/glitchtip/teams/app-sre.yml`>
```
E.g.: [app-sre role](data/teams/app-sre/roles/app-sre.yml)


### Glitchtip Project Alerts

At the moment, project alerts (emails and webhooks) can't be configured via App-Interface. Please configure them manually via the Glitchtip UI (`Settings -> Projects -> Settings -> Project Alerts`).

> **Attention** :warning:
>
> There is no default email alert configured for any Glitchtip project. If you don't configure an email alert, you won't receive any alert emails.

---
### Manage Openshift resources via App-Interface (`/openshift/namespace-1.yml`)

[services](/data/services) contains all the services that are being run by the App-SRE team. Inside of those directories, there is a `namespaces` folder that lists all the `namespaces` that are linked to that service.

Namespaces declaration enforce [this JSON schema](https://github.com/app-sre/qontract-schemas/blob/main/schemas/openshift/namespace-1.yml). Note that it contains a reference to the cluster in which the namespace exists.

A namespace declaration can contain labels. These will be applied as kubernetes labels on the namespace resource. Note that
* labels must conform to [Kubernetes Labels constraints](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#syntax-and-character-set).
* labels set by other means (eg an operator) will not be overridden. If a conflict exists, an error will be thrown.

Notes:
* If the resource already exists in the namespace, the PR check will fail. Please get in contact with App-SRE team to import resources to be under the control of App-Interface.
* Manual changes to resources will be overridden by App-Interface in each run.
* If a resource has a `qontract.recycle: "true"` annotation, all pods using that resource will be recycled on every update.
  * Supported resources: Secrets, ConfigMaps
  * **Recycling pods managed by Clowder is not supported at this time** (see: [APPSRE-4034](https://issues.redhat.com/browse/APPSRE-4034))

OpenShift resources can be entirely self-serviced via App-Interface. A list of supported resource types can be found [here](https://github.com/app-sre/qontract-schemas/blob/main/schemas/openshift/namespace-1.yml#L46).

Some resources have special characteristics and are described further below. These have a specific `provider` value.
- `Secret`
- `Route`

For other resources, two `provider` options are available:
- `resource`
- `resource-template`

The `resource-template` provider supports using the `Jinja2` template language to extend the capabilities of the integration. In addition to the [standard Jinja2 language](https://jinja.palletsprojects.com/en/2.10.x/), the following additional capabilities are supported:
- Fetch a secret from vault

    ```jinja
    {{ vault('app-sre/creds/smtp', 'username') }}
    ```

- Fetch a secret from vault with a templated path or key:

    ```jinja
    {{ vault('path/to/secret-with-key-per-namespace', '{{ resource.namespace.name }}') }}
    ```

- Fetch file contents from github:

    ```jinja
    {{ github('repo-name', 'path-to-file', 'ref') }}
    ```

- Execute a Graphql query on app-interface data:

    ```jinja
    {{ query('/queries/file.graphql') }}
    ```

  This file should be located in the `resources/queries/` directory. See all existing examples [here](/resources/queries/)

- Base64 encode a block of data

    ```jinja
    {% b64encode %}
    My data
    {% endb64encode %}
    ```

- Reference the resource & namespace metadata from app-interface

  The `resource` variable is passed to Jinja2 and contains all the resource/namespace metadata as returned by the integration at the point of processing the resource

  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ resource.name }}
  data:
    foo: bar
  ```

> **Warning**: The Jinja2 delimiters (`{{ }}` and `{% %}`) conflicts with other templating languages such as go's text/template. To remedy that, the `type` `extracurlyjinja2` can be used to add an extra curly brace to the standard Jinja2 delimiters (resulting in `{{{ }}}` and `{{% %}}`

The next section demonstrates how to manage a `ConfigMap` resource via two examples showing both the `resource` and `resource-template` providers:

#### Manage shared OpenShift resources via App-interface (`/openshift/namespace-1.yml`)

In order to manage resources for multiple namespaces in a single location you can use a Shared Resources file.

Create a shared resources file with an `openshiftResources` section. [Example](/data/services/ocm/shared-resources/stage.yml). The `openshiftResources` section is defined identically in a namespace file and in a shared resources file (see previous section).

To add the shared resources to a namespace, add a `sharedResources` section to a namespace file and reference the shared resources file. [Example](/data/services/ocm/namespaces/uhc-stage.yml).

#### Example: Manage a ConfigMap via App-Interface (`/openshift/namespace-1.yml`)

In order to add ConfigMaps to a namespace, you need to add them to the `openshiftResources` field.

- `provider`: must be `resource`
- `path`: path relative to [resources](/resources). Note that it starts with `/`.

The object itself must be stored under the `resources` path, and by convention it should be named: `resources/<cluster_name>/<namespace>/<configmap_name>.configmap.yml`.

In order to change the values of a ConfigMap, send a PR modifying the ConfigMap in the `resources` directory, and upon merge it will be applied.

#### Example: Manage a templated ConfigMap via App-Interface (`/openshift/namespace-1.yml`)

A templated opensource resource is configured the same way as a standard resource, with the following changes:

- `provider`: must be `resource-template`
- `type`: can be `jinja2` or `extracurlyjinja2` (default is `jinja2`)

An example of the file content could be:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
type: Opaque
data:
  not_so_secret_value: {{{ vault('app-interface/my-cluster/my-namespace/my-not-so-secret-secret', 'the-key') }}}
```


#### Manage Secrets via App-Interface (`/openshift/namespace-1.yml`) using Vault

Instructions:

1. Create a secret in Vault with the data (key-value pairs) that should be applied to the cluster.
  * The secret in Vault should be stored in the following path: `app-interface/<service>/<environment>/<secret_name>`, environment being `stage`, `prod`, ...
  * The value of each key in the secret in Vault should **NOT** be base64 encoded.
  * If you wish to have the value base64 encoded in Vault, the field key should be of the form `<key_name>_qb64`.
2. Add a reference to the secret in Vault under the `openshiftResources` field ([example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/cd9c6062819e2da76ed108f1bf4946ca72e593d6/data/services/cincinnati/namespaces/cincinnati-production.yml#L26-29))with the following attributes:

- `provider`: must be `vault-secret`.
- `path`: absolute path to secret in [Vault](https://vault.devshift.net). Note that it should **NOT** start with `/`.
- `version`: version of secret in Vault.
- `name`: (optional) name of the Kubernetes Secret object to be created. Overrides the name of the secret in Vault.
- `labels`: (optional) labels to add to the Secret.
- `annotations`: (optional) annotations to add to the Secret.
- `type`: (optional) type of the Kubernetes Secret to be created. Defaults to `Opaque` if not specified.

3. In order to change one or more values in a Kubernetes Secret, update the secret in Vault first and submit a new MR with the updated `version` field.
  * The current version can be found in Vault on the top-right of the list of values for your secret.

Notes:

* When creating a new secret in Vault, be sure to set the `Maximum Number of Versions` field to `0` (unlimited).
* If you want to delete a secret from Vault, please get in contact with the App-SRE team.
* If you wish to use a different secrets engine, please get in contact with the App-SRE team.
* To create a secret in a `production` environment, please get in contact with the App-SRE team.

Example:

This secret in Vault:
```
{
  "key": "value",
  "otherkey_qb64": "dmFsdWUy"
}
```
Would generate this Kubernetes Secret:
```yaml
apiVersion: v1
kind: Secret
data:
  key: dmFsdWU=
  otherkey: dmFsdWUy
type: Opaque
```

#### Manage Routes via App-Interface (`/openshift/namespace-1.yml`) using Vault

Routes can be entirely self-serviced via App-Interface.

In order to add Routes to a namespace, you need to add them to the `openshiftResources` field.

- `provider`: must be `route`
- `path`: path relative to [resources](/resources). Note that it starts with `/`.
- `vault_tls_secret_path`: (optional) absolute path to secret in [Vault](https://vault.devshift.net) which contains sensitive data to be added to the `.spec.tls` section.
- `vault_tls_secret_version`: (optional, mandatory if `vault_tls_secret_path` is defined) version of secret in Vault.

Notes:
* The secret in Vault should be stored in the following path: `app-interface/<cluster>/<namespace>/routes/<secret_name>`.
* In case the Route contains no sensitive information, a secret in Vault is not required (hence the fields are optional).
* It is recommended to read through the instructions for [Secrets](#manage-secrets-via-app-interface-openshiftnamespace-1yml-using-vault) before using Routes.

#### Validate JSON in Secrets and ConfigMaps

If a key of a Secret or ConfigMap keys is a JSON, you can add the option `validate_json` to the openshift resource definition in order to make sure it is valid json.

#### Validate AlertManager configuration in Secrets and ConfigMaps

If a key of a Secret or ConfigMap keys is a JSON, you can add the option `validate_alertmanager_config` to the openshift resource definition in order to make sure it is valid alertmanager config. The integration will look into the `alertmanager.yaml` key of the secret to look for it unless `alertmanager_config_key` is specified.

#### Dynamically generate resources using Graphql queries

If a resource is using the `query()` alias, specify `enable_query_support: true` to enable the functionality.

More information: [Manage Openshift resources via App-Interface](/README.md#manage-openshift-resources-via-app-interface-openshiftnamespace-1yml)

### Manage OpenShift Groups association via App-Interface (`/openshift/cluster-1.yml`)

[openshift](/data/openshift) contains all the clusters that are managed by the App-SRE team. Inside of those directories, there is a `cluster.yml` file that describes the cluster.

Clusters declaration enforce [this JSON schema](https://github.com/app-sre/qontract-schemas/blob/main/schemas/openshift/cluster-1.yml).

OpenShift group association can be self-serviced via App-Interface.

Groups should be defined under the `managedGroups` section in the cluster file. This is a list of group names that are managed. To associate a user to a group, the user has to be associated to a role that has `access` to the OpenShift group.

An example of a role can be found [here](/data/teams/hive/roles/dev.yml).

Notes:
* The `dedicated-admins` group is managed via OCM using the [ocm-groups](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/ocm_groups.py) integration, whereas all other groups are managed via OC using the [openshift-groups](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/openshift_groups.py) integration.
* The `cluster-admins` group is managed manually via OCM as part of a [cluster onboarding](/docs/app-sre/sop/app-interface-onboard-cluster.md#step-7-obtain-cluster-admin).

### Manage OpenShift LimitRanges via App-Interface (`/openshift/limitrange-1.yml`)

This integration allows namespace owners to manage LimitRanges objects on their namespaces

To deploy and manage LimitRanges on a namespace, a user must add the following to a namespace declaration:

```yaml
limitRanges:
  $ref: /dependencies/openshift/limitranges/<some-name>.yml
```

The LimitRange limits can be customized by creating a new file and referencing the new file in the namespace declaration

The `/openshift/limitrange-1.yml` schema maps to the LimitRanges specs.

### Manage OpenShift ResourceQuotas via App-Interface (`/openshift/quota-1.yml`)

This integration allows namespace owners to manage ResourceQuota objects on their namespaces

To deploy and manage ResourceQuotas on a namespace, a user must add the following to a namespace declaration:

```yaml
quota:
  $ref: /path/to/some/quota.yml
```

The ResourceQuota limits can be customized by creating a new file and referencing the new file in the namespace declaration.

The `/openshift/quota-1.yml` schema maps to the ResourceQuotas specs.

### Self-Service OpenShift ServiceAccount tokens via App-Interface (`/openshift/namespace-1.yml`)

This integration allows namespace owners to get ServiceAccount tokens from a different cluster/namespace in to their namespace for consumption.

To add a Secret to a namespace, containing the token of a ServiceAccount from another namespace, a user must add the following to a namespace declaration:

```yaml
openshiftServiceAccountTokens:
- namespace:
    $ref: /services/<service>/namespaces/<namespace>.yml
  serviceAccountName: <serviceAccountName>
  name: <name of the output resource to be created> # optional
```

The integration will get the token belonging to that ServiceAccount and add it into a Secret called:
`<clusterName>-<namespaceName>-<ServiceAccountName>`. This is the default name unless `name` is defined.
The Secret will have a single key called `token`, containing a token of that ServiceAccount.

### Enable network traffic between Namespaces via App-Interface (`/openshift/namespace-1.yml`)

To enable network traffic between namespace, a user must add the following to a namespace declaration:

```yaml
networkPoliciesAllow:
- $ref: /path/to/source-namespace.yml
```

This will allow traffic from the `source-namespace` to the namespace in which this section is defined.

In this [example](/data/services/cincinnati/namespaces/cincinnati-production.yml#L18-19), traffic is enabled from the `openshift-customer-monitoring` namespace to the `cincinnati-production` namespace.

### Manage Vault configurations via App-Interface

https://vault.devshift.net is entirely managed via App-Interface and its configuration can be found in [config](/data/services/vault.devshift.net/config) folder of ` vault.devshift.net` service

#### Manage vault audit backends (`/vault-config/audit-1.yml`)
Audit devices are the components in Vault that keep a detailed log of all requests and response to Vault

Example:
```yaml
---
$schema: /vault-config/audit-1.yml

labels:
  service: vault.devshift.net

_path: "file/"
type: "file"
description: ""
options:
  _type: "file"
  file_path: "/var/log/vault/vault_audit.log"
  format: "json"
  log_raw: "false"
  hmac_accessor: "true"
  mode: "0600"
  prefix: ""
```
Current audit backends configurations can be found [here](/data/services/vault.devshift.net/config/audit-backends/)

For more information please see [vault audit backends documentation](https://www.vaultproject.io/docs/audit/index.html)

#### Manage vault auth backends (`/vault-config/auth-1.yml`)
Auth backends are the components within Vault that perform authentication. The permissions granted to users upon login are handled via Vault `Entities` and `Groups`. (see **Manage Vault Entities and Groups** below for details)

The primary authentication method used for user access to vault.devshift.net is [OIDC](https://learn.hashicorp.com/tutorials/vault/oidc-auth?in=vault/auth-methods). This method utilizes Red Hat's managed identity provider to verify user claims. The `Default` role is always utilized when attempting login.

Current auth backends configurations can be found [here](/data/services/vault.devshift.net/config/prod/auth-backends)

For more information please see [vault auth backends documentation](https://www.vaultproject.io/docs/auth/index.html)

#### Manage vault entities and groups
An `Entity` is a resource within Vault that represents a user. Entities are associated with one or more `Groups` that grant permissions to the entities via policies. (see **Manage vault policies** below for more on configuring policies)

In the context of App-Interface, entities are generated for users that reference App-Interface roles that contain `oidc_permission` references.

**Example:**

User file that contains a reference to the `app-sre` role
```yaml
---
$schema: /access/user-1.yml

labels: {}

name: Drew Welch
org_username: dwelch
github_username: dwelch0
quay_username: rh_ee_dwelch

roles:
- $ref: /teams/app-sre/roles/app-sre.yml
```

The `app-sre` role contains a reference to an `oidc_permission` 
```yaml
---
$schema: /access/role-1.yml

labels: {}
name: app-sre

oidc_permissions:
- $ref: /dependencies/vault/permissions/oidc/prod/app-sre.yml
```
Note: roles that reference oidc_permissions are mapped as `groups` within Vault. i.e, there will be a Vault group named `app-sre`

The `oidc_permission` file contains references to Vault policies
```yaml
---
$schema: /access/oidc-permission-1.yml

labels:
  service: vault.devshift.net

name: app-sre-oidc-vault
description: app-sre vault administrator permission

instance:
  $ref: /services/vault.devshift.net/config/prod/devshift-net.yml

service: vault
vault_policies:
- $ref: /services/vault.devshift.net/config/prod/policies/app-sre-policy.yml
- $ref: /services/vault.devshift.net/config/prod/policies/vault-manager-policy.yml
```

In summary, the user `dwelch` (username within Red Hat IdP) will have an entity within Vault also named `dwelch`. Upon logging in using OIDC method, the user will be mapped to the any groups they referenced (just the app-sre group in this example).

#### Manage vault policies (`/vault-config/policy-1.yml`)
Policies provide a declarative way to grant or forbid access to certain paths and operations in Vault

Example:
```yaml
---
$schema: /vault-config/policy-1.yml

labels:
  service: vault.devshift.net

name: "<POLICY_NAME>"
rules: |
  path "<SECRETS_ENGINE>/PATH/*" {
    capabilities = ["create","read","update","delete","list"]
  }
```
Current vault policies can be found [here](/data/services/vault.devshift.net/config/policies)

For more information please see [vault policies documentation](https://www.vaultproject.io/docs/concepts/policies.html)

For an example on adding team access to manage Vault app-interface secrets see [this PR](https://gitlab.cee.redhat.com/service/app-interface/merge_requests/2097).

#### Manage vault roles (`/vault-config/role-1.yml`)
Roles represents a set of Vault policies and login constraints that must be met to receive a token with those policies.
The scope can be as narrow or broad as desired. Role can be created for a particular machine, or even a particular user on that machine,
or a service spread across machines. The credentials required for successful login depend upon the constraints set on the Role associated with the credentials.
Currently we support only AppRole.

AppRole Example:
```yaml
---
$schema: /vault-config/role-1.yml

labels:
  service: vault.devshift.net

name: "<ROLE_NAME>"
type: "approle"
mount: "approle/"
options:
  _type: "approle"
  bind_secret_id: "true"
  local_secret_ids: "false"
  period: "0s"
  secret_id_num_uses: "0"
  secret_id_ttl: "0s"
  token_max_ttl: "30m"
  token_num_uses: "1"
  token_ttl: "30m"
  token_type: "default"
  bound_cidr_list: []
  policies:
    - <VAULT_POLICY>
  secret_id_bound_cidrs: []
  token_bound_cidrs: []
```
Current vault roles can be found [here](/data/services/vault.devshift.net/config/roles)

For more information please see [vault AppRole documentation](https://www.vaultproject.io/docs/auth/approle.html)

##### Output Approle credentials at desired Vault path
The approle schema supports an optional attribute `output_path` that specifies a path within Vault to output the approle's `role_id`, `secret_id`, and `secret_id_accessor`  

###### Considerations
* Do not manually create an empty secret beforehand
  - Example: if specified `output_path` is `/app-sre/ci/stage/foobar`, do not manually create `foobar`  
* Ensure the [vault-manager policy](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/prod/policies/vault-manager-policy.yml) has `read`, `create`, and `update` permission for the desired path. 
  - **NOTE:** if the desired path resides within a KV V2 secret engine, ensure a `data` path segment exists after the secret engine name. [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/5abcf371f9be807b990bc569a766f393f898955c/data/services/vault.devshift.net/config/prod/policies/vault-manager-policy.yml#L85-88)  
    - reference [vault kv v2 docs](https://developer.hashicorp.com/vault/docs/secrets/kv/kv-v2#acl-rules) for specifics

An example of this attribute being utilized on an approle within vault.stage.devshift.net can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/stage/roles/approles/vault_manager_stage.yml#L12)  


#### Manage vault secret-engines (`/vault-config/secret-engine-1.yml`)
Secrets engines are components which store, generate, or encrypt data. Secrets engines are incredibly flexible, so it is easiest to think about them in terms of their function.
Secrets engines are provided some set of data, they take some action on that data, and they return a result.

App-interface currently supports the following secrets engines:
- KV (v1)
- KV (v2)
- TOTP

Documentation for currently supported engines can be found [here](/data/services/vault.devshift.net/config/secret-engines)

For more information please see [vault secrets engines documentation](https://www.vaultproject.io/docs/secrets/index.html)

##### KV Secrets engine Example
```yaml
---
$schema: /vault-config/secret-engine-1.yml

labels:
  service: vault.devshift.net

_path: "<SECRETS_ENGINE_MOUNT_PATH>"
type: "kv"
description: "new kv secrets engine"
options:
  _type: "kv"
  version: "2"
```

##### TOTP Secrets engine Example
```yaml
---
$schema: /vault-config/secret-engine-1.yml

labels:
  service: vault.devshift.net

_path: "totp/my-team/"
type: "totp"
description: "TOTP engine for my-team"
```

Register a new TOTP key given by a provider:
- Initiate the 2FA process at the desired provider
- Most provider will provide the OTP registration info via a QR code
- Read the QR Code with a QR Code reader app or extension. Android and iOS both have built-in QR code reader capabilities built into the Camera app.
  - Browser extensions are also available to decode QR codes but at the time of writing this all the ones I've seen are from questionable sources (& not official)
- Write the OTP info to vault. The URL parameter value is what is encoded in the QR Code
  ```sh
  # vault write totp/<my-team>/keys/<the-service> url="otpauth://totp/some-provider-otp:some-user-id?secret=some-secret&issuer=some-issuer&period=30"
  ```

Request a new TOTP code:
The TOTP engine cannot be interacted with via the Vault UI. The Vault CLI or API must be used
- Login to Vault
  ```sh
  vault login -method=oidc -address=https://vault.devshift.net
  ```
- Read a TOTP code
  ```sh
  vault read totp/<my-team>/code/<some-provider>
  ```

### Manage DNS Zones via App-Interface (`/*/dns-zone-1.yml`) using Terraform
We currently support Route53 DNS zones and Cloudflare DNS zones.
#### Route53 DNS Zones
 A Route53 DNS zone follows [this
JSON schema](https://github.com/app-sre/qontract-schemas/blob/main/schemas/dependencies/dns-zone-1.yml).

- `name`: A name for the DNS zone
- `description`: Description for the DNS zone
- `account`: a `$ref` to the account definition to be used in conjunction with the provider
- `vpc`: (optional) a `$ref` to a VPC to route traffic within. this will cause the hosted zone to be considered private
- `records`: A list of `record`. The parameters of the `record` match those of Terraform's [aws_route53_record resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record). In addition to the terraform fields, we also support special fields which are distinguishable by their name starting with `_` (underscore). The special fields are described below.
- `allowed_vault_secret_paths`: (optional) a list of the Vault secret paths that are permitted to be used in `_records_from_vault` entries

Additional special fields:
- `_target_cluster`: A `$ref` to an OpenShift cluster definition. The value of `elbFQDN` on the cluster definition will be used as a target on the record
- `_target_namespace_zone`: An object with a `$ref` to a namespace and a name of a zone defined under `externalResources` in the referenced namespace:
  ```yaml
  - name: <subdomain>
    ...
    _target_namespace_zone:
      namespace:
        $ref: /path/to/namespace.yml
      name: <subdomain>.example.org # example.com should match the zone this entry is added in
  ```
- `_healthcheck`: Allows defining a health check resource that will be assigned to the record. The parameters from Terraform's [aws_route53_health_check resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_health_check) are permitted.
- `_records_from_vault`: Allows the use of Vault secrets for the record value(s). **The only approved use case for this at the moment is domain control validation (DCV).** For instance, using the output from `terraform-cloudflare-resources`, this can be used to verify ownership of domains for Cloudflare ACM certificates.
  - `path`: Full path to the data in Vault
  - `field`: The field that contains the data
  - `key`: (optional) If the Vault data is formatted in JSON, the item in the object matching this key name will be selected
  ```yaml
  _records_from_vault:
    - path: app-sre/integrations-output/terraform-cloudflare-resources/app-sre-stage-01/dev-cloudflare/cloudflare-dev-app-sre-zone
      field: validation_records
      key: _acme-challenge.cloudflare-dev.app-sre.devshift.net
  ```

**NOTE:** If you need a record under the `api.openshift.com` zone
[please go to this document](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/add-route-for-ocm-component.md)

Example DNS zone resource:
```yaml
---
$schema: /dependencies/dns-zone-1.yml

labels: {}

name: example.com
description: This is an example

account:
  # The account under which the DNS zone will be created
  $ref: /aws/app-sre/account.yml

records:
# Simple record, flattened yaml (same line)
- { name: my-record, type: A, records: [127.0.0.1, 127.0.0.2, 127.0.0.3] }

# Simple record, indented yaml
- name: my-record
  type: A
  records:
  - 127.0.0.1
  - 127.0.0.2
  - 127.0.0.3

# Simple CNAME record using special parameter _target_cluster
- { name: my-cluster, type: CNAME, _target_cluster: { $ref: /openshift/my-cluster/cluster.yml } }

# Multiple weighted records (10%/90% weights)
- name: my-weighted-record
  type: CNAME
  ttl: 5
  weighted_routing_policy:
    weight: 90
  set_identifier: my-weighted-record-A
  records:
  - subA.example.com
- name: my-weighted-record
  type: CNAME
  ttl: 5
  weighted_routing_policy:
    weight: 10
  set_identifier: my-weighted-record-B
  records:
  - subB.example.com

# Multiple geolocation records
# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#geolocation-routing-policy
# and https://docs.aws.amazon.com/Route53/latest/APIReference/API_GetGeoLocation.html
- name: my-geolocation-record
  type: CNAME
  ttl: 5
  geolocation_routing_policy:
    continent: NA
  set_identifier: my-geolocation-record_app-sre-stage-01
  # records:
  # - subA.example.com
  _target_cluster: {$ref: /openshift/app-sre-stage-01/cluster.yml}
- name: my-geolocation-record
  type: CNAME
  ttl: 5
  geolocation_routing_policy:
    continent: EU
  set_identifier: my-geolocation-record_appsres04ue2
  _target_cluster: {$ref: /openshift/appsres04ue2/cluster.yml}
# This (country: "*") defines the default geolocation record
# See https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-geo.html#rrsets-values-geo-location
- name: my-geolocation-record
  type: CNAME
  ttl: 5
  geolocation_routing_policy:
    country: "*"
  set_identifier: my-geolocation-record_default
  _target_cluster: {$ref: /openshift/appsres04ue2/cluster.yml}


# Records with aliases (let you route traffic to selected AWS resources or from one record in a hosted zone to another record)
- name: my-aliased-record
  type: A
  alias:
    name: example.cloudfront.net
    zone_id: THISISNOTAZONEID
    evaluate_target_health: true

> Note: You can not use `ttl` or `records` with `alias`.

# Records with healthcheck (foo.example.com will be returned if healthy, otherwise bar.example.com will be returned)
- name: my-healthy-record
  type: CNAME
  ttl: 5
  records:
  - foo.example.com
  failover_routing_policy:
    type: PRIMARY
  _healthcheck:
    fqdn: foo.example.com
    port: 80
    type: HTTP
    resource_path: /
    failure_threshold: 5
    request_interval: 30
- name: my-healthy-record
  type: CNAME
  ttl: 5
  records:
  - bar.example.com
  failover_routing_policy:
    type: SECONDARY
  _healthcheck:
    fqdn: bar.example.com
    port: 80
    type: HTTP
    resource_path: /
    failure_threshold: 5
    request_interval: 30

# NS delegation (the records would be different depending on whats assigned to the delegated zone `my-delegation.example.com`)
- name: my-delegation
  type: NS
  records:
  - ns-660.awsdns-18.net
  - ns-508.awsdns-63.com
  - ns-1265.awsdns-30.org
  - ns-1880.awsdns-43.co.uk
```
#### Cloudflare DNS Zones
 A Cloudflare DNS zone follows [this
JSON schema](https://github.com/app-sre/qontract-schemas/blob/main/schemas/cloudflare/dns-zone-1.yml).

- `identifier`: A globally unique name for the zone.
- `zone`: Actual domain name.
- `delete`: Boolean. Use when deleting a zone. See below for example.
- `plan`: The name of the commercial plan to apply to the zone. Available values: free or enterprise.
- `account`: Cloudflare account this zone belong to.
- `type`: Available values: full, partial. This field should always be full. Full zone implies that DNS is hosted with Cloudflare. A partial zone is typically a partner-hosted zone or a CNAME setup.
- `max_records`: A upper limit of total number of the records allowed in this zone, and it should be larger then existing number of records. If unset, the value is default to the `cloudflareDNSZoneMaxRecords` setting in [App Interface settings](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/app-interface/app-interface-settings.yml). Changing this requires App SRE's approval, please see [Performance Section](#performance) for more information.
- `records`: A list of `record`. All parameters of the `record` match those of Terraform's [cloudflare_record](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) with an additional required parameter `identifier` that servers as a unique (within zone) identification for each record. The number of total records within a zone is limited by max_records mentioned above. See Performance section below for more informatiom. 


\* Note that the `identifier` field doesn't allow underscore, but it is a internal variable that we only recommend to be consistent with the record name. Feel free to replace it with dash if underscore is part of the name.

Example DNS zone resource:
```yaml
---
$schema: /cloudflare/dns-zone-1.yml

labels: {}

identifier: devshift

zone: devshift.net

type: full

account:
 $ref: /cloudflare/app-sre/account.yml

records:
# Simple CNAME record visualai.devshift.net
  - name: visualai
    identifier: visualai
    type: CNAME
    ttl: 300
    value: visual-app-interface.devshift.net
    proxied: true # All requests intended for proxied hostnames will go to Cloudflare first and then be forwarded to your origin server. This only applies to A, AAAA or CNAME records

# Simple TXT record
  - name: devshift-txt
    identifier: devshift-txt
    type: TXT
    ttl: 300
    value: printer=lpr5

# Simple MX record
  - name: devshift-mx
    identifier: devshift-mx1
    type: MX 
    ttl: 300
    value: mailhost1.example.com
    priority: 1

# NS records with multiple values
  - name: devshift-ns
    identifier: devshift-ns1
    type: NS 
    ttl: 300
    value: ns.example.com
    priority: 1
  - name: devshift-ns
    identifier: devshift-ns3
    type: NS 
    ttl: 300
    value: ns3.example.com
    priority: 3
```
##### Delete Cloudflare resource
* To delete a zone, first set the `delete: true` in the zone file with `deletionApprovals` for cloudflare_zone and cloudflare_zone_settings_override in the account file (See this [MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/62509/diffs) for example). Then remove the zone file in another MR. 
* To delete a record, simply remove the record related entries.
##### Performance
MR checks and reconciliation times will grow roughly linearly with zone size. We tested creating a zone with 1000 records took around 5 minutes. This has a broad impract on App Interface MR checks, therefore tenant teams are expected to ensure that the Cloudflare API token has the required capaciy to keep the MR checks at around 5-6 minutes run time.

### Manage AWS access via App-Interface (`/aws/group-1.yml`) using Terraform

[teams](/data/teams) contains all the teams that are being services by the App-SRE team. Inside of those directories, there is a `users` folder that lists all the `users` that are linked to that team. Each `user` has a list of assiciated `roles`. A `role` can be used to grant AWS access to a user, by adding the `user` to an AWS `group`.

Groups declaration enforce [this JSON schema](https://github.com/app-sre/qontract-schemas/blob/main/schemas/aws/group-1.yml). Note that it contains a reference to the AWS account in which the group exists.

Notes:
* Manual changes to AWS resources will be overridden by App-Interface in each run.
* A group without associated users will not be created.

#### Manage AWS users via App-Interface (`/aws/group-1.yml`) using Terraform

AWS users can be entirely self-serviced via App-Interface.

In order to get access to an AWS account, a user has to have:
* A public binary GPG key, which will be used to encrypt the generated password to send by mail.
* A `role` that includes (at least) one of the following:
  * An `aws_groups` section, with a reference to an AWS group file.
    * Example: [sre-aws](/data/teams/app-sre/roles/app-sre.yml) role.
  * A `user_policies` section, with a reference to a policy json document.
    * Example: [f8a-dev-osio-dev.yml](/data/teams/devtools/roles/f8a-dev-osio-dev.yml)
    * Supported terraform-like templates (will be replaced with correct values at run time):
      * `${aws:accountid}`
      * `${aws:username}`

Once a user is created, an email invitation to join the account will be sent with all relevant information.

#### Generating a GPG key

Note: If terminal cannot find `gpg` after install, your executable may be named `gpg2`.

1. Download and install the GPG command line tools for your operating system. We generally recommend installing the latest version for your operating system.
2. Open Terminal.
3. Generate a GPG key pair. Your key can be RSA or ECC.
```
$ gpg --full-generate-key
```
4. A series of prompts directs you through the process. Press the Enter key to assign a default value if desired.
      1. The first prompt asks you to select what kind of key you prefer. Select `RSA and RSA` or `ECC (sign and encrypt)`. It allows you not only to sign communications, but also to encrypt files.
      2. Choose the key size: `4096` (`RSA` path) or elliptic curve: `Curve 25519` (`ECC` path).
      3. Choose when the key will expire. You may set this to  `0 = key does not expire`.
      4. Before the gpg application asks for signature information, the following prompt appears: `Is this correct (y/N)?`. Review and enter `y`.
      5. Enter your name and email address for your GPG key. Remember this process is about authenticating you as a real individual. For this reason, include your real name.
      6. At the confirmation prompt, enter the letter O to continue if all entries are correct, or use the other options to fix any problems.
      7. Finally, enter a passphrase for your secret key. The gpg program asks you to enter your passphrase twice to ensure you made no typing errors.
5. Use the `gpg --list-secret-keys --keyid-format LONG` command to list GPG keys for which you have both a public and private key.

#### Adding your public GPG key

Note: If you cannot find the `gpg` binary in your terminal after installation, your executable may be named `gpg2`.

A Base64-encoded GPG key should be added to the user file under the `public_gpg_key` parameter.

To export your key as binary data to be then Base64-encoded, run:

```
gpg --export <redhat_username>@redhat.com | base64
```

To get your Base64-encoded binary GPG key from an [ASCII-armored](https://www.gnupg.org/gph/en/manual/x56.html) output, run:

```
cat <redhat_username>.gpg.asc | gpg --dearmor | base64
```

To test if your Base64-encoded GPG key in the Merge Request is valid, store the key in a file (i.e., `FILENAME`) and use the following command:

```
cat FILENAME | sed -e 's/\ //g'| base64 -d | gpg
```

Example: https://gitlab.cee.redhat.com/service/app-interface/blob/f40e0f27eacf5510a954c034292e937632caecc7/data/teams/app-sre/users/jmelisba.yml#L27

Note: Please **DO NOT** paste your GPG/PGP key as a single long string! If you have such an output, please wrap it to
preferably to be 64 characters wide (typical width when using ASCII-armored output) but no longer than 76 characters
wide (typical width when using the `base64` binary).

**WARNING**

If you intend to use the Base64-encoded portion of the ASCII-armored output (you have run e.g., `gpg --export --armor`,
or obtained the compliant output using other means), then please ensure that the CRC24 checksum that is appended at the
last line before the key tags is removed. This extra checksum is an extension only supported by various GPG/PGP software
and will work for vanilla Base64 decoders such as the commonly found `base64` binary. You can fold this long line using
the `fold` binary (available on both Linux and macOS) using the `-s -w64` recommended command-line switches.

### Manage external resources via App-Interface (`/openshift/namespace-1.yml`)

Design document: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/design-docs/additional-terraform-providers.md

[services](/data/services) contains all the services that are being run by the App-SRE team. Inside of those directories, there is a `namespaces` folder that lists all the `namespaces` that are linked to that service.

Namespaces declaration enforce [this JSON schema](https://github.com/app-sre/qontract-schemas/blob/main/schemas/openshift/namespace-1.yml). Note that it contains a reference to the cluster in which the namespace exists.

A namespace file may include an `externalResources` section. This section defines external resources required for the service running within the namespace to function. External resources are resources provisioned externally to the cluster, via a specified provisioner. Provisioners are entities in which resources are provisioned.

Supported provisioners:
- `aws`

In order to provision external resources, you need to add them to the `externalResources` section:
- `provider`: one of: `aws`.
- `provisioner`: The entity to provision resources in. The referenced item should be according to the `provider`:
    - `aws`: The AWS account you want to provision resources in.
    - `cloudflare`: The Cloudflare account you want to provision resources in.
- `resources`: a list of resources to provision. The items should be according to the `provider`:
    - `aws`: Same as described in the [Manage AWS resources via App-Interface](#manage-aws-resources-via-app-interface-openshiftnamespace-1yml-using-terraform) section, without `account`.
    - `cloudflare`: Same as described in the [Manage Cloudflare resources via App-Interface](#manage-cloudflare-resources-via-app-interface-openshiftnamespace-1yml-using-terraform) section, without `account`.

Notes:
* Manual changes to external resources will be overridden by App-Interface in each run.
* To be able to use this feature, the `managedExternalResources` field must exist and equal to `true`.
* Different provisioners may be implemented differently under the hood. For example, the `aws` provisioner is implemented using Terraform.

Future support for additional provisioners:
- CNA (Consuming the CNA service)
- GCP (Related to Hive GCP DNS zones)


### Manage AWS resources via App-Interface (`/openshift/namespace-1.yml`) using Terraform

[services](/data/services) contains all the services that are being run by the App-SRE team. Inside of those directories, there is a `namespaces` folder that lists all the `namespaces` that are linked to that service.

Namespaces declaration enforce [this JSON schema](https://github.com/app-sre/qontract-schemas/blob/main/schemas/openshift/namespace-1.yml). Note that it contains a reference to the cluster in which the namespace exists.

Notes:
* Manual changes to AWS resources will be overridden by App-Interface in each run.

#### AWS network configurations for security groups, subnet groups, and others

Some resources such as RDS and Elasticache will require security group and subnet configurations. For any cases where it's unclear which settings to use, check the [AWS network resources page](docs/aws/aws-network-resource-configs.md) to see if the account that you're deploying resources to is covered.

#### Manage shared AWS resources via App-interface (`/openshift/namespace-1.yml`) using Terraform

In the time of this writing, Terraform resources can not be added to a [shared resources file](#manage-shared-openshift-resources-via-app-interface-openshiftnamespace-1yml).

The work to enable that is tracked in https://issues.redhat.com/browse/APPSRE-2614.

To achieve a similar result, we can define a Terraform resource in a single namespace and add only the output Secret to other namespaces.

Instructions:

1. Submit a MR adding the resource to the `externalResources` section in one of the namespace files. Once the MR is merged, the output secret will be placed in the namespace AND in Vault.
  * The Vault secret has a predefined path: `app-sre/integrations-output/terraform-resources/<cluster_name>/<namespace_name>/<output_resource_name>`
1. Submit another MR [adding the Vault secret](#manage-secrets-via-app-interface-openshiftnamespace-1yml-using-vault) to the `openshiftResources` section in all other namespace files:
  ```yaml
  - provider: vault-secret
    path: app-sre/integrations-output/terraform-resources/<cluster_name>/<namespace_name>/<output_resource_name>
    version: 1
    annotations:
      qontract.ignore_reconcile_time: "true"
  ```

Bonus points:

Add the Vault secret to an `openshiftResources` section in a [shared resources file](#manage-shared-openshift-resources-via-app-interface-openshiftnamespace-1yml) and reference it from the `sharedResources` section of all other namespace files.

#### Manage AWS Certificate via App-Interface (`/openshift/namespace-1.yml`)

[AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) is a service that lets you easily provision, manage, and deploy public and private Secure Sockets Layer/Transport Layer Security (SSL/TLS) certificates.

In order to import certificates stored in Vault into AWS Certificate Manager, you need to add them to the `externalResources` field.

- `provider`: must be `acm`
- `identifier` - name of resource to create (or update)
- `secret`: Certificate store in Vault ([example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/dsaas/routes/_wildcard.api.openshift.io)) (optional)
  - `path`: vault path
  - `field`: `all`
  - `version`: (optional) for vault kv2
- `domain`: The domain information for the certificate. (optional)
  - `domain_name`: The name of the domain for which the certificate should be issued
  - `alternate_names`: A list of domains to include as SANs in the certficate
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-ssl" and `provider` is set to `acm`, the created Secret will be called `my-ssl-acm`.
- `annotations`: additional annotations to add to the output resource

NOTE: Either `secret` or `domain_name` must be provided, but not both.  Use `secret` to import a certificate from vault, and `domain` for AWS to create a certifcate

Once the changes are merged, the certificate will be imported into ACM and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:

- `arn` - Amazon Resource Name (ARN) of the Certificate.
- `domain_name` - The name of the domain this Certification is valid for.
- `status` - The status of the Certificate.

If `secret` was set above, then these fields will also be included:
- `key` - Certificate private key.
- `certificate` - Certificate body.
- `caCertificate` - Certificate chain if provided.

#### Manage AWS Secrets Manager via App-Interface (`/openshift/namespace-1.yml`)

[AWS Secrets Manager](https://aws.amazon.com/cn/secrets-manager/) helps you protect access to your applications, services, and IT resources. You can easily rotate, manage, and retrieve database credentials, API keys, and other secrets throughout their lifecycle.

In order to import secrets stored in Vault into AWS Secrets Manager, you need to add them to the `externalResources` field.

- `provider`: must be `secrets-manager`
- `identifier` - name of resource to create (or update)
- `secret`: secret store in Vault
  - `path`: vault path
  - `field`: `all`
  - `version`: (optional) required for vault kv2
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-secret" and `provider` is set to `secrets-manager`, the created Secret will be called `my-secret-secrets-manager`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the secret will be imported into Secrets Manager and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:

- `arn` - Amazon Resource Name (ARN) of the Secret.
- `version_id` - The unique identifier of the version of the secret.

#### Manage ElasticSearch via App-Interface (`/openshift/namespace-1.yml`)

[Amazon Elasticsearch Service](https://aws.amazon.com/elasticsearch-service/) is a fully managed service that makes it easy for you to deploy, secure, and run Elasticsearch cost effectively at scale. Amazon Elasticsearch can be entirely self-serviced via App-Interface.

In order to add or update Amazon Elasticsearch Service, you need to add them to the `externalResources` field.

- `provider`: must be `elasticsearch`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options](/resources/terraform/resources/)
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-service" and `provider` is set to `elasticsearch`, the created Secret will be called `my-service-elasticsearch`.
- `annotations`: additional annotations to add to the output resource

The `defaults` resource file will have a structure that follows closely the structure of the elasticsearch objects from the [terraform AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain), the only difference being the use of vault to store passwords instead of having them in clear text in app-interface. See the [elasticsearch-defaults-1.yml](https://github.com/app-sre/qontract-schemas/blob/main/schemas/aws/elasticsearch-defaults-1.yml) schema file for details of the exact fields that are supported.

Once the changes are merged, the Amazon Elasticsearch Service will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:

- `arn` - Amazon Resource Name (ARN) of the domain.
- `domain_id` - Unique identifier for the domain.
- `domain_name` - The name of the Elasticsearch domain.
- `endpoint` - Domain-specific endpoint used to submit index, search, and data upload requests.
- `kibana_endpoint` - Domain-specific endpoint for kibana without https scheme.
- `vpc_id` - If the domain was created inside a VPC, the ID of the VPC.

#### Manage RDS databases via App-Interface (`/openshift/namespace-1.yml`)

RDS instances can be entirely self-serviced via App-Interface.

App-Interface supports the following RDS engine types:

- postgres
- mysql

In order to create or update an RDS database, you need to add them to the `externalResources` field.

- `provider`: must be `rds`
- `identifier` - name of database instance to create (or update). Must be unique across all RDS instances in the AWS account.
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options](/resources/terraform/resources/)
- `parameter_group`: (optional) path relative to [resources](/resources) to a file with parameter group values. Note that it starts with `/`.
- `old_parameter_group`: (optional) path relative to [resources](/resources) to a file with parameter group values. Note that it starts with `/`. This field is only used during RDS major version upgrades and requires `parameter_group`.
- `overrides`: (optional) list of values from `defaults` you wish to override, with the override values. For example: `engine: mysql`.
- `replica_source`: (optional) indicates this will be a read replica with this identifier of an rds instance acting as the source
- `output_resource_name`: (optional) name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-instance" and `provider` "rds", the created Secret will be called `my-instance-rds`.
- `annotations`: additional annotations to add to the output resource
- `enhanced_monitoring`: (optional) Setting it to `true` will enable enhanced monitoring for the database instance. Learn more about enhanced monitoring [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html).
- `output_resource_db_name`: (optional) set the `db.name` key in the output Secret (does not affect actual terraform resource).
- `reset_password`: (optional) add or update this field to a random string to trigger a database password reset.
  - Note: removing this field will lead to a recycle of the pods using the output resource.
- `ca_cert`: (optional) specify `path`, `field` and `version` of a secret in vault containing a CA certificate to be added to the output Secret. Unless there is a good reason not to, use these settings:
  ```yaml
    ca_cert:
    path: app-interface/global/rds-ca-cert
    field: us-east-1 # region of the DB
    version: 2 # the latest available, search the repo for usage
  ```

Once the changes are merged, the RDS instance will be created (or updated) and a Kubernetes Secret will be created in the same namespace with following details.

- `db.host` - The hostname of the RDS instance.
- `db.port` - The database port.
- `db.name` - The database name.
- `db.user` - The master username for the database.
- `db.password` - Password for the master DB user.
- `db.ca_cert` - CA certificate for the DB (if `ca_cert` is defined).

##### Approved RDS versions

This section describes the database versions that are currently approved by AppSRE. These are only the minimum versions that are required due to significant security vulnerabilities. It is the responsibility of tenants to ensure that the minor version selected works with their service and does not lead to any regressions. Consider upgrading to more recent minor versions if you would benefit from bug fixes or there are security vulnerabilities that may not be a high risk to the majority of databases, but pose a unique risk due to certain features that you've enabled.

For more information about the versions that RDS supports:

* [PostgreSQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.DBVersions)
* [MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt)

**When creating a new database, it is typically suggested that you use the newest minor version possible.**

###### PostgreSQL

| Version | Minimum minor version | Notes                                                                                                                                                                                                      |
|---------|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 14      | \>= 14.3              | Announced as the minimum required version by email from AWS                                                                                                                                                |
| 13      | \>= 13.7              | Announced as the minimum required version by email from AWS                                                                                                                                                |
| 12      | \>= 12.11             | Announced as the minimum required version by email from AWS                                                                                                                                                |
| 11      | \>= 11.16             | Announced as the minimum required version by email from AWS                                                                                                                                                |
| ~~10~~  |                       | **End of life, do not use.**                                                                                                                                                 |

###### MySQL

| Version      | Minor Version | Notes |
| ----------- | ----------- | ----------- |
| 8 | \>= 8.0.23 | This is the minimum version required for the most recent release of [RDS OS upgrades](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#Mandatory_OS_Updates) |
| 5.7 | \>= 5.7.33 | This is the minimum version required for the most recent release of [RDS OS upgrades](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#Mandatory_OS_Updates) |

##### RDS minor version upgrades

This section provides guidance related to RDS minor version database engine upgrades. These minor version upgrades are typically required to mitigate security vulnerabilities and to ensure that teams have the latest bug fixes. See the [Approved RDS versions](#approved-rds-versions) section for more information about the minimum versions required by AppSRE. Tenants are responsible for keeping their databases up-to-date, but this section provides guidance on how to do so.

There are a few things to keep in mind before performing a minor version database engine upgrade:

* Minor version upgrades require a downtime - this downtime has been observed to be roughly 5 minutes, but this isn't strictly guaranteed by AWS. Multi-AZ does not reduce the downtime required by minor version upgrades because RDS upgrades the primary and standby instances simultaneously.
* Always test the upgrade on a stage database first. Minor version upgrades are typically backwards-compatible, but you should always **read the release notes** and test that there aren't any regressions in your service.
* Ensure that you've set an appropriate maintenance window as per the [Maintenance windows for RDS instances](#maintenance-windows-for-rds-instances) section

The documentation for performing upgrades can be found below:

* [Upgrade Minor Version for PostgreSQL RDS Instance](/docs/aws/sop/postgresql-rds-instance-minor-version-upgrade.md)

##### RDS major version upgrades

**Teams should not attempt this process without working closely with AppSRE. This is not a self-service process.**

Major version upgrades are typically quite involved, may include breaking changes, and require proper planning to be successful. It is not unusual to have hours of downtime for a major version upgrade. See the links below for documentation related to your database engine.

* [PostgreSQL major version upgrades](/docs/dba/postgresql-rds-instance-major-version-upgrade.md)

##### Maintenance windows for RDS instances

[RDS maintenance windows](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#Concepts.DBMaintenance) provide a weekly window during which any pending RDS instance changes can occur. This could include pending instance configuration changes, database engine version upgrades, or OS security upgrades.

The maintenance window for your RDS instance should be configured for a time that is determined to be appropriate for your service. You might consider several factors like when the peak load of your service is and the availability of your team in case there is any issue that needs to be escalated to you.

To set your maintenance window, add `maintenance_window` to your `defaults` file or `overrides` section for your resource. Documentation related to the format of the maintenance window string can be found by searching **PreferredMaintenanceWindow** [here](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_ModifyDBInstance.html#API_ModifyDBInstance_RequestParameters).

**Note:** RDS maintenance windows don't guarantee that the maintenance will complete before the window ends, particularly for operations such as major version upgrades. See the RDS maintenance windows documentation for more information.

##### Reset RDS database password

To reset the password of an RDS instance, add the `reset_password` field to the RDS definition according to the instructions in [Manage RDS databases via App-Interface](#manage-rds-databases-via-app-interface-openshiftnamespace-1yml).

Choose a value that represents a trace to why the password should be recycled (for example, a Jira ticket).

Note: You do not need to remove the `reset_password` field from the RDS definition once the password was recycled.

##### Restoring RDS databases from backups

This section covers the different options that are available when a database needs to be restored from backups. This might be required due to data corruption or failed database upgrades.

There are two high-level options for restoring a RDS database:

1. [Create RDS instance from a snapshot](/docs/aws/sop/create-rds-instance-from-snapshot.md) - use this option if you need to restore to a pre-upgrade or manual snapshot, or for other cases where data loss is not a major concern
2. [Restore RDS instance to a specific point in time](/docs/aws/sop/restore-rds-instance-to-specific-point-in-time.md) - use this option if you don't have a snapshot created right before the time you wish to restore to and want to minimize data loss (AWS ships transaction logs every 5 minutes, so data loss should be minimized)

Note that in both cases, restoring a backup will **result in a new database being created** (in-place restore isn't supported by RDS), but in most cases application-level changes aren't necessary because the `Secret` is updated as part of the process.

Merging a restored backup with data that was written after the backup was taken is not in the scope of this documentation. Teams that may have these needs should document application-specific disaster recovery instructions.

##### Publishing Database Log Files to CloudWatch

Database logs for MySQL and PostgreSQL can be configured to be published to CloudWatch where developers can look at the logs to identify & troubleshoot slow queries.

##### Publishing MySQL Logs to CloudWatch Logs

You can publish `audit`, `general`, `slowquery`, and `error` logs to CloudWatch for MySQL RDS instances by adding the following to your RDS specification file:

```yaml
enabled_cloudwatch_logs_exports: ["audit","error","general","slowquery"]
```

Amazon RDS publishes each MySQL database log as a separate database stream in the log group. For example, if you configure the export function to include the slow query log, slow query data is stored in a slow query log stream in the `/aws/rds/instance/my_instance/slowquery` log group.

Additonal details can be found in AWS [documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.MySQL.html).

##### Publishing PostgreSQL Logs to CloudWatch Logs

AWS does not break down RDS logs for PostgreSQL into `error`, `slowquery`, `audit`, etc. categories for logs. The only log options available for PostgreSQL RDS instances are `postgresql`, and `upgrade`.

You can publish `postgresql` and `upgrade` logs to CloudWatch for PostgreSQL RDS instances by adding the following to your RDS specification file:

```yaml
enabled_cloudwatch_logs_exports: ["postgresql","upgrade"].
```


To publish slow query logs to cloudwatch, we must first configure logging parameters for the RDS instance. RDS instance must be configured to use a custom parameter group. If this is not the case, we must first attach a custom parameter group to the database. To enable query logging for your PostgreSQL DB instance, set one of the two parameters in the DB parameter group associated with your DB instance: `log_statement` or `log_min_duration_statement`.

The `log_statement` parameter controls which SQL statements are logged. We recommend that you set this parameter to `all` to log `all` statements when you debug issues in your DB instance. The default value is `none`. To log all data definition language (DDL) statements (CREATE, ALTER, DROP, and so on), set this value to `ddl`. To log all DDL and data modification language (DML) statements (INSERT, UPDATE, DELETE, and so on), set this value to `mod`. **Be aware that this can quickly fill in the storage space of your RDS instance with logs**.

Default log retention is 3 days. If your database runs out of space due to logs, there is no other option than to disable the logs and increase the database size. So keep an eye on the size after enabling it! See AWS [documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.PostgreSQL.html#USER_LogAccess.PostgreSQL.log_retention_period).

The `log_min_duration_statement` parameter sets the limit in milliseconds of a statement to be logged. All SQL statements that run longer than the parameter setting are logged. This parameter is disabled and set to `-1` by default. Enabling this parameter can help you find unoptimized queries. See PostgreSQL [documentation](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-DURATION-STATEMENT).

After you complete the configuration, Amazon RDS publishes the log events to log streams within a CloudWatch log group. For example, the PostgreSQL log data is stored within the log group `/aws/rds/instance/my_instance/postgresql`.

Additional details can be found in AWS [documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.PostgreSQL.html#USER_LogAccess.PostgreSQL.Query_Logging).

##### Configuring access policies for Performance Insights

To access Performance Insights you should have a `role` assigned to your user file with a `user_policies` section that includes a reference to a `performance-insights-access` AWS user policy.

If the policy does not exist for the AWS account, add it.

[Example](/data/aws/insights-prod/policies/PerformanceInsights.yml) for a `performance-insights-access` AWS policy.

Additional details can be found in AWS [documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.access-control.html).

##### Subscribe to RDS event notifications

Currently we support email subscription to [RDS event notifications](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.overview.html). There are two steps invovled:

**Step 1.** Define a SNS topic along side with your RDS instance defination. For example:
```
 - provider: sns 
    identifier: test-sns-1 
    defaults: *.yml
    subscriptions:
    - protocol: email
      endpoint: janedoe@redhat.com
```
Note that the default file need to be present but no value necessary. Currently `email` is the only supported protocol.
**Step 2.** Define `event_notifications` for your RDS instance using the SNS topic identifier you defined above in the `destination` field:
```
 - provider: rds
    identifier: * 
    defaults: *.yml
    output_resource_name: * 
    event_notifications:
    - destination: test-sns-1
      source_type: db-instance
      event_categories: 
        - deletion
        - failover
        - maintenance
```
Note that `destination` should be the name of the SNS topic instead of its ARN. For `source_type`, following six options are supported:
```
db-instance
db-security-group
db-parameter-group
db-snapshot
db-cluster
db-cluster-snapshot
```
See this [AWS document](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.overview.html) for more information about what type of events you can subscribe to.
You can use this [MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/44428/diffs#fd3473d3c2ca1a88f2a9df55aa89ce7027ab5af1) as example. Once your MR is merged, the emails listed in your SNS defination should receive an  email from AWS requesting subscription confirmation.

#### Manage S3 buckets via App-Interface (`/openshift/namespace-1.yml`)

S3 buckets can be entirely self-serviced via App-Interface.

In order to add or update an S3 bucket, you need to add them to the `externalResources` field.

- `provider`: must be `s3`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
- `overrides`: list of values from `defaults` you wish to override, with the override values. For example: `acl: public`.
- `event_notifications`(Optional): a list of configurations to create S3 notification to SQS or SNS. It can contain the following fields:
  - `destination_type`: can be `sns` or `sqs`.
  - `destination`: can be either the name of the queue/topic or its arn.
  - `event_type`: a list of events such as `s3:ObjectCreated:*`.
  - `filter_prefix`(Optional): Prefix filter for the target's name.
  - `filter_suffix`(Optional): Suffix filter for the target's name.

  Example of `event_notifications`:
  ```
  event_notifications:
      - destination_type: sns
        destination: arn:aws:sns:us-east-1:123456789:test-sns-1
        event_type:
          - s3:ObjectCreated:*
  ```
- `sqs_identifier`(Deprecating soon, please use `event_notifications`): identifier of a existing sqs queue. It will create a s3 notifacation to that sqs queue. This field is optional.
- `s3_events`: a listing of the event types for sqs queue.
- `bucket_policy`: an AWS bucket policy to create and attach to the s3 bucket.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-bucket" and `provider` "s3", the created Secret will be called `my-bucket-s3`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the S3 bucket will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `bucket` - The name of the bucket.
- `aws_region` - The name of the bucket's AWS region.
- `endpoint` - The url of the region's S3 endpoint.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.

#### Manage ElastiCache databases via App-Interface (`/openshift/namespace-1.yml`)

ElastiCache (HA) clusters can be entirely self-serviced via App-Interface.

In order to add or update an ElastiCache database, you need to add them to the `externalResources` field.

- `provider`: must be `elasticache`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options](/resources/terraform/resources/)
  - This defaults file must have `auto_minor_version_upgrade: false` field, otherwise you will run into validation error.
    Please see [deprecation_notice](/docs/app-sre/deprecation/deprecate-rds-auto-minor-version-upgrade.md)
  ```
  True is not one of [False]\n\nFailed validating 'enum' in schema['properties']['auto_minor_version_upgrade']:\n    {'enum': [False], 'type': 'boolean'}\n\nOn instance['auto_minor_version_upgrade']:\n    True
  ``` 
- `parameter_group`: (optional) path relative to [resources](/resources) to a file with parameter group values. Note that it starts with `/`.
- `overrides`: list of values from `defaults` you wish to override, with the override values. For example: `engine_version: 5.0.3`.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-cluster" and `provider` "elasticache", the created Secret will be called `my-cluster-elasticache`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the ElastiCache clusters will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `db.endpoint` - The configuration endpoint of the ElastiCache cluster.
- `db.port` - The database port.
- `db.auth_token` - Authentication token for in-transit encryption, if `transit_encryption_enabled` is set to `true`.

Notes:
- To provision an instance with cluster mode enabled, it is mandatory to define `cluster_mode.num_node_groups` and `cluster_mode.replicas_per_node_group` in the defaults file.

#### Manage IAM Service account users via App-Interface (`/openshift/namespace-1.yml`)

IAM users to be used as service accounts can be entirely self-serviced via App-Interface.

In order to add or update a service account, you need to add them to the `externalResources` field.

- `provider`: must be `aws-iam-service-account`
- `identifier`: name of resource to create (or update)
- `variables`: list of key-value pairs to use for templating of `user_policy`. these pairs will also be added to the output resource.
- `policies`: list of AWS policies you wish to attach to the service account user.
- `user_policy`: an AWS user policy to create and attach to the service account user.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-user" and `provider` "aws-iam-service-account", the created Secret will be called `my-user-aws-iam-service-account`.
- `annotations`: additional annotations to add to the output resource
- `aws_infrastructure_access`: (optional) grant the created IAM user AWS Infrastructure access via OCM:
  - `cluster`: reference to the cluster you want to grant infrastructure access to
  - `access_level`: level of access to grant (currently either read-only or network-mgmt)

Once the changes are merged, the IAM resources will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.
- `role_arn` - (optional) the role ARN to assume if `aws_infrastructure_access` is defined.
  * Note: this key will be added after the AWS infrastructure access is granted successfully.

In addition, any additional key-value pairs defined under `variables` will be added to the Secret.

#### Manage Secrets Manager Service account users via App-Interface (`/openshift/namespace-1.yml`)

IAM users for Secrets Manager to be used as service accounts can be entirely self-serviced via App-Interface.

In order to add or update a service account, you need to add them to the `externalResources` field.

The IAM user can only create/delete/retrieve secrets with a name beginning with "`secrets_prefix`/", but it will get all secrets in the account for ListSecrets. We suggest add a name filter when using [ListSecrets](https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_ListSecrets.html#API_ListSecrets_RequestSyntax).

- `provider`: must be `secrets-manager-service-account`
- `identifier`: name of resource to create (or update)
- `secrets_prefix`: prefix to use before all managed secret names in aws Secrets Manager. the trailing slash is added in the code.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-user" and `provider` "aws-iam-service-account", the created Secret will be called `my-user-secrets-manager-service-account`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the IAM resources will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.
- `secrets_prefix` - prefix to use before all managed secret names


#### Manage IAM Roles via App-Interface (`/openshift/namespace-1.yml`)

Roles to be assumed can be entirely self-serviced via App-Interface.

In order to add or update a role, you need to add them to the `externalResources` field.

- `provider`: must be `aws-iam-role`
- `identifier`: name of resource to create (or update)
- `assume_role`: trusted entities can assume this role. Require one of the following.
  - `AWS`: list ARN of iam users or accounts
  - `Service`: list of AWS services
- `inline_policy`: (optional) an AWS policy to create and attach to the role. (requires AWS provider plugin version 3.30.0 or above)
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-role" and `provider` "aws-iam-role", the created Secret will be called `my-role-aws-iam-role`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the IAM resources will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `role_arn` - the role ARN to assume

#### Manage SQS queues via App-Interface (`/openshift/namespace-1.yml`)

SQS queues can be entirely self-serviced via App-Interface.

In order to add or update an SQS queue, you need to add them to the `externalResources` field.

- `provider`: must be `sqs`
- `identifier` - a name of the group of resources to create (or update)
  - Does not affect names of queues.
  - Will be used as the name of the IAM user that will be created.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-queue" and `provider` "sqs", the created Secret will be called `my-queue-sqs`.
- `annotations`: additional annotations to add to the output resource
- `specs`: list of queue specifications to create:
  - `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
  - `queues`: list of queues to create according to the defined defaults:
    - `key` is the key to be added to the Secret
    - `value` is the name of the table to create

Once the changes are merged, the SQS queue will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.
- `aws_region` - The name of the queue's AWS region.

In addition, for each queue defined under `queues`, a key will be created and will contain the queue url. The key is the value defined in `key`.

#### Manage DynamoDB tables via App-Interface (`/openshift/namespace-1.yml`)

DynamoDB tables can be entirely self-serviced via App-Interface.

In order to add or update a DynamoDB table, you need to add them to the `externalResources` field.

- `provider`: must be `dynamodb`
- `identifier` - a name of the group of resources to create (or update)
  - Does not affect names of tables.
  - Will be used as the name of the IAM user that will be created.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-table" and `provider` "dynamodb", the created Secret will be called `my-table-dynamodb`.
- `annotations`: additional annotations to add to the output resource
- `specs`: list of table specifications to create:
  - `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
  - `tables`: list of tables to create according to the defined defaults:
    - `key` is the key to be added to the Secret
    - `value` is the name of the table to create

Once the changes are merged, the DynamoDB table will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.
- `aws_region` - The name of the queue's AWS region.
- `endpoint` - The DynamoDB endpoint URL.

In addition, for each table defined under `tables`, a key will be created and will contain the table name. The key is the value defined in `key`.

#### Manage ECR repositories via App-Interface (`/openshift/namespace-1.yml`)

ECR repositories can be entirely self-serviced via App-Interface.

In order to add or update an ECR repository, you need to add them to the `externalResources` field.

- `provider`: must be `ecr`
- `identifier` - name of resource to create (or update)
- `public`: (optional) - should the repository be public (requires AWS provider plugin version 3.30.0 or above)
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-repo" and `provider` "ecr", the created Secret will be called `my-repo-ecr`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the ECR repository will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `url` - The url of the repository.
- `aws_region` - The name of the repository's AWS region.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.

#### Manage stacks of S3 bucket and CloudFront distribution via App-Interface (`/openshift/namespace-1.yml`)

Stacks of an S3 bucket with a CloudFront distribution can be entirely self-serviced via App-Interface.

In order to add or update an S3+CloudFront stack, you need to add them to the `externalResources` field.

- `provider`: must be `s3-cloudfront`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-s3-cf-stack" and `provider` "s3-cloudfront", the created Secret will be called `my-s3-cf-stack-s3-cloudfront`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the resources will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `bucket` - The name of the bucket.
- `aws_region` - The name of the bucket's AWS region.
- `endpoint` - The url of the region's S3 endpoint.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.
- `cloud_front_origin_access_identity_id` - The identifier for the distribution.
- `s3_canonical_user_id` - The Amazon S3 canonical user ID for the origin access identity.
- `distribution_domain` - The domain name corresponding to the distribution.
- `origin_access_identity` - The origin access identity in the form of `origin-access-identity/cloudfront/<cloud_front_origin_access_identity_id>`.

CloudFront distribution [logging_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#logging_config) is supported. This allows to store CloudFront logs into an S3 bucket.
- The S3 bucket used for logging must be created in app-interface. Since [specific ACLs are needed for CloudFront logging](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership), the logging S3 bucket configuration should *not* contain any `acl` field (eg, do *not* set `acl: private`). These ACLs will be handled automatically.
- The `s3-cloufront` configuration must refer to the logging S3 bucket with the [standard terraform logging_config arguments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#logging-config-arguments). Note that the `bucket` argument should be the logging S3 bucket *hostname*, in the form `<bucket-identifer>.s3.amazonaws.com`.

#### Manage CloudFront Public Keys via App-Interface (`/openshift/namespace-1.yml`)

CloudFront Public Keys can be self-serviced via App-Interface.  Once created in AWS, the public key will need to be manually associated with a `Key group` and then that `Key group` manually associated with a CloudFront Distribution to sign URLs or cookies.

- `provider`: must be `s3-cloudfront-public-key`
- `identifier`: name of resource to create (or update)
- `secret`: Certificate store in Vault
  - `path`: vault path
  - `field`: `all`
  - `version`: (optional) for vault kv2
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-key" and `provider` is set to `s3-cloudfront-public-key`, the created Secret will be called `my-key-s3-cloudfront-public-key`
- `annotations`: additional annotations to add to the output resource

The `secret` must have the key `cloudfront_public_key` that contains the public key to be uploaded to AWS.

Once the changes are merged, the public key will be imported into CloudFront Public Keys and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:

- `id` - The AWS identifier for the public key.
- `etag` - The current version of the public key.
- `key` - The public key.

#### Manage CloudWatch Log Groups via App-Interface (`/openshift/namespace-1.yml`)

CloudWatch Log Groups can be entirely self-serviced via App-Interface.

In order to add or update an CloudWatch Log Group, you need to add them to the `externalResources` field.

- `provider`: must be `cloudwatch`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
- `es_identifier`: identifier of a existing elasticsearch. It will create a AWS lambda to stream logs to elasticsearch service. This field is optional.
- `filter_pattern`: filter pattern for log data. Only works with streaming logs to elasticsearch.
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-log-group" and `provider` "cloudwatch", the created Secret will be called `my-log-group-cloudwatch`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the CloudWatch Log Group will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `log_group_name` - The name of the CloudWatch Log Group.
- `aws_region` - The name of the Log group's AWS region.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.

#### Manage Key Management Service Keys via App-Interface (`/openshift/namespace-1.yml`)

Key Management Service keys can be entirely self-serviced via App-Interface.

In order to add or update a Key Management Service key, you need to add them to the `externalResources` field.

- `provider`: must be `kms`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options:](/resources/terraform/resources/)
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-key" and `provider` "kms", the created Secret will be called `my-key-kms`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the Key Management Service key will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `key_id` - The globally unique identifier for the key.

#### Manage Kinesis Streams via App-Interface (`/openshift/namespace-1.yml`)

Kinesis Streams can be entirely self-services via App-Interface.

In order to add or update a Kinesis Stream, you need to add them to the `externalResources` field.

- `provider`: must be `kinesis`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options](/resources/terraform/resources/)
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-stream" and `provider` "kinesis", the created Secret will be called `my-stream-kinesis`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the Kinesis Stream will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `stream_name` - The name of the stream.
- `aws_region` - The name of the stream's AWS region.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.

#### Manage AWS Autoscaling Group via App-Interface (`/openshift/namespace-1.yml`)

[AWS Autoscaling Group](https://aws.amazon.com/autoscaling/) monitors your applications and automatically adjusts capacity to maintain steady, predictable performance at the lowest possible cost.

In order to add or update an Autoscaling Group, you need to add them to the `externalResources` field.

- `provider`: must be `asg`
- `identifier` - name of asg to create (or update)
- `defaults`: path relative to [resources](/resources) to a file with default values. Note that it starts with `/`. [Current options](https://github.com/app-sre/qontract-schemas/blob/main/schemas/aws/asg-defaults-1.yml)
- `variables`: list of key-value pairs to use for templating of `cloudinit_configs`.
- `cloudinit_configs` - List of multiple parts which adds a file to the generated cloud-init configuration.
  - `filename` - (Optional) A filename to report in the header for the part.
  - `content_type` - (Optional) A MIME-style content type to report in the header for the part.
  - `content` - path relative to [resources](/resources) to a file with body content for the part. Supported `extracurlyjinja2` templates (will be replaced with correct values at run time) with following example delimiters:
    - `{{{ aws_region }}}`
    - `{{{ aws_account_id }}}`
    - `{{{ key from variables }}}`
    - `{{{ vault(path, key) }}}`
    - `{{% jinja func %}}`
- `output_resource_name`: name of Kubernetes Secret to be created.
  - `output_resource_name` must be unique across a single namespace (a single secret can **NOT** contain multiple outputs).
  - If `output_resource_name` is not defined, the name of the secret will be `<identifier>-<provider>`.
    - For example, for a resource with `identifier` "my-app" and `provider` is set to `asg`, the created Secret will be called `my-app-asg`.
- `annotations`: additional annotations to add to the output resource

Once the changes are merged, the Autoscaling Group will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:

- `template_latest_version` - The latest version of the launch template.

#### Manage External DNS zones via App-Interface (`/openshift/namespace-1.yml`)

DNS zones are a required Cloud Native Asset for some applications, such as Hive. In this use case, the application needs an empty DNS zone, which itself will populate.

In order to add a DNS zone, you need to add them to the `externalResources` section:

- `provider`: must be `route53-zone`
- `identifier`: id of the resource to create (example: `dns-example-com`)
- `name`: name of the resource to create (example: `dns.example.com`)
- `output_resource_name`: name of Kubernetes Secret to be created.
- `records`: (optional) same as `records` in [Route53 DNS Zones](#route53-dns-zones), but without support for additional special fields.

Once the changes are merged, the DNS zone will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.

The Secret will contain the following fields:
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.

#### Manage Application Load Balancers via App-Interface (`/openshift/cluster-1.yml`)

Please follow the dev-guidelines: https://service.pages.redhat.com/dev-guidelines/docs/appsre/advanced/manage-application-load-balancer

#### Enable deletion of AWS resources in deletion protected accounts

Most AWS accounts managed via app-interface are protected against resource deletions (`enableDeletion: true` or undefined, defaults to true).

In case a resource needs to be deleted from such an account, you can enable the deletion by adding a new entry to a `deletionApprovals` section in an AWS account file. For example:
  ```yaml
  deletionApprovals:
  - type: aws_db_instance
    name: db-name-to-delete
    expiration: '2021-12-31' # YYYY-MM-dd
  ```

Such an entry will enable this specific resource to be deleted even if the account does not have deletion enabled.

When submitting a MR to delete a resource which results in a build failure, look at the logs and find lines such as `['delete', '<account_name>', '<resource_type>', '<resource_name>']`. For each line (will also include an error such as `'delete' action is not enabled.`) - add an entry to the `deletionApprovals` list.

### Manage Cloudflare user access via App-Interface using Terraform

The `terraform-cloudflare-users` integration is used to provide access to [Cloudflare](https://www.cloudflare.com/) accounts.

In order to provide access to Cloudflare accounts registered in App-Interface, you need to [sign up for a Cloudflare account](https://www.cloudflare.com/) with
your `@redhat.com` email address. Note, access is only granted to users who register with `@redhat.com` email address.

Once you have registered the user, you can follow these steps.
1. Add `cloudflare_user` field in your user file (`/access/user-1.yml`) and set it to your registered `@redhat.com` email.
1. Create a cloudflare role (`/cloudflare/account-role-1.yml`), link it to your account and list the relevant roles. Cloudflare account administrators should have visibility into all roles available through Cloudflare UI. If the cloudflare role already exists you can skip this step.

    Example
    ```
    ---
    $schema: /cloudflare/account-role-1.yml

    account: 
      $ref: /path/to/your/cloudflare/account.yml

    name: dummy-cloudflare-admin-read-only
    description: Read-only access to the dummy Cloudflare account

    roles:
      - 'Administrator Read Only'

    ```
1. Associate newly created Cloudflare role (`/cloudflare/account-role-1.yml`) to access role (`/access/role-1.yml`) with `cloudflare_access` field.

    Example
    ```
    ---
    $schema: /access/role-1.yml
    ...
    cloudflare_access:
    - $ref: /path/to/your/cloudflare/role.yml
    ...

    ```

### Manage Cloudflare resources via App-Interface (`/openshift/namespace-1.yml`) using Terraform

The `terraform-cloudflare-resources` integration is used to provision [Cloudflare](https://www.cloudflare.com/) services.

In order to provision Cloudflare resources, you need to add them to the `externalResources` field in a `namespace` file.

- `provider`: must be `cloudflare`
- `provisioner`: must be a `$ref` to a `/cloudflare/account-1.yml` file
- `resources`: list of Cloudflare resources to provision

### Manage Cloudflare Zone via App-Interface (`/openshift/namespace-1.yml`) using Terraform

The Cloudflare Zone definition follows the Cloudflare Terraform provider [zone definition](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone)

When provisioning a new zone, it is necessary to change the domain nameservers to use the Cloudflare nameservers that are assigned to that zone. Those nameservers are returned by Terraform as output data but are currently not visible anywhere. An AppSRE team member can login to the Cloudflare account to retrieve the nameservers. Note: when using a `partial` type zone, nameservers do NOT need to be changed but some Cloudflare features are unavailable (see cloudflare docs).

When provisioning certificates with [Cloudflare ACM](https://developers.cloudflare.com/ssl/edge-certificates/advanced-certificate-manager/) you will need to prove ownership of the domain by creating TXT records. These challenge record values are currently only available in the console, but an AppSRE team member can assist in providing these. The TXT record(s) can be created in the `/dependencies/dns-zone-1.yml` file managing the DNS zone in question.

- `provider`: `zone`
- `identifier`: a unique identifier for the zone (terraform identifier)
- `zone`: a valid domain name
- `plan`: `free` or `enterprise` (an enterprise account is required to enable the later)
- `type`: `full` or `partial` (when you only want Cloudflare on some specific CNAME records)
- `settings`: (Optional) See the Cloudflare Terraform provider docs for [cloudflare_zone_settings_override](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone_settings_override) for a list of available options. **Note:** be sure to quote any on/off values (`'on'` or `'off'`), otherwise in YAML they will turn into booleans and will be rejected by the Cloudflare API.
- `argo`: (Optional) Settings either or both of these options will enable Cloudflare Argo on the zone (an enterprise account is required)
  - `smart_routing`: `on` or `off`
  - `tiered_caching`: `on` or `off`
- `tiered_cache`: (Optional) Manages Cloudflare Tiered Cache settings. This allows you to adjust topologies for your zone
  - `cache_type`: One of: `generic`, `smart`
- `cache_reserve`: (Optional) Control Cloudflare [Cache Reserve](https://developers.cloudflare.com/cache/about/cache-reserve/) options on a zone. **Setting this currently does nothing. See the [Cloudflare Runbook](/docs/app-sre/runbook/cloudflare.md) for more info**
  - `enabled`: `on` or `off`
- `records`: A list of records to provision
  - `name`: name of the record
  - `type`: ex: `A`, `CNAME`
  - `ttl`: Record's TTL (must be set to 1 for CNAME)
  - `value`: The records target
  - `proxied`: (Optional) Whether the record should get Cloudflare origin protection (enable or disable Cloudflare on the record)
- `workers`: (Optional) A list of Cloudflare workers to provision 
  - `identifier`: a unique identifier for the worker (terraform identifier)
  - `pattern`: The URL pattern that the worker will act on (ex: `mydomain.com/some/path/*`)
  - `script_name`: The name of the worker script that this worker will use to process requests (must be defined and match the name of a worker script resource)
- `certificates`: (Optional) A list of Cloudflare certificates to provision for the zone. See the [DCV docs](#domain-control-validation-dcv-for-cloudflare-certificates) for verifying domain ownership.
  - `identifier`: a unique identifier for the certificate (terraform identifier)
  - `type`: the type of certificate (currently supports `advanced` for [Cloudflare ACM certificates](https://developers.cloudflare.com/ssl/edge-certificates/advanced-certificate-manager/))
  - `certificate_authority`: certificate authority to issue the certificate. `lets_encrypt` is the only value that is currently supported.
  - `hosts`: list of hostnames to provision the certificate for. If using Let's Encrypt, this must not contain more than 2 entries, one matching the zone name, and the other a subdomain or the subdomain wildcard (ex. `my.zone.com` and `*.my.zone.com`, or `my.zone.com` and `something.my.zone.com`)
  - `validation_method`: validation method to use in order to prove domain ownership. Let's Encrypt only supports `txt`.
  - `validity_days`: how long the certificate is valid for. Let's Encrypt only supports `90`.
  - `cloudflare_branding`: (default **false**) whether to include Cloudflare branding. This will add sni.cloudflaressl.com as the Common Name.
  - `wait_for_active_status`: (default **false**) whether to wait for a certificate pack to reach status active during creation. Note that if this takes longer than expected it could block other changes within your account.

#### Domain Control Validation (DCV) for Cloudflare Certificates

When provisioning certificates with [Cloudflare ACM](https://developers.cloudflare.com/ssl/edge-certificates/advanced-certificate-manager/) you will need to prove ownership of the domain by creating TXT records if the DNS is not hosted at Cloudflare.

If the DNS is hosted in a Route53 zone, you can configure the DCV record(s) as seen in the example below:

```yaml
---
$schema: /dependencies/dns-zone-1.yml

labels: {}

name: <your domain>
description: <some description>

# A list of all paths used below in _records_from_vault
allowed_vault_secret_paths:
- app-sre/integrations-output/terraform-cloudflare-resources/app-sre-stage-01/dev-cloudflare/cloudflare-dev-app-sre-zone

records:
- name: _acme-challenge.cloudflare-dev.app-sre
  type: TXT
  _records_from_vault:
    - path: app-sre/integrations-output/terraform-cloudflare-resources/app-sre-stage-01/dev-cloudflare/cloudflare-dev-app-sre-zone
      field: validation_records
      key: _acme-challenge.cloudflare-dev.app-sre.devshift.net

- name: _acme-challenge.cdn01.cloudflare-dev.app-sre
  type: TXT
  _records_from_vault:
    - path: app-sre/integrations-output/terraform-cloudflare-resources/app-sre-stage-01/dev-cloudflare/cloudflare-dev-app-sre-zone
      field: validation_records
      key: _acme-challenge.cdn01.cloudflare-dev.app-sre.devshift.net
```

The Vault `path` will be: `app-sre/integrations-output/terraform-cloudflare-resources/<cluster_name>/<namespace>/<zone_identifier>-zone`

The `field` will always be `validation_records` and the `key` will be the value of the SANs on the certificate, prefixed with `_acme-challenge`.

### Manage Cloudflare Worker Scripts via App-Interface (`/openshift/namespace-1.yml`) using Terraform

The Cloudflare Worker Scripts definition follows the Cloudflare Terraform provider [worker script definition](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/worker_script)

Worker scripts are programs that will process requests and possibly change them as they pass through Cloudflare

- `provider`: `worker_script`
- `identifier`: a unique identifier for the zone (terraform identifier)
- `name`: name of the script (must match with the `script_name` set on a worker within a zone resource definition)
- `content_from_github`: Fetch the script content from a GitHub repository
  - `repo`: URL of the repo (ex: `https://github.com/app-sre/cfworkerdemo`)
  - `path`: path to the script file within the repo (only a single file is supported at the moment)
  - `ref`: SHA of the commit we want deployed (branch or tag not supported)
- `vars`: (Optional) Variables that we want to pass to the worker script as environment variables
  - `name`: Name of the variable
  - `text`: Value of the variable

### Manage Cloudflare Logpush and Logpull configuration using Terraform
Cloudflare products generate metadata which can be used for purposes such as debugging, identifying configuration adjustments, and creating analytics etc. 
Cloudflare has (features)[https://developers.cloudflare.com/logs/#features] that allows these logs to be accessible through different means. You can refer to the Cloudflare docs on how those features can be useful to you.

App-interface currently supports following Terraform resources for Logpush and Logpull configuration.
#### Logpush
Cloudflare [Logpush](https://developers.cloudflare.com/logs/about/) supports pushing logs to storage services, SIEMs, and log management providers via the Cloudflare dashboard or API.

Configuring Logpush is a two step process (for some destinations) with app-interface.
1. Create a MR with Logpush ownership challenge as documented below and merge it. Note: You can skip this step, if the Logpush [destination](https://developers.cloudflare.com/logs/get-started/enable-destinations/) does not require ownership challenge. 
1. Create a MR with Logpush job resource and merge it. 
##### Logpush ownership challenge resource

Certain Logpush [destinations](https://developers.cloudflare.com/logs/get-started/enable-destinations/) require proof of ownership. You can configure ownership challenge through [`logpush_ownership_challenge`](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/logpush_ownership_challenge) Terraform resource.

Following is an example, please set attribute values as per your needs.
```yaml
- provider: cloudflare
  provisioner:
    $ref: /cloudflare/app-sre/account.yml
  resources:
  # For zone level resource
  - provider: logpush_ownership_challenge
    identifier: test-logpush-challenge
    zone: test-zone
    destination_conf: s3://bucket/logs?region=us-east-1&sse=AES256 # Update this according to your destination
  # For account level resource
  - provider: logpush_ownership_challenge
    identifier: test-logpush-challenge
    destination_conf: s3://bucket/logs?region=us-east-1&sse=AES256 # Update this according to your destination
```

Note: Currently we only support `S3` for Logpush destination. Please see additional resources for setting up bucket policy required for `S3` destination before creating ownership challenge.

Once the logpush_ownership_challenge is configured, you can manually inspect the destination to obtain the ownership token which is used during the creation of `logpush_job`.

Additional resource:
- [Cloudflare destination](https://developers.cloudflare.com/logs/get-started/api-configuration/#destination)
- [S3 Destination Pre-requisite](https://developers.cloudflare.com/logs/get-started/enable-destinations/aws-s3/#manage-via-api)

##### Logpush job resource
The Cloudflare Logpush job resource definition follows [`logpush_job`](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/logpush_job) Terraform resource.

Following is an example, please set attribute values as per your needs.
```yaml
- provider: cloudflare
  provisioner:
    $ref: /cloudflare/app-sre/account.yml
  resources:
    - provider: logpush_job
      identifier: test-logpush-job-zone
      enabled: true
      zone: test-zone
      logpull_options: fields=RayID,ClientIP,EdgeStartTimestamp&timestamps=rfc3339
      destination_conf: s3://bucket/logs?region=us-east-1&sse=AES256
      ownership_challenge: some-challenge 
      dataset: http_requests
      frequency: <low|high>
    - provider: logpush_job
      identifier: test-logpush-job-account
      enabled: true
      logpull_options: fields=RayID,ClientIP,EdgeStartTimestamp&timestamps=rfc3339
      destination_conf: s3://bucket/logs?region=us-east-1&sse=AES256
      ownership_challenge: some-challenge
      dataset: http_requests
      frequency: high
      name: test-logpush-job # must contain only alphanumeric characters, hyphens, and periods
      kind: instant-logs
      filter: "{\"key\":\"BotScore\",\"operator\":\"lt\",\"value\":\"30\"}"
```

Additonal resources
- [Cloudflare datasets](https://developers.cloudflare.com/logs/reference/log-fields/#datasets)

#### Logpull
Cloudflare [Logpull](https://developers.cloudflare.com/logs/logpull/) is a REST API for consuming request logs over HTTP. These logs contain data related to the connecting client, the request path through the Cloudflare network, and the response from the origin web server.

##### Logpull retention resource

The cloudflare Logpull retention resource definition follows [`logpull_retention`](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/logpull_retention) Terraform resource.

Following is an example, please set attribute values as per your needs.

```yaml
- provider: cloudflare
  provisioner:
    $ref: /cloudflare/app-sre/account.yml
  resources:
    - provider: logpull_retention
      identifier: test-logpull-retention
      zone: test-zone
      enabled: true
```
#### Monitoring Logpush jobs
Tenants are encouraged to setup prometheus alerts to monitor Logpush job status in case of any failures. 
You can utilize following metrics to setup the alerts
- `cloudflare_logpush_failed_jobs_account_count` with labels `destination`, `job_id` (can be obtained via Cloudflare UI) to monitor Logpush job for account level resources
- `cloudflare_logpush_failed_jobs_zone_count` with labels `destination`, `job_id` (can be obtained via Cloudflare UI) to monitor Logpush job for zone level resources


### Manage VPC peerings via App-Interface (`/openshift/cluster-1.yml`)

VPC peerings can be entirely self-services via App-Interface.

A cluster can be peered to a VPC that is defined in app-interface (we call it an account VPC) or to another OCM cluster account VPC (we call it a cluster VPC)

In order to use this integration, the following must be defined in the cluster definition file, under the `peering` key

- `connections`: a list of peering connections that this cluster should have. A peering connection can be either to an `account VPC` or a `cluster VPC`
  - `provider`: One of `account-vpc`, `cluster-vpc-requester` or `cluster-vpc-accepter`
  - `name`: A name for the VPC peering connection (ex: `clusterA-cluster-B`)
  - `vpc` (mutually exclusive with `cluster`): Value as `$ref: /path/to/some/vpc.yaml` (of type `/aws/vpc-1.yml`) [Account VPC SOP](/docs/app-sre/sop/app-interface-cluster-vpc-peerings.md)
  - `cluster` (mutually exclusive with `vpc`): Value as `$ref: /path/to/some/cluster.yaml` (of type `/openshift/cluster-1.yml`)
  - `manageRoutes`: (optional) A boolean value indicating should the integration add appropriate routes to existing Route Tables.

**Note:** For a cluster-to-cluster VPC peering, both clusters MUST have a corresponding VPC peering definition, one of which defined as `cluster-vpc-requester` and one as `cluster-vpc-accepter`, each referencing the other cluster. This ensures we are very specific about peerings and don't end up creating peering requests that will not lead to an account that won't have a corresponding accepter.

Example:

```yaml
# hive-stage-01 cluster.yaml
...
peering:
  connections:
  - provider: cluster-vpc-requester
    name: hive-stage-01_app-sre-stage-01
    cluster:
      $ref: /openshift/app-sre-stage-01/cluster.yml
```

```yaml
# app-sre-stage-01 cluster.yaml
...
peering:
  connections:
  - provider: cluster-vpc-accepter
    name: app-sre-stage-01_hive-stage-01
    cluster:
      $ref: /openshift/hive-stage-01/cluster.yml
```

### Management of layer 7 service networks (Skupper networks)

[Skupper](skupper.io) is a layer seven service interconnect. It enables secure communication across Kubernetes clusters with no VPNs or special firewall rules.

With Skupper, your application can span multiple cloud providers, data centers, and regions.

Some features to highlight:

* **Simple to set up**
  * No changes to your existing application required
  * Transparent HTTP/1.1, HTTP/2, gRPC, and TCP communication
* **Secure by design**
  * Communicate across clusters without exposing service ports on the internet
  * Inter-cluster communication is secured by mutual TLS
* **Connect anywhere**
  * Multicloud, hybrid cloud, and edge-to-edge connectivity
  * Secure access from the public cloud to private cloud services without VPNs
  * Add and remove new clusters dynamically
* **Smart routing**
  * Dynamic load balancing based on service capacity
  * Cost- and locality-aware traffic forwarding
  * Redundant routes for high availability in the face of network failures

The installation and the configuration can be entirely self-service via App-Interface.
In order to use this integration, you have to define a *skupper-network* and *skupper-sites* via the namespace definition files.

Let's start with the *skupper-network* definition.

* `$schema: /dependencies/skupper-network-1.yml`
* `identifier` a unique identifier for the skupper network
* `siteConfigDefaults` **required** Default configuration for all skupper sites. This configuration will be merged with the site-specific configuration from the namespace file.
  * `skupperSiteController` **required** Skupper site-controller image and version. Use the latest available version; see [Skupper releases](https://github.com/skupperproject/skupper/releases), e.g.: `quay.io/skupper/skupper-site-controller:1.2.0`
  * `clusterLocal` Boolean value indicating if the site is cluster local or not. If `true`, the site will be accessible only from within the cluster. If `false`, the site will be accessible from outside the cluster. The default value is `false`.
  * `console` Boolean value indicating if the skupper console (web-UI) should be enabled or not. The default value is `true`.
  * `consoleAuthentication` Skupper console authentication method. Currently, only `openshift` is supported. The default value is `openshift`.
  * `consoleIngress` Determines how the skupper console is exposed. Possible values are `route`, `loadbalancer`,  and `none`. The default value is `route`.
  * `controllerCpuLimit` CPU limit for the skupper controller. The default value is `500m`.
  * `controllerCpu` CPU request for the skupper controller. The default value is `200m`.
  * `controllerMemoryLimit` Memory limit for the skupper controller. The default value is `128Mi`.
  * `controllerMemory` Memory request for the skupper controller. The default value is `128Mi`.
  * `controllerPodAntiaffinity` Pod antiaffinity label matches to control the placement of controller pods. The default value is `skupper.io/component=controller`.
  * `controllerServiceAnnotations` Annotations (string with `key=value,anotherkey=value, ...`) to be added to the skupper controller service. The default value is `managed-by=qontract-reconcile`.
  * `edge` Boolean value indicating if the site is edge or not. An edge site is a namespace hosted on an internal cluster that is not accessible from outside the Red Hat VPN. Services hosted on an edge site are reachable within the Skupper network regardless of the cluster connectivity. The default value is `false` for non-internal clusters and `true` for internal clusters.
  * `ingress` Determines how the Skupper router is exposed. Possible values are `route`, `loadbalancer`,  `ingress`, and `none`. The default value is `route`.
  * `routerConsole` Boolean value indicating if the skupper router console (apache QPID web-UI) should be enabled or not. The default value is `false`.
  * `routerCpuLimit` CPU limit for the skupper router. The default value is `500m`.
  * `routerCpu` CPU request for the skupper router. The default value is `200m`.
  * `routerLogging` Log level for the skupper router. Possible values are `trace`, `debug`, `info`, `notice`, `warning`, and `error`. The default value is `error`.
  * `routerMemoryLimit` Memory limit for the skupper router. The default value is `156Mi`.
  * `routerMemory` Memory request for the skupper router. The default value is `156Mi`.
  * `routerPodAntiaffinity` Pod antiaffinity label matches to control the placement of router pods. The default value is `skupper.io/component=router`.
  * `routerServiceAnnotations` Annotations (string with `key=value,anotherkey=value, ...`) to be added to the skupper router service. The default value is `managed-by=qontract-reconcile`.
  * `routers` Replica count of skupper routers. The default value is `3`.
  * `serviceController` Boolean value indicating if the skupper service controller should be enabled or not. The default value is `true`.
  * `serviceSync` Boolean value indicating if the skupper service controller should synchronize the skupper services. The default value is `true`.

E.g.:

```yaml
---
$schema: /dependencies/skupper-network-1.yml

identifier: skupper-network-01

siteConfigDefaults:
  skupperSiteController: quay.io/skupper/site-controller:1.2.0
```

Now define the *skupper-sites* via the namespace definition file (`/openshift/namespace-1.yml`).

* `skupperSite`
  * `network` **required**
    * `$ref` Reference to the *skupper-network* definition file.
  * `delete` Boolean value indicating if the skupper site should be deleted or not. The default value is `false`.
  * `config` The available configuration options are the same as the ones defined in the *skupper-network* definition file, except `skupperSiteController`, because the Skupper version must be the same for all sites in the same network.

> :warning: **Attention**
>
> Skupper currently does not support changing the skupper configuration after the sites have been created. If you want to adapt the configuration, you have to delete the affected skupper site and re-create it again by using the `delete: true` option.

E.g.:

```yaml
---
$schema: /openshift/namepsace-1.yml

...

skupperSite:
  network:
    $ref: <path to skupper-network definition file>
```

> :information_source: **Note**
>
> A Skupper network must have at least two sites.

To create a Skupper service, you need to annotate your deployment, your statefulset, or your Kubernetes service with the following annotation:

* `skupper.io/proxy` Defines the protocol to be used for the service. Possible values are `tcp`, `http`, and `http2`. The default value is `tcp`.
  * tcp supports any protocol overlayed on TCP; for example, HTTP1 and HTTP2 work when you specify tcp.
  * If you specify http or http2, the IP address reported by a client may not be accessible.
  * All service network traffic is converted to AMQP messages in order to traverse the service network.
  * TCP is implemented as a single streamed message, whereas HTTP1 and HTTP2 are implemented as request/response message routing.
* `skupper.io/address` Defines the name (address) of the service. The default value, when annotating a service, is the name of the k8s service. Must be specified for deployments and statefulsets.
* `skupper.io/port` Defines the service and target port(s). Format is either
  * `servicePort` Service port to be exposed and target port are the same. E.g., `8080`.
  * `servicePort:targetPort` Service port to be exposed and target port are different. E.g., `80:8080`.
  * `servicePort:targetPort,servicePort:targetPort` Expose multiple ports. E.g., `80:8080,443:8443`.

Deployment annotation example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  annotations:
    skupper.io/proxy: http
    skupper.io/address: my-service
    skupper.io/port: 8080:8080
...
```

### Share resources between AWS accounts via App-Interface (`/aws/account-1.yml`)

In some use cases, we may want to share resources between AWS accounts.

This will be done by adding an entry to a `sharing` section of the "source" AWS account file (containing resources to be shared):
```yaml
sharing:
- provider: <type of sharing to use>
  account:
    $ref: /path/to/destination/account.yml
```

#### Share AMIs between AWS accounts

To share AMIs, add the following entry to a `sharing` section of the source AWS account file:
```yaml
sharing:
- provider: ami
  account:
    $ref: /path/to/destination/account.yml
  regex: <filter image by name>
  region: <region to share AMIs from/to> # optional, will use the default region of the account if not specified
```

This will cause all AMIs that match the regex expression to be shared from the source account to the destination account. AMI tags will also be copied to the shared AMI for traceability.

### Manage Slack User groups via App-Interface

Slack User groups can be self-serviced via App-Interface.

To manage a User group via App-Interface:

1. **Add a `permission` file with the following details:**

- `name`: name for the permission
- `description`: description of the User group (currently not automated)
- `service`: `slack-usergroup`
- `handle`: the handle of the User group
- `skip`: should this user group be skipped (unmanaged)
- `workspace`: a reference to a file representing the Slack Workspace
- `pagerduty`: a reference to a file representing a PagerDuty target (Schedule or Escalation Policy).
  * Adding this attribute will add the PagerDuty target as an additional "source of truth", and will add the final schedule user to the Slack user group (in addition to any references from user files).
- `ownersFromRepos`: a list of urls of github or gitlab repositories containing
  the `OWNERS` files to extract `approvers`/`reviewers` from. Only the root
  `OWNERS` file is considered. The `OWNERS_ALIASES` is respected.
    - Note: optionally add `:<branch>` to use a specific branch. For example: `https://github.com/openshift/osde2e:main`.
- `schedule`: a reference to a file representing a schedule.
- `channels`: a list of channels to add to the User group

2. **Add this permission to the desired `roles`, or create a new `role` with this permission only (mandatory).**
**Note:** Skip this step if the user group is not populated based on app-interface. i.e. if it is populated based on an external source of truth, such as an OWNERS file or PagerDuty.

3. **Add the group in the `managedUsergroups` section of the** [redhat-internal slack](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/slack/redhat-internal.yml) **dependency file**

Examples:
* An example for the `app-sre-team` User group permission can be found [here](/data/teams/app-sre/permissions/app-sre-team-coreos-slack.yml)
* An example for a role that has this permission can be found [here](/data/teams/app-sre/roles/app-sre.yml)
* An example for the `app-sre-ic` User group permission which is also synced with a PagerDuty schedule can be found [here](/data/teams/app-sre/permissions/app-sre-ic-coreos-slack.yml)
* An example for a PagerDuty schedule file can be found [here](/data/dependencies/pagerduty/app-sre-primary.yml).
* An example for a PagerDuty escalation policy file can be found [here](/data/dependencies/pagerduty/app-sre-escalation-policy.yml).
* An example for a GitHub `OWNERS` file can be found [here](/data/teams/sd-sre/permissions/aws-account-operator-coreos-slack.yml).
* An example for a GitHub `OWNERS_ALIASES` file can be found [here](/data/teams/sd-sre/permissions/managed-velero-operator-coreos-slack.yml).
* An example for a schedule can be found [here](/data/teams/app-sre/schedules/app-sre-onboarding-ic.yml).

Notes:
* The slack user group will be automatically created if it does not exist in slack before creating the merge request.
* In order to be able to use the `pagerduty` attribute of a `permission`, the relevant users (ones from that PagerDuty schedule) should have the following attributes in their user files:
  * `slack_username` - if it is different from `org_username`
  * `pagerduty_username` - if it is different from `org_username`

### Manage Jenkins jobs configurations using jenkins-jobs

Jenkins jobs configurations can be entirely self-serviced via App-Interface, and allows to define JJB Manifests to be used to bring up CI/CD/Automation pipelines or adhoc jobs in the internal and external Jenkins instance.

Note: This used to be managed in the [JJB](https://gitlab.cee.redhat.com/service/jjb) repository.

To add a configuration to a Jenkins instance, add a `jenkins-config` object with the following details:
- `instance` - reference to a jenkins instance
- `type` - one of the following JJB entities:
  - `views`
  - `secrets`
  - `base-templates`
  - `job-templates`
  - `jobs`
- `config` - a list of configurations of type `view` or `project` (use `config` for `views` and `jobs` types)
- `config_path` - a path to a resource containing configuration (use `config_path` for `secrets` and `job-templates` types, which tend to be have a "complex" yaml)

Examples:
- `views` - [object](/data/services/app-interface/cicd/ci-int/views.yaml)
- `secrets` - [object](/data/services/app-interface/cicd/ci-int/secrets.yaml), [resource](/resources/jenkins/app-interface/secrets.yaml)
- `job-templates` - [object](/data/services/app-interface/cicd/ci-int/job-templates.yaml), [resource](/resources/jenkins/app-interface/jobs-templates.yaml)
- `jobs` - [object](/data/services/app-interface/cicd/ci-int/jobs.yaml)

All JJB configurations rely on a set of JJB entities for the corresponding Jenkins intance:
- `global` - [resources](/resources/jenkins/global/)
- `ci-int` - [object](/data/services/jenkins/cicd/ci-int/), [resources](/resources/jenkins/ci-int/)
- `ci-ext` - [object](/data/services/jenkins/cicd/ci-ext/), [resources](/resources/jenkins/ci-ext/)
- `ci-centos` - [object](/data/services/jenkins/cicd/ci-centos/), [resources](/resources/jenkins/ci-centos/)

The final JJB configrations will be sorted in the following order:
- `defaults`
- `global-defaults`
- `views`
- `secrets`
- `base-templates`
- `global-base-templates`
- `job-templates`
- `jobs`

External reference:
- [Jenkins Job Builder](https://docs.openstack.org/infra/jenkins-job-builder/)

Notes:
- If the secret is from a Vault KV V2 secret engine (versioned), the secret definition must include `engine-version: 2`. [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/jenkins/mt-sre/secrets.yaml#L4)


### Delete AWS IAM access keys via App-Interface

AWS IAM keys deletion can be entirely self-serviced via App-Interface.

In order to delete a key from an AWS account, add the Access key ID to the `deleteKeys` list in the AWS Account file.
For example, merging [this](/data/aws/osio/account.yml#L11) line will delete the Access key with ID `AKIAVT6AWJBAILFXBV4A` from the `osio` account.

One use case this is useful for is leaked keys.


### Reset AWS IAM user passwords via App-Interface

AWS IAM user passwords can be entirely self-serviced via App-Interface.

To reset a user's password in an AWS account, submit a MR with a new entry to the `resetPasswords` list in the AWS Account file:
```yaml
- user:
    $ref: /path/to/user/file.yaml
  requestId: <some_unique_value_without_spaces>
```

The user's new password should appear GPG encrypted within 30 minutes in app-interface-output repository: [terraform-users-credentials](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/terraform-users-credentials.md) and also via email.

To decrypt password: `echo <password> | base64 -d | gpg -d - && echo` (you will be asked to provide your passphrase to unlock the secret)

This operation will also reset any existing virtual MFA devices.

#### Behind the scenes

Once the MR is merged, an integration called `aws-iam-password-reset` will delete the user's login profile. At this point, the user can not login to the account.

A different integration, called `terraform-users` will realize that the user does not have a login profile and will re-create it. At this point, the user has a new random password.

The curious reader can follow [#sd-app-sre-reconcile](https://redhat-internal.slack.com/archives/CS0E65QCV) to see when these two actions have completed.

Once the new password is in place, it needs to be picked up by an app-interface-output created by a `qontract-cli` command called `terraform-users-credentials` (the repository is refreshed once every 10 minutes).

### AWS garbage collection

To enable garbage collection in an AWS account, add `garbageCollection: true` to the account file. [example](/data/aws/osio-dev/account.yml#L20)

AWS resources which do *NOT* have one of the following properties are continuously garbage collected:

* The resource name starts with the name of an existing IAM user
* The resource name has `stage` or `prod` in it
* The resource has one of these tags:
  * `managed_by_integration` - resources managed by the `terraform-resources` or `terraform-users` integrations
  * `owner` - resources managed by `app-sre` team terraform configurations in [app-sre/infra](https://gitlab.cee.redhat.com/app-sre/infra/tree/master/terraform)
  * `aws_gc_hands_off` - resources created manually, if tag is set to `true`
  * `ENV`/`environment` - resources which are related to `stage` or `prod`

Supported resource types are:
* S3
* SQS
* RDS
* DynamoDB


### GitHub user profile compliance

App-Interface users must define a `github_username` field in their user file. This profile must comply with the following requirements:

* The profile `Company` field must contain `Red Hat` (regex expression: `^.*[Rr]ed ?[Hh]at.*$`)
* The profile must have one `@redhat.com` e-mail address configured, that has been validated.

### Manage GitLab group members

Adding, removing, and changing access levels of gitlab group members can be self-serviced via App-Interface

To manage a GitLab group via App-Interface:
1. Add a `permission` file with the following details:

- `name`: name for the permission
- `description`: description
- `service`: `gitlab-group-membership`
- `group`: name of GitLab Group
- `access`: access level this permission gives (owner/maintainer/developer/reporter/guest)
- `pagerduty`: (optional) a reference to a file representing a PagerDuty target (Schedule or Escalation Policy).
  * Adding this attribute will add the PagerDuty target as an additional "source of truth", and will add the final schedule user to the gitlab group (in addition to any references from user files).

2. Add this permission to the desired `roles`, or create a new `role` with this permission only.

3. Add this permission to the GitLab bot role which can be found [here](/data/teams/app-sre/roles/app-sre-gitlab-bot.yml)

4. Make sure that ever member of the group has a role giving them permission to the group otherwise the integration will remove them.

Examples:
* An example for the `app-sre` group permission can be found [here](/data/dependencies/gitlab/permissions/app-sre-member.yml)
* An example for a role that has this permission can be found [here](/data/teams/app-sre/roles/app-sre.yml)

Notes:
* Creating new GitLab groups is not supported (GitLab group has to pre-exist).


### Create GitLab projects

Creating a new project in gitlab can be self-serviced via App-Interface.

To request the creation of a new project, submit a PR adding the new project under the desired group [here](/data/dependencies/gitlab/gitlab.yml). The project will be created on merge.

You will also need to add the repository information to the `codeComponents` section in your app file.

To get access to the project, if required, contact the App SRE team.


### Add a Grafana Dashboard

See [this guide](/docs/app-sre/monitoring.md#visualization-with-grafana) on how to create Grafana dashboards.


### Execute a SQL Query on an App Interface controlled RDS instance

To execute an SQL Query, you have to commit to the app-interface an YAML
file with the following content:

```yaml
---
$schema: /app-interface/app-interface-sql-query-1.yml
name: <sql query unique name>
namespace:
  $ref: /services/<service>/namespaces/<namespace>.yml
identifier: <RDS resource identifier (same as defined in the namespace)>
output: <filesystem or stdout or encrypted>
# Required if output is encrypted
requestor:
  $ref: <user-1.yml with public_gpg_key>
schedule: <if defined the output resource will be a CronJob instead of a Job>
query: <sql query>
```

If you want to run multiple queries in the same spec, you can define the
`queries` list instead of the `query` string. Example:

```yaml
---
$schema: /app-interface/app-interface-sql-query-1.yml
name: <sql query unique name>
namespace:
  $ref: /services/<service>/namespaces/<namespace>.yml
identifier: <RDS resource identifier (same as defined in the namespace)>
output: <filesystem or stdout or encrypted>
# Required if output is encrypted
requestor:
  $ref: <user-1.yml with public_gpg_key>
schedule: < In UTC time - if defined the output resource will be a CronJob instead of a Job >
queries:
  - <sql query 1>
  - <sql query 2>
  - <sql query 3>
```

Example:

```yaml
---
$schema: /app-interface/app-interface-sql-query-1.yml
labels: {}
name: 2020-01-30-account-manager-registries-stage
namespace:
  $ref: /services/ocm/namespaces/uhc-stage.yml
identifier: uhc-acct-mngr-staging
output: filesystem
query: |
  SELECT id, name, deleted_at from registries;
```

#### SQL Rules
* Only READ sentences (`SELECT`, `EXPLAIN`, `EXPLAIN ANALYZE SELECT`)
* Columns must be specified. `SELECT * ` is not allowed

#### SQL Format
* We strongly recommend use yaml multiline format keeping the line breaks.
* Comments are allowed in both possible formats (check the examples below)
* Queries must end with `;`

```yaml
query: |
  SELECT id, name from a;
...
query: |
  SELECT /* comment */ id, name
  FROM a -- comment
  WHERE id = 1;
...
queries:
  - |
    SELECT id, name FROM a;
  - |
    SELECT id, name FROM b /* comment */ order by id;
  - |
    SELECT id, name
    FROM c
    -- comment: need to order by id
    ORDER BY id;
```

When that SQL Query specification is merged, the integration will create a
Job (or a CronJob if `schedule` is defined) in the namespace provided:

```bash
$ oc get pods | grep 2020-01-30-account-manager-registries-stage
2020-01-30-account-manager-registries-stage-7pl6v              0/1     Completed   0          4h32m
```

That Job will execute the SQL query and place the result to the requested
location:

- `stdout`: requires `view` access to the namespace. The pod created by the Job
  will have the SQL query result printed to the stdout. Example:

```bash
$ oc logs 2020-01-28-account-manager-registries-stage-7pl6v
             id              |            name             |          deleted_at
-----------------------------+-----------------------------+-------------------------------
 1HPiQ7VattP4WXgGRMvANMIxAuJ | registry.redhat.io          |
 1HPgUBbu7A5ATEa9pVgderCnaBw | registry.connect.redhat.com |
 1Aabcdoseqrawn1t994qf3ny3ec | quay.io                     |
 1VTLMg1uEFgznKiLVh7szZHQcnU | aaa                         | 2019-12-25 11:08:22.886628+00
 1VTMLJRMxUMjOLYczcmPU7GKnZN | aaa                         | 2019-12-25 11:18:12.000539+00
 1VTMJoJgSGW6EnuwsxLrrstdB7k | aaa                         | 2020-01-13 08:24:12.635462+00
 1VTMKAJ9orhfiB5Us7VQSobmjfW | aaa                         | 2020-01-13 08:24:25.324837+00
 1VTMKSKYsDPugCUFKhdg91PMVpL | aaa                         | 2020-01-13 08:24:37.888744+00
 1VTMKZvvoazsHM8Qt58bLsOD8Yk | aaa                         | 2020-01-13 08:25:31.468072+00
 1VTMKj0RZU4VflvpWFabCkq14ji | aaa                         | 2020-01-13 08:26:03.942181+00
 1VTMKyagkV8EqDBAQPyoWuv1cmI | aaa                         | 2020-01-13 08:26:14.51152+00
 1VTML5RK1eqsWKZAke0fC3FEgWY | aaa                         | 2020-01-13 08:26:28.173743+00
 1VTN6U2ClGNWn3uAqBSUkaZ8DGJ | aaa                         | 2020-01-13 08:26:36.128141+00
 1VVB7O0E9GqJ9tJJJ8Cz34mbCfd | aaa                         | 2020-01-13 08:26:50.414377+00
 1VVB7nTNwEABvhhrY7bAEoUysLW | aaa                         | 2020-01-13 08:26:58.086477+00
 1VVB7q4PPEH3R1tsuPTLjabYqId | aaa                         | 2020-01-13 08:27:12.184195+00
 1VVBSyT1eblnOXm5fsQirKdzHxu | aaa                         | 2020-01-13 08:27:20.478724+00
 1VVBUGCglzmE98l9zLeqljWKZdV | aaa                         | 2020-01-13 08:27:34.340959+00
 1VVBUV6rcZ9jsqo2vUuBpw21gbP | aaa                         | 2020-01-13 08:27:41.733607+00
(19 rows)
```

- `filesystem`: requires `edit` access to the namespace. The pod created by the
  Job will have the SQL query result written to the pod filesystem. In the pod
  stdout you will see the `oc` command to retrieve the SQL query results.

```bash
$ oc logs 2020-01-30-account-manager-registries-stage-cjh82
Get the sql-query results with:

oc cp 2020-01-30-account-manager-registries-stage-cjh82:/tmp/query-result.txt 2020-01-30-account-manager-registries-stage-cjh82-query-result.txt

Sleeping 3600s...
```

Notice that, in this case, the pod will be kept sleeping for 1 hour so you can
retrieve the query results.

Using that command:

```bash
$ oc rsh --shell=/bin/bash 2020-01-30-account-manager-registries-stage-cjh82 cat /tmp/query-result.txt
             id              |            name             |          deleted_at
-----------------------------+-----------------------------+-------------------------------
 1HPiQ7VattP4WXgGRMvANMIxAuJ | registry.redhat.io          |
 1HPgUBbu7A5ATEa9pVgderCnaBw | registry.connect.redhat.com |
 1Aabcdoseqrawn1t994qf3ny3ec | quay.io                     |
 1VTLMg1uEFgznKiLVh7szZHQcnU | aaa                         | 2019-12-25 11:08:22.886628+00
 1VTMLJRMxUMjOLYczcmPU7GKnZN | aaa                         | 2019-12-25 11:18:12.000539+00
 1VTMJoJgSGW6EnuwsxLrrstdB7k | aaa                         | 2020-01-13 08:24:12.635462+00
 1VTMKAJ9orhfiB5Us7VQSobmjfW | aaa                         | 2020-01-13 08:24:25.324837+00
 1VTMKSKYsDPugCUFKhdg91PMVpL | aaa                         | 2020-01-13 08:24:37.888744+00
 1VTMKZvvoazsHM8Qt58bLsOD8Yk | aaa                         | 2020-01-13 08:25:31.468072+00
 1VTMKj0RZU4VflvpWFabCkq14ji | aaa                         | 2020-01-13 08:26:03.942181+00
 1VTMKyagkV8EqDBAQPyoWuv1cmI | aaa                         | 2020-01-13 08:26:14.51152+00
 1VTML5RK1eqsWKZAke0fC3FEgWY | aaa                         | 2020-01-13 08:26:28.173743+00
 1VTN6U2ClGNWn3uAqBSUkaZ8DGJ | aaa                         | 2020-01-13 08:26:36.128141+00
 1VVB7O0E9GqJ9tJJJ8Cz34mbCfd | aaa                         | 2020-01-13 08:26:50.414377+00
 1VVB7nTNwEABvhhrY7bAEoUysLW | aaa                         | 2020-01-13 08:26:58.086477+00
 1VVB7q4PPEH3R1tsuPTLjabYqId | aaa                         | 2020-01-13 08:27:12.184195+00
 1VVBSyT1eblnOXm5fsQirKdzHxu | aaa                         | 2020-01-13 08:27:20.478724+00
 1VVBUGCglzmE98l9zLeqljWKZdV | aaa                         | 2020-01-13 08:27:34.340959+00
 1VVBUV6rcZ9jsqo2vUuBpw21gbP | aaa                         | 2020-01-13 08:27:41.733607+00
(19 rows)
```

- `encrypted`: requires `view` access to the namespace. The pod created by the Job
  will have the SQL query result encrypted with requestor's public_gpg_key and
  printed to the stdout.

```bash
$ oc logs 2020-01-30-account-manager-registries-stage-cjh82
Get the sql-query results with:

cat <<EOF > 2020-01-30-account-manager-registries-stage-cjh82-query-result.txt
-----BEGIN PGP MESSAGE-----

hQIMA4VLxbLWZXlwARAAopxeOIKmfRbsH/a12s35aClwjVb0hTbVvfT4jHXZJR9C
...
=jA8e
-----END PGP MESSAGE-----
EOF
gpg -d 2020-01-30-account-manager-registries-stage-cjh82-query-result.txt
```

Running that command locally and decrypt the message with requestor's private key.

To delete a scheduled query (CronJob), add `delete: true` to your query definition file like so:

```yaml
---
$schema: /app-interface/app-interface-sql-query-1.yml
labels: {}
name: 2020-01-30-account-manager-registries-stage
namespace:
  $ref: /services/ocm/namespaces/uhc-stage.yml
identifier: uhc-acct-mngr-staging
output: filesystem
query: |
  SELECT id, name, deleted_at from registries;
delete: true
```
Once your change is merged, the CronJob and related resources will be deleted from the cluster. After that point it's safe to delete the query file itself.

**Important notes**
* Each Job will be automatically deleted after 7 days.
* CronJobs run indefinitely unless you delete them using the `delete` parameter, removing the file will not delete the CronJob from the cluster.
* Query files are only executed once unless a `schedule` is defined.
  The query file execution status is tracked using the `name` field.
  If you wish to run an existing query file a second time
  (possibly including modifications to the queries), you must change the `name`
  field. This can be achieved by copying the existing file to a new file with a
  new `name`, or reusing the existing file and changing the query `name`.
* Updates on CronJobs (schedule, queries, ...) aren't supported yet, delete old one by using `delete` parameter and submit a new file with your changes.

### Enable Gitlab Features on an App Interface Controlled Gitlab Repository

To manage a Gitlab repository via App Interface, you have to add an `upstream`
resource to the `codeComponents` section in your App. Example:

```yaml
---
$schema: /app-sre/app-1.yml

labels:
  service: app-sre

name: App-SRE

...

codeComponents:
...
- name: managed-tenants
  resource: upstream
  url: https://gitlab.cee.redhat.com/service/managed-tenants
...
```

**Every fork of this repo must have @devtools-bot added as a `Maintainer` of
the project.** If the bot is not added, GitLab will not be updated with the
status of your builds in the `Pipelines` tab, and the bot will not
automatically merge your MRs with the proper approvals (described later in this
section). If you don't know how to add a user to your project, see the
[GitLab documentation](https://docs.gitlab.com/ee/user/project/members/#add-users-to-a-project).

App Interface has several features that can be enabled for the Gitlab
repositories:
- `gitlabRepoOwners`: Value `enabled: true` will enable the
  `gitlab-repo-owners`, integration, that evaluates the
  `OWNERS`/`OWNERS_ALIASES` files in that repository to post comments to the
  Merge Requests reporting the required approvals, ultimately labeling the
  Merge Request, making it up for auto-merge.
- `gitlabHousekeeping`:  Value `enabled: true` will enable the
  `gitlab-housekeeping` integration, that auto-merges Merge Requests that are
  labelled as such. It also rebases the Merge Requests that are not rebased
  (you can disable the rebase feature with `rebase: false`). Additional supported
  fields:
    - `limit` - limit number of merges/rebases to avoid load (default: 1)
    - `days_interval` - number of days to consider an item as stale (default: 15)
    - `enable_closing` - enable closing of stale items after two stale periods (default: disabled)
    - `pipeline_timeout` - number of minutes that determine if a pending pipeline is to be canceled.
    If not set, no pipeline will be canceled.
- `jira`: Value as `$ref: /path/to/jira-server.yaml` will enable the
  Gitlab/JIRA integration, that links Merge Requests mentioning JIRA tickets
  to the mentioned JIRA ticket.
- `showInReviewQueue` : When set to true, MRs from this repository 
  display in the [review queue](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/app-interface-review-queue.md) so that the AppSRE IC can review MRs that are not self-servicable.
  (For AppSRE usage only).

Example:

```yaml
codeComponents:
...
- name: managed-tenants
  resource: upstream
  url: https://gitlab.cee.redhat.com/service/managed-tenants
  gitlabRepoOwners:
    enabled: true
  gitlabHousekeeping:
    enabled: true
    rebase: false
...
```

The functionality of the gitlab-housekeeping feature depends on the @devtools-bot gitlab user added as a Maintainer to every fork of the repository.

This check can be automated by adding an execution of the gitlab-fork-compliance integration to the repository's pr-check script.

Here is an example: https://gitlab.cee.redhat.com/mk-ci-cd/kafka-storage-expansions/-/merge_requests/17

Consider creating a gitlab group for your team to use with this feature. No gitlab group? Just leave out the last argument. The bot will be added to the fork, which is the important part.

> Note: If you are using a custom Jenkins job template, you should add the `gitlab_fork_compliance_reconcile_toml` secret. Here is an [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/jenkins/managed-services/job-templates.yaml#L529).

### Provision and consume Kafka clusters via KAS Fleet Manager

Provisioning Kafka managed clusters through the Kafka Service Fleet Manager can be self-serviced via app-interface.

> Note: This feature is currently disabled due to [SDB-2914](https://issues.redhat.com/browse/SDB-2914).

#### Request quota

To request quota for a new cluster, create a merge request to the [ocm-resources](https://gitlab.cee.redhat.com/service/ocm-resources) repository requesting additional quota for the AppSRE OCM production organization. Here is an [example](https://gitlab.cee.redhat.com/service/ocm-resources/-/merge_requests/1916). The merge request should include details on the requesting entity and any information that supports the need to use a Kafka instance.

> Note: each additional unit grants quota for 3 clusters.

Once the merge request is created, send an email to [Cloud Services BU](mailto:cloud-services-bu@redhat.com) (cc [AppSRE](mailto:sd-app-sre+kafka-requests@redhat.com)) with all the information.

Once approval is granted (preferably as a comment on the merge request), ping @ocm-resources in #service-development-b (CoreOS slack) to get the merge request merged.

#### Provision cluster

To provision a new cluster, create a Kafka cluster file. Example:
```yaml
---
$schema: /kafka/cluster-1.yml

labels: {}

name: example-kafka
description: <cluster description>

ocm:
  $ref: /dependencies/ocm/production.yml

spec:
  provider: aws
  region: us-east-1
  multi_az: true
```

To define a consumer of the Kafka cluster, add the `kafkaCluster` reference to a namespace file. Example:
```yaml
kafkaCluster:
  $ref: /kafka/example-kafka/cluster.yml
```

To explicitly indicate that your service relies on the Kafka service, add the `kafka` dependency in the App file:
```yaml
dependencies:
# existing dependencies
- $ref: /dependencies/kafka/service.yml
```

This will result in a Secret being created in the consuming namespace. The Secret will be called `kafka` and it will contain the following keys:
- `bootstrap_server_host` - Bootstrap server hostname (host:port)
- `client_id` - Client ID to use for authentication
- `client_secret` - Client Secret to use for authentication

### Enable GitLab repo synchronization
There are instances when it is desired to maintain an exact copy of a GitLab repository within a network-isolated environment (ex: FedRamp).

For these instances, the optional `gitlabSync` attribute can be added within the `codeComponents` for the relevant repository:
```yaml
codeComponents:
- name: homeless-templates
  resource: upstream
  url: https://gitlab.cee.redhat.com/app-sre/homeless-templates
  gitlabSync:
    sourceProject:
      name: homeless-templates
      group: app-sre
      branch: main
    destinationProject:
      name: homeless-templates-sync
      group: app-sre-services
      branch: main

```
`sourceProject` specifies the project to target within `gitlab.cee.redhat.com`

`destinationProject` specifies where to maintain the copy in FedRamp GitLab instance.

Once a `gitlabSync` is merged, the source project/branch will be monitored for any commits. When commits are detected, a sync process will be triggered. Updates are visible on the destination project within 10 minutes.

**Considerations:** 
* synchronizing from `gitlab.cee.redhat.com` to the primary GitLab instance within FedRamp is the only supported pairing at this time. If you desire to utilize this functionality for another GitLab instance, please reach out within #sd-app-sre
* the destination project must already exist
* the AppSRE bot (@app-sre-bot) must be a member of both projects and be assigned the `maintainer` role
* if the branch specified for destination project is `Protected` (default branch) the destination project must allow force pushes from maintainers to the specified branch  
  * This can be adjusted by navigating to: `Settings > Repository > Protected branches` in the destination project


### Write and run Prometheus rules tests

Please follow [this guide](/docs/app-sre/prometheus-rules-tests-in-app-interface.md) to know to do it.

### How to offboard/delete a service

This process can be done in two ways.
* Method one
  * Open the first MR in app-interface to delete each target in the saas file for your related service. See [Delete target from SaaS file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/FAQ.md#delete-target-from-saas-file) for a deeper explanation and example.
  * Once that MR is merged, you can open a second MR in app-interface to add the line `delete: true` within the namespace file.
* Method two
  * Open a MR to add the line `delete: true` on the related namespace file and delete the targets from the saas file.


### How to enable replication between Vault instances

To enable replication between two different vault instances create a replication section on the Vault instance file (`/vault-config/instance-1.yml`) that will act as the source Vault.

The common config for all the different providers is the authentication and the destination instance, this can be configured as this example:

```yaml
replication:
- vaultInstance:
    $ref: destination/vault/instance/file.yml
  sourceAuth:
    provider: "approle"
    secretEngine: "kv_v1"
    roleID:
      path: "path/to/source_vault/role_id"
      field: "role_id"
    secretID:
      path: "path/to/source_vault/secret"
      field: "secret_id"

  destAuth:
    provider: "approle"
    secretEngine: "kv_v1"
    roleID:
      path: "path/to/destination_vault/role_id"
      field: "role_id"
    secretID:
      path: "path/to/destination_vault//secret"
      field: "secret_id"
```

The `replication` key can be configured using providers. Providers allow to configure different sources for secrets that are going to be copied and at least one must be configured, the integration has two different providers, `jenkins` and `policy`.

#### Jenkins

Jenkins provider on Vault replication integration allows to copy all the secrets used by a given Jenkins instance from the source Vault instance to the destination instance. An example config for this would be:

```yaml
  paths:
  - provider: "jenkins"
    jenkinsInstance:
      $ref: dependencies/jenkins_instance_file.yml
```

And optionally, the secrets to copy can be limited by a Vault policy, if specified, the integration will return an error in case any of the secrets is not part of the policy

Example configuration:

```yaml
  paths:
  - provider: "jenkins"
    jenkinsInstance:
      $ref: dependencies/jenkins_instance_file.yml
    policy:
      $ref: policy/path/policy.yml
```

#### Policy

Policy provider on Vault replication integration allows to copy all the secrets under the path on the policy. An example configuration would be:

```yaml
  - provider: "policy"
    policy:
      $ref: policy/path/policy.yml
```

Real examples can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/prod/devshift-net.yml)

## Design

Additional design information: [here](docs/app-interface/design.md)

[schemas]: <https://github.com/app-sre/qontract-schemas>
[userschema]: <https://github.com/app-sre/qontract-schemas/blob/main/schemas/access/user-1.yml>
[crossref]: <https://github.com/app-sre/qontract-schemas/blob/main/schemas/common-1.json#L58-L86>
[role]: <https://github.com/app-sre/qontract-schemas/blob/main/schemas/access/role-1.yml>
[permission]: <https://github.com/app-sre/qontract-schemas/blob/main/schemas/access/permission-1.yml>

## Developer Guide

More information [here](docs/app-sre/sop/app-interface-development-environment-setup.md)

## Quay Documentation

All the quay.io related documentation can be found in the [`quay`](docs/quay) folder.
