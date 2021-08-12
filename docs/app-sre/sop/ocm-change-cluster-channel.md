# Change cluster channel in OCM

This SOP explains how to change an App SRE cluster's channel in OCM.

## Notes

1. In the past we were able to change a cluster's channel for all clusters.
1. Following [SDA-3297](https://issues.redhat.com/browse/SDA-3297), this is now self-service via the OCM API.

## Process

1. Submit a MR to app-interface to change the cluster's channel (`stable`/`fast`/`candidate`/`nightly`)
    * Note: the success of the operation depends on:
        - The cluster is in a version that exists in the target channel
        - The cluster does not have existing upgrade policies
1. If the cluster has an `upgradePolicy`:
    1. Disable the `ocm-upgrade-scheduler` integration in [Unleash](https://app-interface.unleash.devshift.net)
    1. Log in to the [OCM console](https://console.redhat.com/openshift) and delete the automatic upgrade policy for the cluster
1. Get the MR reviewed and merged.
    * Note: the `ocm-clusters` integration is expected to attempt to update the cluster a few times until the changes are reflected in OCM (more info in [SDA-3297](https://issues.redhat.com/browse/SDA-3297)).
1. Once the changes are reflected (indicated by the `ocm-clusters` integration going silent), enable the `ocm-upgrade-scheduler` integration in [Unleash](https://app-interface.unleash.devshift.net).
