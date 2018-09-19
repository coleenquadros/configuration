# Hosted Services

This repository serves as a central coordination point for hosted services being run by the Application SRE team.
Many or all of the portions of the contract defined herein will be handled through automation after changes are accepted to this repository by the appropriate parties.

## Hosted Services Contract

A service exists as one or more subdirectories to this repository, containing instances of the [JSON-Schemas](https://json-schema.org/) defined in the `schemas` subdirectory of this repository.

## Features

### Existing Features

None

### Planned Features

- Walk the tree of service definitions and execute any and all matching integrations against schema instance
- Automatically generate JSON schema docs from the set of schemas provided: [CloudFlare JSON-Schema tools](https://github.com/cloudflare/json-schema-tools)
- Self-hosted automation, devshift.net tooling is described and conforms to this contract
- Unify common patterns like machine readable indentifiers when [draft-08](https://github.com/json-schema-org/json-schema-spec/milestone/6) is ratified
- (stretch) Provide a full platform which can help in onboarding a new service and do the Git PR workflow against the source of truth repository
  - https://github.com/mozilla-services/react-jsonschema-form
  - [Libgit2 MySQL backend](https://www.perforce.com/blog/your-git-repository-database-pluggable-backends-libgit2)

## Integrations

### Requirements for any integration

- Idempotent, and integration should result in the same thing if run multiple times with same input
- Runnable as a script or as a component of an application
- Schema definitions must predictably be able to determine what an operation to a map property name, or array item will do in the integration
  - stableIndexList, stableIdentifierList, and stableMapName are provided schema fragments and strategies for signaling this to the schema validated config writer (i.e. service owner)
- Full rectification loop between things that are declared in the management plane and the running systems
  - Creation
  - Mutations
  - Removal
- Integrations are triggered based on the schemas that are declared via the `$schema` property in the instances

### Existing Integrations

None

### Planned integrations

- Top level tracking of managed services, their contact points, and work streams: `schemas/app-sre`
- GitHub team syncing with lists of Red Hat users: `schemas/users/`
- Automatically managing a Vault installation and federating access: `schemas/vault`
- Management of OLM catalog entries for managing service operators: `schemas/olm`
- Ownership of OpenShift Kubernetes namespace resources: `schemas/opensfhit`
- Management of cluster monitoring, such as zabbix, prometheus, and alert manager: `schemas/monitoring`

## Integration Notes

### Vault notes:

```
Authenticate users in vault against github with a github token
2 ways to map policies to github entities
Team or individual members of team
Avoid having individuals
app-sre organization and osio-dev team
have an ansible role that is managing policies and mappings
api calls
if you remove a policy it stays in the vault install
present in the DB
need a destructor
need to pick the policy name, and pick the policy mapping in github
going to rewrite in go in order to do full rectification loop
```

### Service index:

```
schema for openshift projects that we deploy
List of all of the things we own, even with no automation
Link to JIRA filtered by service label
Link to source control filtered to repo
Responsible parties
Enum for [user facing, red hat facing, automation]
Enum for status [extenrally manager, managed by automation, partially managed]
```