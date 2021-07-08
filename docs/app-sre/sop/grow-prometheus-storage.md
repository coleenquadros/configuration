# Grow Prometheus storage

This is an SOP intended for use by an AppSRE team member to increase storage in a Prometheus operator instance running in the openshift-customer-monitoring namespace.

## Process

1. Submit a MR to app-interface to grow the storage size for the cluster you are interested in. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/21744
1. Wait for the MR to be merged and applied. Make sure the new size appears on the Prometheus resources:
    ```sh
    $ oc get prometheus app-sre -o json | jq -r .spec.storage.volumeClaimTemplate.spec.resources.requests.storage
    ```
1. Manually edit the PVCs to the new storage value (change `.spec.resources.requests.storage`):
    ```sh
    $ oc edit pvc prometheus-app-sre-db-prometheus-app-sre-0
    $ oc edit pvc prometheus-app-sre-db-prometheus-app-sre-1
    ```
    > Note: this is needed due to https://github.com/prometheus-operator/prometheus-operator/issues/4079
1. Delete the StatefulSet, which will cause pods to restart and for PVCs to be grown to new size:
    ```sh
    $ oc delete sts prometheus-app-sre
    ```
