# Design document: Explicit resource reference metadata in qontract-schema data files

## Author/date

Gerd Oberlechner / May 2022

## Context

`app-interface` repositories consist of two types of files:

* data files - they adhere to a schema defined in qontract-schema
* resources file - arbitrary files that are bundled together with data files but don't adhere to any schema

It is very common that data files reference resource files, e.g. an RDS instance declaration references a resource file that contains certain RDS defaults

```yaml
....
terraformResources:
- provider: RDS
  ...
  defaults: /reference/to/resourcefile
  ...
```

## Problem statement

Resource reference fields in data file schemas are pure strings with no additional information about their referencing nature available. This implies, that qontract-validator has no way to verify resource references and app-interface PR checks will only find invalid references during integration dry-runs. This increases the duration of PR checks that will fail for sure in the end.

Currently, resource files can't reliably be back-referenced to a data file, which makes the integration selection mechanism during PR checks unreliable and bound to path conventions (e.g. a PR check will run `terraform-resources` when a file under `/resources/terraform/` is changed).

Additionally, applications relying on schema introspection are blind about resource references as well and can't react properly (e.g. qontract-reconcile dataclass generator).

## Goal

* Make data file schemas aware of resource references without breaking current schemas
* Verify resource file references during bundling
* Make resource reference metadata explicit so it can be used to enable better integration selection during PR checks
* Fail app-interface PR checks faster when resource references are invalid

## Proposal

Introduce a common type declaration `/common-1.json#/definitions/resourceref` that is compatible with `string` but represents a path to a resource.

```yaml
---
"$schema": /metaschema-1.json
version: '1.0'
type: object
...
properties:
  ...
  path:
    "$ref": "/common-1.json#/definitions/resourceref"
```

This information can be used in `qontract-validator` to verify resource references and enables fast fail for PR checks during bundle creation. At the same time it is compatible with current data.

Additionally add a property `isResourceRef = true` to the respective field in the graphql schema. This can leveraged during schema introspection.

During bundle creation, `resources.backrefs` will be filled with a list of data files that reference a resource.

```json
{
    ...
    "resources": {
        "/path/to/resource": {
            "content": "...",
            ...
            "backrefs": [
                {
                    "path": "/path/to/datafile.yml",
                    "datafileSchema": "/openshift/namespace-1.yml",
                    "type": "Namespace_v1",
                    "jsonpath": "jsonpath to element that references a resource"
                },
            ]
        }
    }
    ...
}
```

Those backrefs will be queryable and can be used during PR checks to properly identify data files that indirectly change along with a resource file, and thus allow fine selection of integrations to run during PR checks.

## Milestones

Small enough for one bite.
