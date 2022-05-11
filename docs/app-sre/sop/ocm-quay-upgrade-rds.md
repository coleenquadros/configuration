# Upgrading RDS for OCM-Quay

There are some special considerations when upgrading OCM Quay RDS instances. These will be covered below, but see the [architecture document](docs/app-sre/sop/ocm-quay-upgrade-rds.md) for more background about the service itself.

## Notifications

@sre-platform-region-leads and @dsantama from #sd-cicd should be notified once we're ready to schedule maintenance.

An example message that was shared in #sd-app-sre can be seen here: https://coreos.slack.com/archives/CCRND57FW/p1651842103993419

## Impact

See the architecture document, mentioned above, for the most up-to-date information about the architecture. At a high-level, the impact is:

* Updating the RO databases shouldn't be impactful as long as we remove the associated cluster from the `pull` DNS record first (only do one at a time)
* Updating the RW database will result in an outage for the `push` endpoint of OCM-Quay. Some implications of this are:
  * [mirror of images from quay.io](/docs/app-sre/ocm-quay-mirroring.md) to OCM-Quay will fail transiently, but should recover because the process is idempotent
  * Service Delivery CICD (#sd-cicd) systems alternate between using quay.io and OCM-Quay, so the team should be notified (mention of reaching out to @dsantama above)

Additional, it seems that there may be some OSD customers using OCM-Quay directly because of concerns of opening up the firewall in their organizations to quay.io. This was brought to our attention by @jmelis and there will be ongoing discussions about whether this can be easily undone. For now, this shouldn't prevent us from taking downtime to upgrade our databases, but it's good to be aware of.

## Procedure

This database should be upgraded during business hours because it requires modifying DNS records, so we cannot rely on RDS maintenance windows performing this maintenance after hours. It's also a fallback for quay.io for OSD use cases only, so it shouldn't be noticeable to most teams (unless quay.io is down).

As with all RDS instances, the replicas must be upgraded first. The procedure below describes two distinct operations, upgrading the replicas and upgrading the primary. It is okay, and probably desirable, to separate the upgrades of replicas by a day or so, and likewise with the primary.

### Upgrading replicas

**NOTE: ONLY UPGRADE ONE REPLICA AT A TIME**

1. See the [Notifications](#notifications) section above and make sure that you've notified the correct teams
2. Verify that there aren't any ongoing issues with quay.io (this is a fallback system for OSD use cases if quay.io is down). Don't proceed if there is any hint of issues with quay.io.
3. Verify that the TTL value for `pull.q1w2.quay.rhcloud.com` is set to a low enough value that clients will pick up changes to DNS records that we will make below (at the time of writing, this is <60s)
4. Create a MR to update the DNS record matching `set_identifier: pull-${db_identifier}`  for `pull.q1w2.quay.rhcloud.com` to set the weight of the cluster associated with the RDS instance being upgraded to `0` so that traffic will not be directed to that ONE cluster ([example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/38526)) 
5. Merge the MR above and confirm that `pull.q1w2.quay.rhcloud.com` is no longer sending traffic to the cluster to be upgraded (note DNS is round-robin, so you will need to make several attempts). You can use following snippet to monitor dns routing.
   ```
   # Run the command below for a minute to ensure DNS doesn't resolve to the disabled cluster
   while true; do dig +short pull.q1w2.quay.rhcloud.com @8.8.8.8; sleep 1; done | grep ocmro
   ```
6. Create a MR to upgrade a SINGLE database (the one associated with the cluster above) to the desired version ensuring that you set `apply_immediately: true` so it doesn't wait for the next maintenance window ([example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/38345))
7. Once the database upgrade is complete, verify that the OCM-Quay cluster is working as expected:
   1. login to the URL specific to the OCM-Quay cluster to verify that Quay is up (ex. ocmro<REPLICA_NUMBER>.q1w2.quay.rhcloud.com)
   2. pull an image from the cluster
8. Once the cluster has been verified, revert the MR in step #2 so that traffic will be restored to the cluster.
9. Confirm that `pull.q1w2.quay.rhcloud.com` is again resolving to the cluster that you upgraded (note DNS is round-robin, so you will need to make several attempts)
10. Repeat the steps above for the remaining RDS replicas ensuring appropriate time in between instance upgrades (at least ~24 hours in between the first and second replica isn't a bad idea)

### Upgrading primary

Upgrading the primary is simpler because there isn't any modification of DNS records.

1. See the [Notifications](#notifications) section above and make sure that you've notified the correct teams
2. Verify that there aren't any ongoing issues with quay.io (this is a fallback system for OSD use cases if quay.io is down). Don't proceed if there is any hint of issues with quay.io.
3. Create a MR to upgrade the database to the desired version ensuring that you set `apply_immediately: true` so it doesn't wait for the next maintenance window ([example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/38345))
4. Once the database upgrade is complete, verify that the OCM-Quay cluster is working as expected:
   1. login to the URL specific to the OCM-Quay cluster to verify that Quay is up (pull.q1w2.quay.rhcloud.com)
   2. confirm that the [mirroring of images from quay.io](/docs/app-sre/ocm-quay-mirroring.md) is working as expected (check logs for qontract-reconcile integration)
