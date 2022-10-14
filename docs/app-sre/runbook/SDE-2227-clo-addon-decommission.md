# CLO Addon decommission

[SDE-2227](https://issues.redhat.com/browse/SDE-2227)

[TOC]

## Context

[ADR 58](https://docs.google.com/document/d/1RJ66T0eqcaEZzuG3gKYKzedVxw62iXWq-fsJcWECGV4/edit) 
aims at deprecation the logging Addon we currently use on app-sre clusters, and which allows
to get application logs within the cloudwatch instance of the cluster account. We also aim at
supporting other log storage, such as Loki ([SDE-2017](https://issues.redhat.com/browse/SDE-2017)),
which is not supported within the Addon.

So we will replace the CLO (Cluster Logging Operator) addon by the official openshift logging-operator.

This operator will be configured to:
- still use fluentd for log gathering
- send logs to cloudwatch *in the `app-sre-logs` account*, which will remove the need to switch AWS roles
- Arrange logs into log groups according to cluster and namespace
- Optionally send logs to Loki

This document describes how to remove the addon from a cluster and how to install the logging-operator.
This process is unfortunately a bit manual due to bugs in the CLO addon

## Procedure

### Preparation

This is done as a preparatory step (part of the MR for this doc):
* Remove the CLO addon from the cluster. [Example](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/45410/diffs).
  * This does not remove the addon from OCM
* Add the `openshift-logging` namespace for the cluster in app-interface, with a AWS IAM secret granting access to `app-sre-logs` cloudwatch.
* Prepare the `openshift-logging` namespaces with commented out `sharedResources` to setup cluster-logging
  * There is no need to deploy `clo-token-refresher` nor its secret if we're not sending logs to Loki  
* Email to advertise the change:
  * [app-interface email](../../../data/app-interface/emails/clo-addon-decommission-anouncement.yaml)

### Remove the CLO addon

The script `hack/clo-decommission.sh` can be used to automate that. To use it, you need to
* have `oc`, `ocm` and `jq` in your PATH
* export a `CLUSTER` environment variable with the cluster name
* be logged in to ocm CLI (download from https://console.redhat.com/openshift/downloads): Get a token from https://console.redhat.com/openshift/token and follow instructions
* be logged in to your cluster (`oc login <URL>`)

Then just invoke the script:
```sh
./hack/clo-decommission.sh
```

Note: the script can take a long time (up to 23~30min) due to the wait on hive synchronization.

Alternatively, here are the manual steps:
* Since the integration does not uninstall the addon itself, uninstall it manually from the console
  * Select the cluster from https://console.redhat.com/openshift
  * In the `Add-ons` tab, select `Cluster Logging Operator` and hit `Uninstall`
* This addon has a bug, it does not remove itself properly: it forgets the CSV. So login onto the cluster and remove the CSV:
  * `oc delete -n openshift-logging clusterserviceversion -l operators.coreos.com/cluster-logging.openshift-logging`
  * You may have to run that several times if the timing is unfortunate with the hive sync.
* Due to hive reconciliation period, you may have to wait up to 20min to see the addon finally marked as uninstalled in the console 
* If there are any remaining dangling resources, let's clean them up:
```
oc delete -n openshift-logging clusterlogging,clusterlogforwarder --all || echo "... This is expected"
oc delete -n openshift-logging clusterserviceversion -l operators.coreos.com/cluster-logging.openshift-logging
oc delete -n openshift-logging --ignore-not-found catalogsource addon-cluster-logging-operator-catalog
oc delete -n openshift-logging --all subscriptions.operators.coreos.com,operatorgroup,installplan,catalogsource
# not removing CRDs. This will get upgraded by the operator deployment. Would need cluster-admin rights.
# oc delete --ignore-not-found crd clusterloggings.logging.openshift.io
# oc delete --ignore-not-found crd clusterlogforwarders.logging.openshift.io 
oc delete --ignore-not-found -n openshift-logging secret addon-cluster-logging-operator-parameters
```

### Install the openshift-logging operator

Single MR uncommenting the `managedResourceTypes` and `sharedResources` from the `openshift-logging`  namespace file. This will deploy and configure the openshift-logging operator.

*Note*: this can be done in one step as we did not delete CRDs in the previous step. If we did, we'd have to first deploy the operator, which installs the CRDs, and then configure logging in a second MR.

### Cleanup
After a while, letting users access old logs for some time (few weeks/months)

* Update the [cluster onboarding/provisioning doc](../sop/app-interface-onboard-cluster.md) and hack tools.
* Update the FAQ `Get access to cluster logs via Log Forwarding` section to not reference switching roles anymore
  * Same for Clair SOP: `docs/clair/sops/logs.md`
* Remove the `user_policy` from `data/aws/app-sre-logs/roles/log-consumer.yml`: `/aws/app-sre-logs/policies/ClusterAccess.yml`
* Remove the `read-only` access from `app-sre-logs` in the `awsInfrastructureAccess` of each cluster:
```yaml
- awsGroup:
    $ref: /aws/app-sre-logs/groups/Log-consumers.yml
  accessLevel: read-only
```
* Remove all `*-cloudwatch-access` entries of `aws-iam-service-account` from `data/services/observability/namespaces/app-sre-observability-production.yml`
* Remove the `{{{ cluster.name }}}-cloudwatch` datasources from Grafana: `resources/observability/grafana/grafana-datasources.secret.yaml`
* Cleanup each cluster account cloudwatch content
