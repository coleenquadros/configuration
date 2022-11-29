# Granular permission model

## ... in a nutshell

With the granular permission model, engineering teams & partner SRE teams can acquire more permissions to manage and support their own services in app-interface without AppSREs explicit reviews and approvals.

Declarative policies (a.k.a. app-interface `change-types`) enables change permissions from something wide like "change everything for all namespaces in a cluster" to something fine grained as "bump the version of a single vault secret" or "change the TTL of a record in a specific DNS zone".

The key concept is a `/app-interface/change-type-1.yml` and holds the change permissions of structured app-interface files in a declarative way. Change-types can be bound to app-interface datafiles and resources in the context of a `/access/role-1.yml`, effectively making the members of that role app-interface merge-request approvers for the changes described in the change-type.

A list of supported `change-types` can be found [here](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/change-types.md).

You an idea for a new `change-type`? Let us know and create a ticket on the [AppSRE Jira Board](https://issues.redhat.com/projects/APPSRE)


## Quickstart example

All app-interface datafiles (and some resource files) follow a defined schema (e.g. `/app-interface/saas-file-2.yml`) and are well structured documents. A change-type can use `JSONPath` expressions to select parts of such files.

Lets define a simple change-type `/app-interface/changetype/saas-file-self-service.yml`, that grants the self-service permission to change the `deployResources` on saas files.

```yaml
$schema: /app-interface/change-type-1.yml

name: saas-file-self-service

priority: medium

contextType: datafile
contextSchema: /app-sre/saas-file-2.yml

changes:
- provider: jsonPath
  jsonPathSelectors:
  - deployResources
```

The `contextType` and `contextSchema` define the allowed context a change-type can be used, therefore `saas-file-deploy-resource-limits` can only be bound to `datafiles` of the schema `/app-sre/saas-file-2.yml`.

The changes described by this changes-type can be found in the `changes` section. Following the `qontract-reconcile` provider pattern, selection mechanisms other than `JSONPath` can be supported in the future but the `jsonPath` provider is the only one supported right now. `changes.jsonPathSelectors` defines a list of `JSONPath` expressions that will be self-serviceable. In our example, it is everything under `deployResources`. You can learn more about JSONPath [here](https://goessner.net/articles/JsonPath/index.html)) and experiment with on this [playground](https://jsonpath.com/).

The `priority` field defines the order in which merge requests will be processed, and most importantly, merged. Generally, use `urgent` for change types with higher SLOs (like a production promotion), `high` for functional changes (like promoting a secret version), and `medium`/`low` for the rest (Yet to be defined). `critical` is also available, to be used with caution.

Once a change-type is defined, it can be bound to datafiles or resources within the context of an app-interface role.

```yaml
$schema: /access/role-1.yml

name: my-role

...

self_service:
- change_type:
    $ref: /app-interface/changetype/saas-file-self-service.yml
  datafiles:
  - $ref: /services/my-service/my-saas-file.yml
```

Once the change-type and the role are present in the `app-interface` repository, any merge-request targeting the allowed section of the saas file will be approvable by the members of the role. The `self-serviceable` label will appear on the merge-request along with a comment stating the detected changes and the eligible approvers. Any approver can comment with `/lgtm` on the merge-request to put it to the `AppSRE` merge queue where it will be merged automatically following the regular rebase/retest process.

## Role based self-service

change-types and the files they should be applied to are brought together in an app-interface role under the `self_service` section. There are different ways how changes are related back to change-types and approvers.

### Direct ownership

Explicitely listing all datafiles and resources that can be changed by a role is the simplest approach to define ownership.

```yaml
self_service:
- change_type:
    $ref: /app-interface/changetype/saas-file-self-service.yml
  datafiles:
  - $ref: /services/my-service/my-saas-file.yml
- change_type:
    $ref: /app-interface/changetype/rds-defaults-self-service.yml
  resources:
  - /terraform/resources/my-db-defaults.yml
```

The change-type and the saas files related to it share the same schema. So the change-type directly reacts to changes in those files.

### Indirect ownership

The direct ownership approach is very flexible but cumbersome to maintain at scale. Sometimes it makes sense to define ownership on a group of resources, e.g. all namespaces of a cluster.

Lets define a change-type `cluster-owner.yml` that can be bound to a cluster but grants change permissions on the namespaces of that cluster.

```yaml
$schema: /app-interface/change-type-1.yml

name: cluster-owner

contextType: datafile
contextSchema: /openshift/cluster-1.yml

changes:
- provider: jsonPath
  changeSchema: /openshift/namespace-1.yml
  jsonPathSelectors:
  - $
  context:
    selector: cluster.'$ref'
```

The change-type defines `/openshift/cluster-1.yml` as the `contextSchema` so it is valid to attach it to a cluster, but at the same time it mentiones `/openshift/namespace-1.yml` as the `changeSchema`. In this example we will grant permissions on the entire namespace files, so we use the JSONPath `$` which represents the root of the document.

To restrict permissions to namespaces of the cluster the change-type is bound to, we need to declare a `context.selector` that identifies the cluster within the namespace.

Now we can attach the change-type to a cluster.

```yaml
self_service:
- change_type:
    $ref: /app-interface/changetype/cluster-owner.yml
  datafiles:
  - $ref: /openshift/my-cluster/cluster.yml
```

## Advanced example: JSONPaths filtering, macro expansion and conditional context selectors

Another scenario, where the change happens in one file but permissions need to be defined for another one, is role membership. Tenants want to approve membership requests to their roles but the change happens within the `/access/user-1.yml` file under `roles`.

Disclaimer: the `add-role-member` change-type developed in this section is incomplete at first and we will enhance it step by step until we reach the desired solution.

We can define a change-type as follows.

```yaml
$schema: /app-interface/change-type-1.yml

name: add-role-member

contextType: datafile
contextSchema: /access/role-1.yml

changes:
- provider: jsonPath
  changeSchema: /access/user-1.yml
  jsonPathSelectors:
  - roles[*]
  context:
    selector: roles[*].'$ref'
```

The `context.selector` will correctly extract the roles of a user and the `jsonPathSelector` makes sure approvers can only approve changes in the `roles` section of such a userfile. But the `jsonPathSelector` is too wide. It grants permissions to approve ALL changes to the roles of a user, not just for the role the change-type is bound to. We need to narrow down the selector and luckily JSONPath supports filtering.

```yaml
changes:
- provider: jsonPath
  changeSchema: /access/user-1.yml
  jsonPathSelectors:
   - roles[?(@.'$ref'=='{{ ctx_file_path }}')]
```

The new `jsonPathSelectors` uses the filter syntax `?(@.field==value)` combined with Jinja2 macro expansion. The variable `ctx_file_path` resolves to the role path this change-type is bound to. Therefore this JSONPath restricts change permissions to those entries of the `roles` array that represent the role the change-type is bound to. In other words: the approvers can only approve changes that mention their role.

Now lets add some final brushing on this change-type. It is named `ADD-role-member` so we would like to restrict approval permissions when the role is added to a userfile but not when it is removed. This can be achieved by adding the `added` condition to the context selector.

```yaml
changes:
- provider: jsonPath
  ...
  context:
    selector: roles[*].'$ref'
    when: added
```

Similar to the `added` condition, the context selector also supports a `removed` condition.

The final version of this change-type looks like this:

```yaml
---
$schema: /app-interface/change-type-1.yml

name: add-role-member

contextType: datafile
contextSchema: /access/role-1.yml

changes:
- provider: jsonPath
  changeSchema: /access/user-1.yml
  jsonPathSelectors:
  - roles[?(@.'$ref'=='{{ ctx_file_path }}')]
  context:
    selector: roles[*].'$ref'
    when: added
```

## Resource files

All examples up until now were covering change-types for datafiles, but resource files are supported as well. A change-type for a resource file uses `contextType: resourcefile`.

The `contextSchema` property is optional in this situation, because not all resource files adhere to a schema. If a resource file declares a schema and contains a structured document, it can be processed exactly the same way as datafiles and fine grained `jsonPathSelectors` can be used to describe the parts of the file that are covered under the change-type.

Resource files that don't declare a schema or aren't structured documents can't use fine grained change selection within the file. The only available option for the `jsonPathSelector` is `$`, which covers basically the entire file and grants permission to approve arbitrary changes in the file.

Jinja2 templated resource files are currently not considered structured documents. The templating tags prevent parsing the otherwise structured nature of such files and a solution to deal with this has not been found yet :(

## Approval flow

The process to introduce changes into app-interface is a merge-request. A merge-request can change multiple files and also multiple parts per file.

The granular permission model is implemented with the `change-owners` integration and runs as part of the PR check of a merge-request. It introspects the changes and tries to find one or many `change-types` to cover each change. If all changes are covered, the merge-request is considered self-serviceable and will get a label by that name. If a merge-request is not covered or only partially covered by `change-types`, it is considered `non-self-serviceable` and will get a label by that name.

A `self-serviceable` merge-request will show a summary of the detected changes and for each change the potential approver roles and approvers. Approvers can state their decision with `/lgtm`, `/lgtm cancel`, `/hold` and `/hold cancel` comments. An `/lgtm` approves all changes the approver is eligible to approve. If all changes are approved, the `change-owners` integration will add the `bot/approved` label to the merge-request and the `gitlab-housekeeper` integration will process it as part of the merge queue. A single `/hold` adds the `bot/hold` label to the merge-request and prevents it from being mergable regardless of any present approvals until it is canceled.

## Structurally neutral changes

Not all changes in app-interface files have an actual effect on the configuration of the services, e.g. reordering elements in YAML files or adding comments. But those structurally neutral changes are still changes and need to be addressed in merge-requests.

If a file only contains structurally neutral changes, the granular permission model grants approval permissions to tenants that have an arbitrary approval permission on that file already.

Structurally neutral changes will show up in the detected change list as `$file_sha256sum`. We can for sure find a nicer representation for those cases but thats how it is right now ¯\_(ツ)_/¯

## Preventing priviledge escalation

The granular permissions model acts only on merged change-types. This implies that changes to change-types themselves have no effect in the context of a merge-request. This actively prevents privilege escalation where a merge-request introduces a change-type that grants permissions for changes on change-types (or any other flavour of this).

## Disable a change-type

A change-type can be disable by settings the `disabled` property to `true`. This will remove the change-type influence to the approval process while it will still show up in the `change-owners` logs. This is useful

* to temporarily disable a change-type that may not work correctly
* during change-type development to test it in the field

Changes on the `disabled` property of a change-type take effect after the introducing merge-request has been merged.

## Why is a merge-request not self-serviceable?

If a merge-request is not self-serviceable but you expect it to be, check the PR check output of the `change-owners` integration. It shows the detected changes in detail and also states if a matching change-type has been found or not. Especially for merge-requests that are just partially covered by change-types you can easily spot the uncoverd parts.

The `change-owners` logs will also show if a change-type would potentially cover a change but is disabled.

## Test impact of a change-type

The impact of a change-type in the context of a role can be tested with `qontract-cli test-change-type`

Make sure the change-type and the role your want to test are configured as you want them to be. Build a local bundle out of them and start a `qontract-server`, e.g. by running `make dev` from the `qontract-server` repo.

Then run

```bash
qontract-cli test-change-type \
  --change-type-name <change-type-name> \
  --role-name <role-name> \
  --app-interface-path <path-to-app-interface-instance>
```

This will yield the contents of all self-serviceable files having the self-servicable sections highlighted.

Known issues/limitations:

* If the change-type under test uses `context.selector`, the test might take up to a minute to complete.
* change-types with a conditional `context.selectors` can not be tested
* the output might be very long for some change-type/role combinations - an option to provide shorter output will be added in upcoming changes
