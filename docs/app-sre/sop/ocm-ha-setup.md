- [Info](#info)
- [Process](#process)
  - [VPC Peerings](#vpc-peerings)
- [Additional information](#additional-information)
  - [Leader election in CS](#leader-election-in-cs)

# Info

**Aim of this doc:** This SOP serves as a step-by-step process on how to deploy OCM in HA mode

**Feeds into Goal:** Scale out OSD + Managed Services control plane to meet increasing business demand for capacity, reduce risk and scale.

> Note: This SOP is work in progress.

# Process

## VPC Peerings

1. VPC peerings are created during a [Hive shard provisioning](/docs/app-sre/sop/hive-shard-provisioning.md).

# Additional information

## Leader election in CS

There are two types of leader election in CS:
1. Kubernetes Controllers - the elected leader is responsible for interacting with a Hive shard. The election is managed in the `uhc-leadership` namespace in each of the Hive shards. This implies that there may be a different leader (pod) per Hive shard, but also that there will be a single leader across clusters.
2. Background jobs - the elected leader is responsible for controlling where background jobs are executed. The election is managed in the same namespace as the one where CS is running. This implies there can only be one leader in a namespace, but there will be a leader in each cluster where OCM is running. To prevent that from happenning, setting the `LEADERSHIP_ENABLED` parameter to "false" will exclude all pods from participating in the leader election process.

## Static Egress IPs

OCM uses a set static egress IPs assigned to a specific cluster in order to have communication with the RHIT UMB whitelisted. When moving clusters, or setting up a new cluster, you must take note of these new or refreshed IPs and communicate them to the RHIT UMB team.
