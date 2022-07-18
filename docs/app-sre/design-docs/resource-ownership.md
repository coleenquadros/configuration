# Design document - app-interface resource ownership

## Author / Date

Gerd Oberlechner / July 2022

## Problem statement

The current app-interface saas-file self service capability allows AppSRE tenants to approve certain changes on their owned saas-files without AppSRE involvement. Ownership of saas files is declared within `/access/role-1.yml#owned_saas_files` and this information is leveraged by the `saas-file-owners` integration to determine when and who can approve a change.

The [granular permission model initiative](../initiatives/fine-grained-permission-model.md) seeks to apply the same approach of self-service approval to arbitrary types of changes. Therefore also ownership must be declarable in a more general way.

## Goal

* Declare general resource ownership on role level so resources ownership can be granted to users by granting the role.
* Define all resource ownerships within one schema element to prevent field explosion within the `/access/role-1.yml` schema.

## Out of scope

The actual declaration of change types (what can be changed in a self service manner) will be part of a follow up design document.

## Proposal

Enhance the `/access/role-1.yml` schema to allow the declaration of owned resources within a list `owned_resources`. The items of this list will be objects with one field `resource`, which is a reference to a datafile. Defining this as an objects enables extensibility, e.g. the types of changes granted on such a resource can be defined in an future field `change_type`.

```yaml
---
$schema: /access/role-1.yml
...
owned_resources:
- resource:
    $ref: a resource
  change_type:  # not part of this design doc, just mentioned as a heads up
    $ref: a change type
```

On the jsonschema side, `owned_resources.resource` is a `crossref` with a `$schemaRef` enum that will allow us to restrict the datafile types that can be referenced and will be enforced during bundle validation. The result is a list of mixed typed datafile references.

On the GraphQL side, mixed types within a list need to be implemented with `interfaces`. We will dynamically add an interface `PathObject_v1` to all datafile types at `qontract-server` runtime and introduce an `interfaceResolve.strategy = schema` which resolves resource references based on their `$schema`.

```yaml
- name: PathObject_v1
  isInterface: true
  interfaceResolve:
    strategy: schema
  fields:
  - { name: path, type: string, isRequired: true }
```

The `Role_v1` can then reference a list of `PathObjects_v1`.

```yaml
- name: Role_v1
  datafile: /access/role-1.yml
  fields:
  ...
  - { name: owned_resources, type: PathObject_v1, isList: true, isInterface: true }
  ...
```

This makes the owned resources queryable like this

```
{
  roles_v1 {
    owned_resources {
      resource {
        path
      }
    }
  }
}
```

Since this interface is fully integrated into the apollo type system at runtime, also queries like the following are supported

```
{
  roles_v1(path: "/teams/app-sre/roles/app-sre.yml") {
    name
    ownedresources {
      resource {
        path
        ... on SaasFile_v2 {
          name
        }
        ... on App_v1 {
          onboardingStatus
        }
      }
    }
  }
}
```

## Milestones

* Milestone 1 - Implement dynamic `PathObject_v1` interface assignment in `qontract-server` and perform respective change in `qontract-schema`.
* Milestone 2 - Start using `owned_resources` for the `saas-file-owners` integration and deprecate `owned_saas_files`
