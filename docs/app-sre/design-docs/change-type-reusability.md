# Design document - change-type reusability and ownership extension

## Author / Date

Gerd Oberlechner / December 2022

Jira: https://issues.redhat.com/browse/APPSRE-6651

## Problem statement

`change-types` can not easily be reused in different contexts as they define the context within they can act with their `contextSchema` field. The mentioned schema restricts how ownership can be defined via the `self_service` section of an `/access/role-1.yml` and how ownership can be expanded via `changes.context`.

E.g. the following `change-types` operates on `/openshift/namespace-1.yml` and can be used on owned namespaces.

```yaml
$schema: /app-interface/change-type-1.yml
name: namespace-owner
contextSchema: /openshift/namespace-1.yml
changes:
- provider: jsonPath
  jsonPathSelectors:
    <allowed changes to namespaces>

$schema: /access/role-1.yml
name: my-role
self_service:
- change_type:
    $ref: namespace-owner.yml
  datafiles:
  - $ref: my-namespace-1.yml
  - $ref: my-namespace-2.yml
```

If we would like to define higher level concepts for ownership, e.g. allow management of namespaces that belong to an `/app-sre/app-1.yml`, this `change-type` can't be reused, and we would need to create a nearly identical one, one that defines `/app-sre/app-1.yml` as `contextSchema` and knows how to find that context in a namespace via `changes.context.selector` (see "indirect ownership" in the [change-type docs](/docs/app-sre/change-types.md)).

```yaml
$schema: /app-interface/change-type-1.yml
name: app-based-namespace-owner
contextSchema: /app-sre/app-1.yml
changes:
- provider: jsonPath
  changeSchema: /openshift/namespace-1.yml
  context:
    selector: app.'$ref'
  jsonPathSelectors:
    <mention the same allowed changes again :(>

$schema: /access/role-1.yml
name: my-role
self_service:
- change_type:
    $ref: app-based-namespace-owner.yml
  datafiles:
  - $ref: my-app.yml
```

This is undesired duplication and makes [higher level concepts for ownership](https://issues.redhat.com/browse/SDE-2418) harder to achieve.

## Goals

Make `change-types` reusable in different contexts and enable ownership expansion.

## Proposal

Add a new change provider named `change-type` to `/app-interface/change-type-1.yml#changes.provider` that can reference an existing `change-type` and put it into the context of `changes.context`.

```yaml
- provider: change-type         <-- new provider
  changeTypes:
  - $ref: namespace-owner.yml   <-- puts the existing change-type ...
  context:                      <-- ... into a new context
    selector: app.'$ref'
```

This makes a change-type reusable in new contexts and also enables us to define higher level concepts of ownership.

### Example

Lets solve the situation from the problem statement: use the existing `namespace-owner` `change-type` in the context of an `/app-sre/app-1.yml` - grant `namespace-owner` permissions to whomever has permissions on the app.

We introduce a new `change-type` `app-owner` that has `/app-sre/app-1.yml` as `contextSchema`. In the `changes` section we define an entry using the new `change-type` provider and reference the existing `namespace-owner` `change-type`. With `context.selector: app.'$ref'` we define that the `namespace-owner` `change-type` should be applied to all namespaces of an owned app.

```yaml
$schema: /app-interface/change-type-1.yml
name: app-owner
contextSchema: /app-sre/app-1.yml
changes:
- provider: change-type
  changeSchema: /openshift/namespace-1.yml
  context:
    selector: app.'$ref'
  changeTypes:
  - $ref: namespace-owner.yml
- ...

$schema: /access/role-1.yml
name: my-role
self_service:
- change_type:
    $ref: app-owner.yml
  datafiles:
  - $ref: my-app.yml
```

The way `changes.context` is configured is unchanged. The result of this `change-type` is identical to assigning the `namespace-owner` `change-type` to all namespaces of an app explicitely.
