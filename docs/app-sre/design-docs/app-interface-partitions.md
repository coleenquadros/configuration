# Design doc: More granular QR Rollouts

## Author/date

Jordi Piriz / 2023-01-09

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-6774

## Problem Statement

We don't have a reliable way to rollout possible dangerous changes to Openshift-resources based integrations.
As a practical example, [APPSRE-6724](https://issues.redhat.com/browse/APPSRE-6724) introduces a new resources diff strategy that could cause issues with the deployed resources. With our current approach, we can override a shard with the new code, but that does not limit the target clusters where the code will run. It makes sense to deploy those (or even all) changes to the staging clusters first, and then promote the changes to the production clusters.

## Goals

- Define a reliable way to deploy changes to a limited set of target clusters.

## Non-objectives

- Automate staged rollouts

## Proposal

With terraform-resources integration we call `shards` to aws accounts, but those could be seen as `partitions`. We can enhance our current sharding strategy to add `partitions` over the data. Then, if a `partition` is large enough, we can apply `sharding` over it. This approach can be extended to multiple `partition` definitions like `per-cluster`, `per-ocm-environment`, `per-aws-accounts`, etc.

This way we can improve the isolation level of our integrations, reducing the blast radius when issues arise, and gaining the ability to introduce changes in a reduced scope of targets.

To deploy changes over a single partition we will leverage our current shard-specific-integration-deployments strategy, changing it to fit the `partitions`. In next iterations it might make sense to define environments over partitions and define staged rollouts.

### Some practical examples

Disclaimer: These are examples, the shard values might not make sense.

- Openshift-resources:
  Partitions:
    Strategy: per-cluster
    Items:
      - cluster: app-sre-prod-01:
        shards: 3
      - cluster: app-sre-stage-01:
        shards: 1

- Terraform-resources:
  Partitions:
    Strategy: per-aws-account
    Items:
      - app-sre:
        shards: 3
      - app-sre-stage:
        shards: 1

- ocm-clusters:
  Partitions:
    Strategy: per-ocm-environment
    Items:
      - prod:
        shards: 1
      - stage:
        shards: 1

## Alternatives considered

- N/A

## Milestones

 1. Definition of the solution and discuss viability
 2. Implement the per-cluster partition type over openshift-resources integration.
