# YuptooPodDown
Severity: High

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
-  If there are no pods up in the production environment, customers aren't being able upload host-inventory reports from satellite.

## Summary
Note:  This service is deployed via [Clowder](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst).

This alert fires when the Yuptoo pod(s) drop and/or Prometheus cannot scrape metrics.

## Access required
-  Console access to the cluster + namespace (crcp01ue1 + yuptoo-prod) pods are running in.

## Steps
-  Log into the console / namespace and verify no pods are created or running.
    - Check each pod here: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/yuptoo-prod/pods
    - If no pods are found, then it's likely this table will be empty. Or, the status for existing pods will not be "Running".
-  Check if there are any available logs / events for yuptoo-prod pods.
    - If any pods have available logs, use browser's "find" feature to search for "Terminate" to see if you can find any logs noting when and why the pod was terminated.
-  Check if any deployments or changes in the application happened closer to the time the error started.
    - In the list of pods for yuptoo-prod, check the "Created" column to see if a recent update was made to the pod that may be causing the issue
-  Check infrastructure metrics and yaml file on the OpenShift console for yuptoo-service (Deployments -> yuptoo-service -> Metrics/YAML) https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/yuptoo-prod/deployments/yuptoo-service/metrics take notes.
    - Look for possible incorrect configurations or memory or cpu usage resource quotas that are being maxed out and causing the pod to restart or crash.
-  Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/yuptoo/app.yml

