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

~~With terraform-resources integration we call `shards` to aws accounts, but those could be seen as `partitions`. We can enhance our current sharding strategy to add `partitions` over the data. Then, if a `partition` is large enough, we can apply `sharding` over it. This approach can be extended to multiple `partition` definitions like `per-cluster`, `per-ocm-environment`, `per-aws-accounts`, etc.~~

~~This way we can improve the isolation level of our integrations, reducing the blast radius when issues arise, and gaining the ability to introduce changes in a reduced scope of targets.~~

~~To deploy changes over a single partition we will leverage our current shard-specific-integration-deployments strategy, changing it to fit the `partitions`. In next iterations it might make sense to define environments over partitions and define staged rollouts.~~

After spiking and writing some code around it, I think introducing the concept as sub-sharding suits better and is less disruptive. The idea remains the same: Integrations that are subject to be horizontally partitioned by a clear attribute (`per-openshift-cluster`, `per-aws-account`, `per-cloudflare-zone`, etc.) will be **sharded** by that attribute. If a specific shard is big enough to be split,
it will be possible to apply a **sub-sharding** strategy over it.

To start, using the current hash based sharding strategy that we use as a `sub-sharding` strategy is enough for now. `sub-sharding` will be configured using integration configuration overrides as we do right now to override the container images.

The sharding configuration for integrations will be improved to allow more changes at the pod level and it will be grouped under a `sharding` section. All `sub-shards` will get the same configuration, there will be no distinctions at this second level of sharding. Check the examples for a more clear understanding.

### Some practical examples

```yaml
managed:
- namespace:
    $ref: /services/app-interface/namespaces/app-interface-production-int.yml
  spec:
    resources:
      requests:
        memory: 500Mi
        cpu: 500m
      limits:
        memory: 1000Mi
        cpu: 1200m
    sharding:
      strategy: per-openshift-cluster
      shardSpecOverrides:
      - shard: appsrep05ue1
        subSharding:
          strategy: static
          shards: 20
      - shard: app-sre-stage-01
        imageRef: my-dangerous-change
        resources:
          requests:
            memory: 2Gi
            cpu: 2
          limits:
            memory: 2Gazillions
            cpu: 100
        subSharding:
          strategy: static
          shards: 5

---
# Another case with just a static sharding. But setting the sharding attributes
# under the sharding section
managed:
- namespace:
    $ref: /services/app-interface/namespaces/app-interface-production-int.yml
  spec:
    resources:
      requests:
        memory: 500Mi
        cpu: 500m
      limits:
        memory: 1000Mi
        cpu: 1200m
    sharding:
      strategy: static
      shards: 20

```


## Alternatives considered

- N/A

## Milestones

 1. Definition of the solution and discuss viability
 2. Implement the per-cluster partition type over openshift-resources integration.
