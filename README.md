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
  implementations) that define the contract. JSON and GraphQL schemas of the datafiles.
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
- [Share your fork](https://docs.gitlab.com/ee/user/project/members/share_project_with_groups.html#sharing-a-project-with-a-group-of-users) with the [app-sre](https://gitlab.cee.redhat.com/app-sre) group as `Master`.
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
./manual_schema_validator.sh schemas graphql-schemas data resources
```

The output will be JSON document, so you can pipe it with `jq`, example:
`./manual_schema_validator.sh schemas graphql-schemas data resources | jq .`

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
  - <https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com/>
  - <https://ci.ext.devshift.net/>
  - <https://vault.devshift.net/ui/>
  - Many openshift.com clusters:
    - `dsaas`, `dsaas-stg`, `evg`, `app-sre`, `app-sre-dev`.
  - OpenShift.io Feature Toggles
- Management of OpenShift rolebindings
- Management of Quay repos.
- Management of Quay organisation members.
- Management of OpenShift ConfigMaps.
- Management of OpenShift Secrets using Vault.
- Management of Vault configurations.

### Planned integrations

- Top level tracking of managed services, their contact points, and work
  streams.
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



### Manage Openshift resources via App-Interface (`/openshift/namespace-1.yml`)

[services](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services) contains all the services that are being run by the App-SRE team. Inside of those directories, there is a `namespaces` folder that lists all the `namespaces` that are linked to that service.

Namespaces declaration enforce [this JSON schema](https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/openshift/namespace-1.yml). Note that it contains a reference to the cluster in which the namespace exists.

Notes:
* If the resource already exists in the namespace, the PR check will fail. Please get in contact with App-SRE team to import resources to be under the control of App-Interface.
* Manual changes to ConfigMaps or Secrets will be overridden by App-Interface in each run.

#### Manage ConfigMaps via App-Interface (`/openshift/namespace-1.yml`)

ConfigMaps can be entirely self-serviced via App-Interface.

In order to add ConfigMaps to a namespace, you need to add them to the `openshiftResources` field.

- `provider`: must be `resource`
- `path`: path relative to [resources](https://gitlab.cee.redhat.com/service/app-interface/tree/master/resources). Note that it starts with `/`.

The object itself must be stored under the `resources` path, and by convention it should be named: `resources/<cluster_name>/<namespace>/<configmap_name>.configmap.yml`.

In order to change the values of a ConfigMap, send a PR modifying the ConfigMap in the `resources` directory, and upon merge it will be applied.

#### Manage Secrets via App-Interface (`/openshift/namespace-1.yml`) using Vault

Secrets can be entirely self-serviced via App-Interface.

Instructions:

1. Create a secret in Vault with the data (key-value pairs) that should be applied to the cluster.
  * The secret in Vault should be stored in the following path: `app-interface/<cluster>/<namespace>/<secret_name>`
  * The value of each key in the secret in Vault should **NOT** be base64 encoded.
  * If you wish to have the value base64 encoded in Vault, the field key should be of the form `<key_name>_qb64`.
2. Add a reference to the secret in Vault under the `openshiftResources` field with the following attributes:

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

* [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) with fields of type `stringData` are not supported.
* When creating a new secret in Vault, be sure to set the `Maximum Number of Versions` field to `0` (unlimited).
* If you want to delete a secret from Vault, please get in contact with the App-SRE team.
* If you wish to use a different secrets engine, please get in contact with the App-SRE team.

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
- `path`: path relative to [resources](https://gitlab.cee.redhat.com/service/app-interface/tree/master/resources). Note that it starts with `/`.
- `vault_tls_secret_path`: (optional) absolute path to secret in [Vault](https://vault.devshift.net) which contains sensitive data to be added to the `.spec.tls` section.
- `vault_tls_secret_version`: (optional, mandatory if `vault_tls_secret_path` is defined) version of secret in Vault.

Notes:
* The secret in Vault should be stored in the following path: `app-interface/<cluster>/<namespace>/routes/<secret_name>`.
* In case the Route contains no sensitive information, a secret in Vault is not required (hence the fields are optional).
* It is recommended to read through the instructions for [Secrets](#manage-secrets-via-app-interface-openshiftnamespace-1yml-using-vault) before using Routes.

### Manage Vault configurations via App-Interface

https://vault.devshift.net is entirely managed via App-Interface and its configuration can be found in [config](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/vault.devshift.net/config) folder of ` vault.devshift.net` service

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
Current audit backends configurations can be found [here](https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/vault.devshift.net/config/audit-backends/)

For more information please see [vault audit backends documentation](https://www.vaultproject.io/docs/audit/index.html)

#### Manage vault auth backends (`/vault-config/auth-1.yml`)
Auth backends are the components in Vault that perform authentication and are responsible for assigning identity and a set of policies to a user.

Example:
```yaml
---
$schema: /vault-config/auth-1.yml

labels:
  service: vault.devshift.net

_path: "github/"
type: "github"
description: "github auth backend"
settings:
  config:
    _type: "github"
    organization: "app-sre"
    base_url: ""
    max_ttl: "360h"
    ttl: "120h"
policy_mappings:
  - github_team:
      $ref: <github team datafile (`/access/permission-1.yml`), for example: /dependencies/vault/permissions/app-sre.yml>
    policies:
      - $ref: <vault policy datafile (`/vault-config/policy-1.yml`), for example: /services/vault.devshift.net/config/policies/app-sre-policy.yml>
```
**Note**: some auth backends like github support policy mappings. Policy mapping can be applied to auth backed entity, for example in case with github auth currently allowed entity is a `team`.
To apply vault policy on auth entity `policy_mappings` key should be used.

Current auth backends configurations can be found [here](https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/vault.devshift.net/config/auth-backends)

For more information please see [vault auth backends documentation](https://www.vaultproject.io/docs/auth/index.html)

#### Manage vault policies (`/vault-config/policy-1.yml`)
Policies provide a declarative way to grant or forbid access to certain paths and operations in Vault

Exmaple:
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
Current vault policies can be found [here](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/vault.devshift.net/config/policies)

For more information please see [vault policies documentation](https://www.vaultproject.io/docs/concepts/policies.html)

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
Current vault roles can be found [here](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/vault.devshift.net/config/roles)

For more information please see [vault AppRole documentation](https://www.vaultproject.io/docs/auth/approle.html)

#### Manage vault secret-engines (`/vault-config/secret-engine-1.yml`)
Secrets engines are components which store, generate, or encrypt data. Secrets engines are incredibly flexible, so it is easiest to think about them in terms of their function.
Secrets engines are provided some set of data, they take some action on that data, and they return a result.

KV Secrets engine Example:
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
Current secrets engines can be found [here](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/vault.devshift.net/config/secret-engines)

For more information please see [vault secrets engines documentation](https://www.vaultproject.io/docs/secrets/index.html)


### Manage AWS access via App-Interface (`/aws/group-1.yml`) using Terraform

[teams](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/teams) contains all the teams that are being services by the App-SRE team. Inside of those directories, there is a `users` folder that lists all the `users` that are linked to that team. Each `user` has a list of assiciated `roles`. A `role` can be used to grant AWS access to a user, by adding the `user` to an AWS `group`.

Groups declaration enforce [this JSON schema](https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/aws/group-1.yml). Note that it contains a reference to the AWS account in which the group exists.

Notes:
* Manual changes to AWS resources will be overridden by App-Interface in each run.
* A group without associated users will not be created.

#### Manage AWS users via App-Interface (`/aws/group-1.yml`) using Terraform

AWS users can be entirely self-serviced via App-Interface.

In order to get access to an AWS account, a user has to have:
* A `role` that includes an `aws_groups` section, with a reference to an AWS group file.
  * Example: [sre-aws](/data/teams/app-sre/roles/sre-aws.yml) role.
* A public binary GPG key, which will be used to encrypt the generated password to send by mail.

Once a user is created, an email invitation to join the account will be sent with all relevant information.

## Adding your public GPG key
A base64 encoded binary GPG key should be added to the user file.
To export your key:
```
gpg --export <redhat_username>@redhat.com | base64
```

To get your base64 encoded binary GPG key from an [ascii armored output](https://www.gnupg.org/gph/en/manual/x56.html):
```
cat <redhat_username>.gpg.asc | gpg --dearmor | base64
```


### Manage AWS resources via App-Interface (`/openshift/namespace-1.yml`) using Terraform

[services](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services) contains all the services that are being run by the App-SRE team. Inside of those directories, there is a `namespaces` folder that lists all the `namespaces` that are linked to that service.

Namespaces declaration enforce [this JSON schema](https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/openshift/namespace-1.yml). Note that it contains a reference to the cluster in which the namespace exists.

Notes:
* Manual changes to AWS resources will be overridden by App-Interface in each run.
* To be able to use this feature, the `managedTerraformResources` field must exist and equal to `true`.

#### Manage RDS databases via App-Interface (`/openshift/namespace-1.yml`)

RDS instances can be entirely self-serviced via App-Interface.

In order to add or update an RDS database, you need to add them to the `terraformResources` field.

- `provider`: must be `rds`
- `account`: must be one of the AWS account names we manage. Current options:
  - `app-sre`
  - `osio`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](https://gitlab.cee.redhat.com/service/app-interface/tree/master/resources) to a file with default values. Note that it starts with `/`. Current options:
  - [rds](https://gitlab.cee.redhat.com/service/app-interface/tree/master/resources/terraform/rds-1.yml) - `/terraform/rds-1.yml`
- `overrides`: list of values from `defaults` you wish to override, with the override values. For example: `engine: mysql`.

Once the changes are merged, the RDS instance will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.
The name of the secret will be `<identifier>-<provider>`. For example, for a resource with `identifier` "my-instance" and `provider` "rds", the created Secret will be called `my-instance-rds`.
The Secret will contain the following fields:
- `db.host` - The hostname of the RDS instance.
- `db.port` - The database port.
- `db.name` - The database name.
- `db.user` - The master username for the database.
- `db.password` - Password for the master DB user.

#### Manage S3 buckets via App-Interface (`/openshift/namespace-1.yml`)

S3 buckets can be entirely self-serviced via App-Interface.

In order to add or update an S3 bucket, you need to add them to the `terraformResources` field.

- `provider`: must be `s3`
- `account`: must be one of the AWS account names we manage. Current options:
  - `app-sre`
  - `osio`
- `identifier` - name of resource to create (or update)
- `defaults`: path relative to [resources](https://gitlab.cee.redhat.com/service/app-interface/tree/master/resources) to a file with default values. Note that it starts with `/`. Current options:
  - [s3](https://gitlab.cee.redhat.com/service/app-interface/tree/master/resources/terraform/s3-1.yml) - `/terraform/s3-1.yml`
- `overrides`: list of values from `defaults` you wish to override, with the override values. For example: `acl: public`.

Once the changes are merged, the S3 bucket will be created (or updated) and a Kubernetes Secret will be created in the same namespace with all relevant details.
The name of the secret will be `<identifier>-<provider>`. For example, for a resource with `identifier` "my-bucket" and `provider` "s3", the created Secret will be called `my-bucket-s3`.
The Secret will contain the following fields:
- `bucket` - The name of the bucket.
- `aws_access_key_id` - The access key ID.
- `aws_secret_access_key` - The secret access key.


## Design

Additional design information: [here](docs/app-interface/design.md).

[schemas]: <https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas>
[userschema]: <https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/access/user-1.yml>
[crossref]: <https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/common-1.json#L58-L86>
[role]: <https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/access/role-1.yml>
[permission]: <https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/access/permission-1.yml>

## Developer Guide

More information [here](docs/app-interface/developer.md).
