# Migrate cluster from EFK to CloudWatch log forwarding

## Background

As part of [SDE-552](https://issues.redhat.com/browse/SDE-552) we are migrating all AppSRE managed clusters from EFK to CloudWatch log forwarding.

## Purpose

Describe the way of migrating a cluster from using EFK to CloudWatch log fowarding.

## Content

1. Create a merge request to app-interface to:
    - remove the `openshift-logging` namespace file that belongs to the cluster
    - add the `cluster-logging-operator` addon to the cluster file
    - remove the `kibanaUrl` of the cluster
1. Disable the `ocm-addons` integration and let the merge request get merged.
1. Once the merge request is merged and the changes are reflected (tl;dr wait ~15 minutes), login to the cluster and clean up the `openshift-logging` namespace:
    ```sh
    $ oc -n openshift-logging delete clusterlogging instance
    $ oc -n openshift-logging delete subscription cluster-logging
    $ oc -n openshift-logging delete subscription elasticsearch-operator
    $ oc -n openshift-logging get csv --no-headers | awk '{print$1}' | grep -e clusterlogging -e elasticsearch-operator | xargs oc -n openshift-logging delete
    $ oc -n openshift-logging delete pvc --all
    ```
1. Enable the `ocm-addons` integration. The installation should be reflected in the OCM console.
