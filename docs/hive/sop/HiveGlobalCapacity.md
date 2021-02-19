# SOP : HiveGlobalCapacity Alert (WIP)

**This SOP is a work-in-progress**

## HiveGlobalCapacity

<!-- toc -->

- [SOP : HiveGlobalCapacity Alert (WIP)](#sop--hiveglobalcapacity-alert-wip)
  - [HiveGlobalCapacity](#hiveglobalcapacity)
    - [Impact](#impact)
    - [Summary](#summary)
    - [Access required](#access-required)
    - [Resolution](#resolution)

<!-- tocstop -->

---

### Impact
Customers will be unable to provision new clusters

### Summary
The global hive is determined from the following
1) Hive shards `hive-controllers` metrics are scraped by AppSRE prometheus
2) The capacity is based on how many `ClusterDeployment` objects exist as reported by `hive-controllers`
3) The maximum capacity of a single hive shard is configured in OCM and that value is also set in the alert definitions

The alert currently do not discern clouds, regions and such. All hive shards that are active and configured are considered in the capacity calculation

### Access required
Access to prod hive cluster (as necessary for verifications).

AWS Organization access (SREP) required for setting up new AWS accounts

App-Interface (APPSRE) for submitting the configs required to provision a new shard

### Resolution
#### Provision a new hive shard
Provisioning a new hive shard is a rather complex process has been greatly simplified in app-interface over time. Nonetheless it is best to take some time to validate with SREP and the Hive team first to ensure the high capacity utilization is legetimate (this step will eventually not be needed once we gain confidence and especially once we have additional capabilities such as the sharding service, cluster relocation, autoscaling and better automation around shard management)

1) Create a JIRA card on the OHSS board
   - Title: `Hive capacity is near full`
   - Priority: `Urgent`
   - Description:
     - Link to the alert
     - Link to this SOP
     - Indicate that AppSRE is adding a new Hive shard and that SREP help will be required to setup AWS accounts, IDP and such (this is explained in the [Hive shard provisioning SOP](/docs/app-sre/sop/hive-shard-provisioning.md))

2) Begin provisioning a new hive shard, followng the [Hive shard provisioning SOP](/docs/app-sre/sop/hive-shard-provisioning.md)

3) Before adding the new shard in OCM, the SREP and Hive teams should give the green light

<!-- no additional technical steps should be added here. the source of truth for hive shard provioning is the above SOP -->

#### Increasing the capacity limit in OCM
**To be used in case of emergency only**

If we are completely out of capacity or we are time constrained and can't wait for a new shard to be provisioned (about a day) we may want to increase the shard capacity limit in OCM

A shard should be able to manage up to `1000` ClusterDeployments even though we currently have the (soft) limit set to `500`.

Changing the limit in OCM is done in app-interface via the [saas file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm/cicd/saas/saas-uhc-clusters-service.yaml) by updating the `PROVISION_SHARD_CLUSTER_LIMIT` variable


