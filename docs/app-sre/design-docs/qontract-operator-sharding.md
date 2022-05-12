# Design doc: Automatic integration sharding

## Author/date

Gerd Oberlechner - May 2022

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-2963

## Problem statement

qontract-reconcile supports sharding integrations for the purpose of parallelizing work for faster reconciliation and error boundaries. Currently sharding is configured statically and does not automatically scale when it would be meaningful.

## Goal

* Introduce automatic integration sharding based on clusters and AWS accounts in app-interface
* Eliminate the need for wrapper integrations like `terraform-resources-wrapper`

## Out of scope

* Implement sharding strategies based on load or other app-interface data
* Remove static sharding via `managed.spec.shards`. Static shard definitions serve a purpose and will be kept as a feature.

## Proposed solution

Add a field `/app-sre/integration-1.yml#managed.spec.shardingStrategy` that defines how an integration in a specific environment will be sharded.

### Cluster sharding

The `per-cluster` sharding strategy watches for all clusters in app-interface where the respective integration is not disabled. For each found cluster, a `Deployment/StatusfulSet` of name `qontract-reconcile-{integration name}-{cluster name}` is created.

```yaml
$schema: /app-sre/integration-1.yml
...
managed:
- namespace: ref-to-integration-namespace.yml
  spec:
    shardingStrategy: per-cluster
```

An integration using that strategy needs to support a flag `--cluster-name`, e.g. `openshift-resource`, `openshift-vault-secrets`, `openshift-routes`, ...

### AWS account sharding

The `per-aws-account` strategy works exactly like the `per-cluster` strategy but operators on AWS accounts instead.

An integration using that strategy needs to support a flag `--account-name`, e.g. `terraform-resources`

This strategy will enable us to deprecate `terraform-resources-wrapper`

## Milestones

Small enough to implement in one bite.
