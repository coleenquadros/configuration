# Cluster logging

Cluster logging, also called openshift logging, is a set of components that are deployable on an OpenShift cluster in order to provide centralized logging for all pods in the cluster. It is used to capture the pods STDOUT/STDERR and push the log entries to a centralized location on the cluster for tenants to be able to view and search through them.

## Support

As of OpenShift 4.5, the logging stack is supported by the logging team, part of the Red Hat developer organization.

**Note:** The logging stack is transitioning to an addon and this will change how it is deployed and supported. The information below documents the logging stack prior to this change.

# Installation

The OSD instructions for installing Cluster Logging is provided here: https://docs.openshift.com/dedicated/4/logging/dedicated-cluster-deploying.html

The App-SRE team leverages app-interface and qontract-reconcile to install the resources from the above link onto clusters. As such, the instructions below differ slightly from the ones provided at the link above.

## App-Interface

The logging stack is installed in a namespace named `openshift-logging`

Access to resources within this namespace is limited for regular users, including dedicated-admins. Only cluster-admins have full access to this namespace.

Resources required to deploy openshift-logging are found in app-interface under a cluster `namespaces` folder, in a file named `openshift-logging.yaml`. An example of such a file can be found here: [/data/openshift/app-sre-prod-01/namespaces/openshift-logging.yaml](/data/openshift/app-sre-prod-01/namespaces/openshift-logging.yaml)

## Deployment structure

The namespace under which the logging components are deployed is `openshift-logging`

The following components are normally deployed as part of the standard install:

| Type | Name | Purpose |
|------|------|---------|
| Subscription | clusterlogging | Responsible for the bringup of the clusterlogging operator |
| Subscription | elasticsearch-opertor | Responsible for the bringup of the elasticsearch-operator operator, required by clusterlogging |
| Deployment | elasticsearch | Datastore for the logs |
| Deployment | kibana | Frontend for browsing elasticsearch |
| DaemonSet | fluentd | Watch for pod logs and forwards them to elasticsearch. There is one fluentd pod per node on a cluster |

# Operations

## Re-deploying the logging stack

Sometimes it may be necessary to completely remove the logging stack components and deploy them from scratch. Such a situation occur when it is required to downgrade the logging stack version.

**Note: The following instructions will erase all logging history**

1. **Optional** override version in app-interface if a specific version is desired (otherwise the one matching the cluster version is installed). This is normally done via the `openshift-logging.yaml` file located within a cluster/namespaces directory structure in app-interface. An example of such a file can be found here: [/data/openshift/app-sre-prod-01/namespaces/openshift-logging.yaml](/data/openshift/app-sre-prod-01/namespaces/openshift-logging.yaml)

1. Disable the `openshift-resources` integration in [Unleash](https://app-interface.unleash.devshift.net)

    While not strictly required, this is useful so that app-interface will not start reconciling the resources while we are in the process of deleting them.

1. Submit the changes to app-interface from the previous step, and wait for the MR to be merged and deployed. It is possible to watch the Subscription objects to tell if the desired version is deployed. (tip: do this in a separate shell so you can watch while running the rest of the commands)

        oc -n openshift-logging get subscription --watch

1. Find out the names of the CSV resources for `clusterlogging` and `elasticsearch-operator` CSVs

        oc -n openshift-logging get csv | grep -e clusterlogging -e elasticsearch-operator

1. Find out the names of the PVC resources for `elasticsearch`

        oc -n openshift-logging get pvc | grep ^elasticsearch

1. Delete all of the logging stack resources

        oc -n openshift-logging delete clusterlogging instance
        oc -n openshift-logging delete pvc elasticsearch-<xyz>-1
        oc -n openshift-logging delete pvc elasticsearch-<xyz>-2
        oc -n openshift-logging delete pvc elasticsearch-<xyz>-3
        oc -n openshift-logging delete subscription cluster-logging
        oc -n openshift-logging delete subscription elasticsearch-operator
        oc -n openshift-logging delete csv clusterlogging-<xyz>
        oc -n openshift-logging delete csv elasticsearch-operator-<xyz>

1. Re-enable the `openshift-resources` integration

1. Let app-interface reconcile everything.
