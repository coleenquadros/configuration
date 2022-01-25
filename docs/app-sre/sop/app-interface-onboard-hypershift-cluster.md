<!-- TOC -->

- [Provisioning the cluster](#provisioning-the-cluster)
- [Hypershift deployment](#hypershift-deployment)

<!-- /TOC -->

This SOP serves as a step-by-step process on how to provision Hypershift from zero (no cluster) to a fully functioning Hypershift management cluster


# Provisioning the cluster

1. Follow the standard [Cluster Onboarding SOP](app-interface-onboard-cluster.md) using the following specs
   *Note*: some of these numbers need to be reviewed in the light of first hypershift usage (storage, load balancers, compute type .. )

    |                            | Staging       | Production    |
    |----------------------------|---------------|---------------|
    | Availability               | Multizone     | Multizone     |
    | Compute type               | m5.xlarge     | m5.xlarge     |
    | Compute count (autoscale)  | 9 - 12        | 9 - 27        |
    | Persistent storage         | 1600 GB       | 1600 GB       |
    | Load balancers             | 12            | 12            |
    | UpgradePolicy wokloads     | hypershift    | hypershift    |
    | **Network type**           | OVNKubernetes | OVNKubernetes |
    | Machine CIRD               | See note      | See note      |
    | Private                    | false         | false         |
    | Internal                   | false         | false         |
    | VPC peering                | none          | none          |

1. For stage `cluster.yml`, add `dedicated-readers` under `managedGroups` and update `data/teams/hypershift/roles/hypershift-dedicated-readers.yml` with a reference to our new cluster:
    ```yaml
    access:
    ...
    - cluster:
        $ref: /openshift/<cluster_name>/cluster.yml
    group: dedicated-readers
     ```


# Hypershift deployment
