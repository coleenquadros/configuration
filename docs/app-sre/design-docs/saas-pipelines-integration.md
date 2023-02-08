# Design document - SaaS Pipelines Integration

## Author / Date

Karl Fischer
February 2023

## Tracking JIRA

[APPSRE-6941](https://issues.redhat.com/browse/APPSRE-6941)

## Problem statement

We often see merge conflicts in auto-promotion MRs created by our devtools bot.
Promotions are currently event based. Gitlab sends messages to an SQS queue if
an auto-promotion is desired as result of a merge.
The SQS queue is read by an integration, which then creates auto-promotion MRs.

An auto-promotion can take some time. If a change was done to a saas file in the
meantime, then we will see merge confilcts that currently need manual intervention.
Changes can happen by a human, but they can also happen through multiple in-flight
MRs from the auto-promoter process.

Further, we have multiple integrations now handling our SaaS file defined pipelines.
Each integration runs in its own context and special care must be taken to clearly
define and properly detect ownership of triggering the next step. I.e., it must be
avoided that multiple integrations trigger the next step by accident.

## Goals

* Solution to avoid merge conflicts in auto-promotions
* Create one common context for pipeline decisions

## Proposal

We create a new integration that consolidates existing saas trigger integrations.
By having a single integration managing the pipelines, it is easier to maintain context.
I.e., you do not have to worry what another integration might do in parallel.
What happens when multiple triggers apply at the same time?
A single integration can streamline the reason(s) for a trigger in a single context
easier than multiple integrations, each with their own context.

Further, the new integration relies on a reconciliation loop rather than on events.

By having more context, it will be easier to avoid merge conflicts.

We use a custom statefile in S3 to track real-world state. We already do that for
existing integrations.

### Scenarios to consider

#### Moving Commits

```yaml
resourceTemplates:
- name: my-service
  url: https://github.com/my/service
  path: /openshift/template.yaml
  targets:
  - namespace:
      $ref: /services/my-service/namespaces/stage.yaml
    ref: main
```

In this scenario we reference a branch that points to a commit.
The commit can change without any change to the SaaS file itself.

This can be easily detected by storing the currently deployed commit sha
in a statefile.

#### SaaS file change a.k.a. Config change

In this case something changes in the SaaS file definition.

TODO: any change leads to trigger or just a change in a certain section???

#### Upstream Jenkins Jobs

```yaml
resourceTemplates:
- name: my-service
  url: https://github.com/my/service
  path: /openshift/template.yaml
  targets:
  - namespace:
      $ref: /services/my-service/namespaces/stage.yaml
    ref: main
    upstream:
      instance:
        $ref: /dependencies/ci-ext/ci-ext.yml
      name: my-service-gh-build-master
```

In this scenario we trigger a deployment whenever a new (successful) build is detected
in the upstream Jenkins job.

#### New Container Images

TODO

#### Promotions through other SaaS file targets

TODO

### 

## Alternatives

* ArgoCD ???

## Milestones

* TODO
