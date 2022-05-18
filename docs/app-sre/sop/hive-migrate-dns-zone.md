# Migrate DNS zone for Hive

## Background

Following the p1.openshiftapps.com not resolvable incident (https://issues.redhat.com/browse/OHSS-7390), we are working on managing Hive DNS zones via app-interface in https://issues.redhat.com/browse/OSD-8770.

As part of this work, we need to update Hive to use a new DNS zone managed via app-interface, instead of the one that is currently being used.

## Purpose

Describe the process to switch Hive to use a new DNS zone.

## Process

### Preparation

In this part, we will prepare and populate the destination DNS zone.

1. Pre-create the destination DNS zone [via app-interface](https://gitlab.cee.redhat.com/service/app-interface#manage-external-dns-zones-via-app-interface-openshiftnamespace-1yml). This will result in a Secret with credentials to manage the DNS zone. See [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/1f590c8ee98845853a2a09a8339ebffdf7ca037a/data/services/hive/namespaces/hive-stage-01/hive-stage.yml#L125-129)

1. Add the DNS zone output resource to all Hive shards using a shared resources file. This is for all Hive shards to consume the same DNS zone.

1. Create a temporary [shared resources](https://gitlab.cee.redhat.com/service/app-interface#manage-shared-openshift-resources-via-app-interface-openshiftnamespace-1yml) file with the new HiveConfig Route53 credentials.

1. Record the state of all shards before starting (each shard - is it active or not?)

1. For each Hive shard:
    - If shard is active - Submit a MR#1 to [disable cluster provisioning](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/hive-shard-provisioning.md#disabling-shards-from-rotation) for the [shard](https://gitlab.cee.redhat.com/service/app-interface/-/blob/2ac0b9ba83d07dc6257ba87dd3cfa93ee37ec49d/data/services/ocm/shared-resources/production.yml#L21-51)
    - Submit MR#2 to update the Hive namespace file to use a temporary shared resources file with a different [HiveConfig](https://gitlab.cee.redhat.com/service/app-interface/-/blob/1f590c8ee98845853a2a09a8339ebffdf7ca037a/resources/services/hive/stage/hive.hiveconfig.yaml#L50) which uses the newly created Secret. This will cause Hive controller to restart and populate the destination DNS zone. We want to do this to populate the DNS zone ahead of time to avoid rate limiting issues.
    - Submit MR#3 to revert MR#2, to use the original Secret until the migration itself.
    - If shard was active - Submit MR#4 to enable cluster provisioning for the shard.

1. Reduce TTL for the NS delegation record zone according to the [Hive external DNS SOP](https://github.com/openshift/ops-sop/blob/master/v4/troubleshoot/hive-external-dns.md).

### Migration

In this part, we will perform the migration itself. The destination DNS zone should contain most of the existing records as the source DNS zone. This should alleviate any rate limit issues.

In case the destination DNS zone is missing more than 20 records (a low number guesstimate), repeat the preparation part.

1. Submit a MR to update the HiveConfig to use the newly created Secret.
    * Once this MR is merged, Hive controller pods will be recycled to pick up the new Secret and will start populating the destination DNS zone. See [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/1f590c8ee98845853a2a09a8339ebffdf7ca037a/resources/services/hive/stage/hive.hiveconfig.yaml#L50)
1. Update the DNS delegation to point at the newly created DNS zone according to the [Hive external DNS SOP](https://github.com/openshift/ops-sop/blob/master/v4/troubleshoot/hive-external-dns.md).

#### Estimated time for migration

The migration begins once the MR to update HiveConfig is merged. More precisely, once it is applied to Hive clusters. When the HiveConfig is applied, Hive controllers restart, and starts using the destination DNS zone, while the DNS delegation points at the source DNS zone. Once all Hives are restarted, it would be a matter of seconds before any missing entries are added to the destination DNS zone.

This part will take ~2 minute.

Once it is verified that the number of records in the source and destination zones are equal, the DNS delegation should be updated to point to the destination zone. It will take 60 seconds (TTL) for the delegation to be updated to point to the destination DNS zone.

This part will take ~1 minute.

Adding to that any residual DNS propogation time of ~5-10 minutes.

Total estimated time for the migration is hence between 8-13 minutes.

### Rollback

In case anything goes wrong, the rollback plan is:
1. Revert DNS delegation update, and point back to the source DNS zone.
2. Revert HiveConfig update, and point Hive back to use the source DNS zone.

## Impact

If a new cluster will be created after the Secret change in the HiveConfig, the DNS entry for the cluster will be created in the destination DNS zone, while DNS will still be pointing at the source DNS zone. This means that the cluster will not be reachable until DNS delegation is updated.

Assuming the update of the Secret has successfully caused the population of the destination DNS zone, this will mean that the only impact is:

"New clusters may not be reachable for an additional 8-13 minutes".

In reality, since cluster provisioning takes longer, there will likely be no impact for customers.
