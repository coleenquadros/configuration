# Design document - shard specific integration deployments

## Author / Date

Jan-Hendrik Boll
August 2022

### Tracking JIRA

https://issues.redhat.com/browse/APPSRE-6100

## Problem statement

As SRE I might need do code changes, that could have a huge blast radius. I.e.:

 * Refactoring terraform client code
 * Updating terraform binary

As of now there is no way of rolling out changes for i.e. only certain AWS accounts.

## Goals

Enable staged rollouts of qontract-reconcile integrations, shard by shard. 

## Non-Goals

* Automate staged rollout
* Solve integration to schema versioning issue, thus schema related changes could break this rollout approach

## Proposal

The proposed solution is to have shard specific overrides for things like the image tag. This would enable us to rollout changes on a per account basis, since i.e. terraform-resources is sharded by AWS accounts.

### Shard specific overrides in integration-manager

The integration-1 schema is extended to allow overwriting the image tag (here imageRef) of a specific shard. See following example for the terraform-resources integration. The default imageRef used is latest. The imageRef is overwritten for the account `app-int-example-01`. Shards can be specified by either an AWS account reference or the shard id.


```YAML
$schema: /app-sre/integration-1.yml
...
managed:
- namespace:
    $ref: /clusters/appint-ex-01/namespaces/testing.yml
  shardSpecOverride:
    - imageRef: foo
      shard:
        $ref: /aws/app-int-example-01/account.yml
  spec:
    ...
    imageRef: latest
    shardingStrategy: per-aws-account
...
```

This implies that image tags for the integrations are specified in app-interface. `RECONCILE_IMAGE_TAG` from `.env` is thus replaced by this schema change. 

### Staged rollout

A staged rollout can now happen by changing the default imageRef to a sha previous to a risky change. See following example where the default image is set to `stable`. For testing, the image for the shard  `app-int-example-01` is overwritten to `superdangerous`.

```YAML
$schema: /app-sre/integration-1.yml
...
managed:
- namespace:
    $ref: /clusters/appint-ex-01/namespaces/testing.yml
  shardSpecOverride:
    - imageRef: superdangerous
      shard:
        $ref: /aws/app-int-example-01/account.yml
  spec:
    ...
    imageRef: stable
    shardingStrategy: per-aws-account
...
```

This does not change the way we merge to qontract-reconcile. In this example `stable` and `superdangerous` are both already merged to master. It's only that we select certain shards to use the updated image. 

## Future work

This change opens the door for additional shard specific overrides. An example could varying resource settings for shards. 
