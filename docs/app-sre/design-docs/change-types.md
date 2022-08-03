# Design document - describing changes in app-interface

## Author / Date

Gerd Oberlechner
August 2022

## Problem statement

Following the goal of the „fine grained permission model“ initiative, tenants should be allowed to self-service merge certain changes for their services. In order to grant such permissions, those types of changes need to be described. The `saas-file-owners` integrations, which implement self-service merge capabilities for SAAS files, determines the allowed changes in code. This lacks flexibility and needs a more declarable model to enable scaling the self-service concept.

## Goals

AppSRE needs to be capable of defining and testing new change types with low effort and use them to grant fine grained self-service permissions on `app-interface` data to tenants.

## Proposal

Describe types of changes as `app-interface` data and bind it to roles and datafiles/resources.

### Describing change types with expression languages

`app-interface` datafiles (and some resource files) are defined as well structured `yaml` documents. Therefore an expression language like `jsonpath` can be used to describe fine grained selections of document fragments.

We introduce a schema `/app-interface/change-type-1.yml` that describes document change selection on a datafile schema. Change types can be defined not only on datafiles but also on structured resource files that follow a schema.

Following the `provider-pattern`, multiple mechanisms to detect valid change can be implemented. `jsonpath` will be the first supported selection mechanism. Others like graphql queries, Rego expression etc. can be added if required.

This is a schema change proposal that covers the `jsonpath` selection mechanism.

```yaml
---
$schema: /app-interface/change-type-1.yml

name: name for a change type

contextType: datafile or resource
contextSchema: schema for datafile and optionally also for resource files

changes:
- provider: jsonPath
  jsonPathSelectors:
  - list of jsonpath selectors to describe the parts of the schema ...
  - ... that are covered by the change type
```

An example of a change type, that covers the change of secret versions, looks like this:

```yaml
---
$schema: /app-interface/change-type-1.yml

name: secret-promoter

contextType: datafile
contextSchema: /openshift/namespace-1.yml

changes:
- provider: jsonpath
  schema: /openshift/namespace-1.yml
  jsonPathSelectors:
  - openshiftResources[?(@.provider=="vault-secret")].version
```

A jsonpath selector supports conditional selection of document fragments as shown in the example, where only openshift resources of provider `vault-secret` secret were selected.

A `/app-interface/change-type-1.yml` can be used to grant change permissions on datafiles and resources via the `self_service` section of a `/access/role-1.yml`

```yaml
$schema: /access/role-1.yml
...
self_service:
- change_type:
    $ref: /app-interface/changetype/secret-promoter.yml
  datafiles:
  - $ref: /services/my-service/namespaces/stage.yaml
  resources:
  - ...
```

The integration taking care of those `self_service` declarations will make sure that only datafiles/resources can be combined with change types if their `contextType` and `contextSchema` match.

### Logical changes

In certain situations, changes happen in one datafile but change permissions should be logically declared on another datafile, e.g. role memberships of users. Role assignments/removals are changes to the `/access/user-1.yml` files but self-service should be granted based on the involved roles and not the users.

To cover this scenario, the `/app-interface/change-type-1.yml` schema will provide a way to declare a back reference from the changed datafile to the one holding the self-service permissions.

The change type defined in the following example can be used to grant permissions to add and remove roles to/from users. The change declares `contextSchema: /access/role-1.yml` so it can be used to grant permissions to roles. But `changes.schema: /access/user-1.yml` defines to look out for changes in user files under `roles`. So the context this change type operates in is still a `/access/role-1.yml` and that context be found in changed `/access/user-1.yml` files under `roles[*].$ref`.

```yaml
$schema: /access/role-1.yml
...
self_service:
- change_type:
    $ref: /app-interface/changetype/change-role-members.yml
  datafiles:
  - $ref: /team/role.yml

---
$schema: /app-interface/change-type-1.yml

name: change-role-members

contextType: datafile
contextSchema: /access/roles-1.yml

changes:
- type: jsonPath
  schema: /access/user-1.yml
  jsonPathSelectors:
  - roles
  contextSelector: roles[*].$ref
```

### Testing change types

Change types can describe complex selection scenarios. Testing change types is going to become crucial to make sure tenants can only change the intended parts of their service.

Means of testing (cli utility, test data similar to query templates) will be provided to ensure change types are defined correctly and keep working correctly.
