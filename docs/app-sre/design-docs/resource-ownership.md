# Design document - app-interface resource/data ownership

## Author / Date

Gerd Oberlechner / July 2022

## Problem statement

The current app-interface saas-file self service capability allows AppSRE tenants to approve certain changes on their owned saas-files without AppSRE involvement. Ownership of saas files is declared within `/access/role-1.yml#owned_saas_files` and this information is leveraged by the `saas-file-owners` integration to determine when and who can approve a change.

The [granular permission model initiative](../initiatives/fine-grained-permission-model.md) seeks to apply the same approach of self-service approval to arbitrary types of changes. Therefore also ownership must be declarable in a more general way.

## Goal

* Declare general resource and datafile ownership on role level so ownership can be granted to users by granting the role

## Out of scope

The actual declaration of change types (what can be changed in a self service manner) will be part of a follow up design document.

## Proposal

Enhance the `/access/role-1.yml` schema to allow the declaration of owned datafiles and resources within `owned_datafiles` and `owned_resources`. The items of these list will be objects grouping datafiles or resourcefiles respectively. This way, each group can be enhanced in the future by adding additional attributes to refine the ownership relation, e.g. assigning a `change_type` to a group of datafiles or resources.

```yaml
---
$schema: /access/role-1.yml
...
ownded_datafiles:
- datafiles:
  - $ref: a datafile
  ...
  [change_type: ...] # not part of this design doc, just mentioned as a heads up
owned_resources:
- resources:
  - /path/to/a/resource
  ...
  [change_type: ...] # not part of this design doc, just mentioned as a heads up
```

## Datafiles

On the jsonschema side, `owned_datafiles.datafiles` is a list of `crossref` with a `$schemaRef` enum that will allow us to restrict the datafile types that can be referenced and will be enforced during bundle validation. The result is a list of mixed typed datafile references.

On the GraphQL side, mixed types within a list need to be implemented with `interfaces`. We will dynamically add an interface `DatafileObject_v1` to all datafile types at `qontract-server` runtime and introduce an `interfaceResolve.strategy = schema` which resolves resource references based on their `$schema`.

```yaml
- name: DatafileObject_v1
  isInterface: true
  interfaceResolve:
    strategy: schema
  fields:
  - { name: path, type: string, isRequired: true }
  - { name: schema, type: string, isRequired: true }
```

A role declaration with owned datafiles and resources will look like this:

```yaml
---
$schema: /access/role-1.yml
...
owned_datafiles:
- description: AppSRE services
  datafiles:
  - $ref: /services/github-mirror/cicd/deploy.yaml
  - $ref: /services/github-mirror/cicd/test.yaml
  ...
owned_resources:
- description: some configmaps
  resources:
  - /app-sre/app-interface-production/qontract-api.configmap.yaml
  ...
```

This makes the owned resources and datafiles queryable like this

```
{
  roles_v1 {
    owned_datafiles {
      description
      datafiles {
        path
      }
    }
    owned_resources {
      description
      resources
    }
  }
}
```

Since this interface is fully integrated into the apollo type system at runtime, also queries like the following are supported

```
{
  roles_v1 {
    owned_datafiles {
      description
      datafiles {
        path
        ... on SaasFile_v2 {
          name
        }
      }
    }
    owned_resources {
      description
      resources
    }
  }
}
```

## Milestones

* Milestone 1 - Implement dynamic `DatafileObject_v1` interface assignment in `qontract-server` and perform respective change in `qontract-schema`.
* Milestone 2 - Start using `owned_resources` for the `saas-file-owners` integration and deprecate `owned_saas_files`
