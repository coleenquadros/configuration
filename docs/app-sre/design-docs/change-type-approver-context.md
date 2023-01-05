# Design document - natural ownership

## Author / Date

Gerd Oberlechner / December 2022

Jira [APPSRE-6629](https://issues.redhat.com/browse/APPSRE-6629)

## Problem statement

Currently we bring together `change-types` and owned files in the context of a role. That works well and is the most flexible way to establish permissions. Sadly it is also the most cumbersome way of doing it. Especially for situations where we have a lot of files and where very individual ownerships are necessary.

For example `/access/user-1.yml`. It is simply not feasible to grant each user permissions on their own files via roles. That would require one role per user. What makes it even worse is the fact, that the information necessary to define this natural ownership is already there - the user file would represents the owner and the owned file at the same time.

In other cases, the information about a natural owner is directly present or referenceable from the file, e.g. `/app-sre/gabi-instance-1.yml#signoffManagers`.

Being forced to declare such ownerships explicitly is a scaling issue for the granular permission model and Hybrid SRE. It brings back toil through ownership management.

## Goals

Define a way to declare natural ownership for files in the context of a `change-type`.

## Proposal

Add a configuration section to the `/app-interface/change-type-1.yml` schema to make a `change-type` self-aware of natural ownership.

```yaml
$schema: /app-interface/change-type-1.yml
...
ownership:
- provider: jsonPath
  jsonPath: .. jsonpath to select the approver
```

The `ownership.jsonPath` field defines how to find an approver reference in a file.

### Example 1

Users should be able to lifecycle their own `public_gpg_key`.

```yaml
$schema: /app-interface/change-type-1.yml
...
contextSchema: /access/user-1.yml
changes:
- public_gpg_key
ownership:
- provider: jsonPath
  jsonPath: $
```

The `jsonPath: $` is a special JsonPath placeholder for the root of an object, which makes sense in this scenario where users manage themselves.

### Example 2

Gabi signoff-managers can manage the users of their Gabi instance.

```yaml
$schema: /app-interface/change-type-1.yml
...
contextSchema: /app-sre/gabi-instance-1.yml
changes:
- users
ownership:
- provider: jsonPath
  jsonPath: signoffManagers[*].'$ref'
```

## Interaction with explicit ownership

A natural ownership behaves as if it would be an explicit ownership defined in a role. `Example 1` would behave exactly as the following more verbose declaration:

```yaml
$schema: /access/user-1.yml
org_username: user_a
public_gpg_key: |
   xxxxxx
   xxxxxx
roles:
- $ref: user_a_self_management_role.yml


$schema: /access/role-1.yml
name: user_a_self_management_role
self_service:
- change_type:
    $ref: user-public-gpg-key-change-type.yml
  datafiles:
  - $ref: user_a.yml
```

In a PR where more fields than just the `public_gpg_key` of a user are changed, multiple `change-types` would be able to cooperate to enable full-service and multiple teams (roles) would need to `/lgtm` before the PR would be considered approved. It does not matter where ownership comes from. As soon as ownership exists, all of them are treated equally.
