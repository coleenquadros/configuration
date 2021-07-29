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
1. While there are still OSD v3 shards, a VPC peering should be added manually:
    - Log in to the cluster's AWS account using the AWS Infrastructure Access feature (use the network-mgmt role).
    - Add a new VPC peering connection to the v3 Hive shard in the matching environment (stage/production).
      Hive shard details:
        * hive-stage:
            * Account ID: 520502526389
            * VPC ID: vpc-0c2fa7c422c7f97a5
            * Region: us-east-1
            * VPC CIDR block: 10.140.0.0/16
        * hive-production:
            * Account ID: 945023158838
            * VPC ID: vpc-02f4f6e22c9bfb407
            * Region: us-east-1
            * VPC CIDR block: 10.121.0.0/16
    - Create an OHSS ticket for SREP to accept the peering connection request in the v3 Hive cluster's AWS account and add the requester's CIDR block to the accepter's route table. Example: [OHSS-4942](https://issues.redhat.com/browse/OHSS-4942)
    - Once the peering connection is accepted, add the v3 Hive cluster's CIDR block to the public Route table in the OCM cluster's AWS account.

# Additional information

## Leader election in CS

There are two types of leader election in CS:
1. Kubernetes Controllers - the elected leader is responsible for interacting with a Hive shard. The election is managed in the `uhc-leadership` namespace in each of the Hive shards. This implies that there may be a different leader (pod) per Hive shard, but also that there will be a single leader across clusters.
2. Background jobs - the elected leader is responsible for controlling where background jobs are executed. The election is managed in the same namespace as the one where CS is running. This implies there can only be one leader in a namespace, but there will be a leader in each cluster where OCM is running. To prevent that from happenning, setting the `LEADERSHIP_ENABLED` parameter to "false" will exclude all pods from participating in the leader election process.

## Static Egress IPs

OCM uses a set static egress IPs assigned to a specific cluster in order to have communication with the RHIT UMB whitelisted. When moving clusters, or setting up a new cluster, you must take note of these new or refreshed IPs and communicate them to the RHIT UMB team.
