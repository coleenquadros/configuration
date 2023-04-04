# TalliesWillMissWindow
Severity: Medium

## Impact
-  Tally task consumption rate appears to be insufficient to keep up with scheduled tasks. Tally is projected to leave more than too many tasks unprocessed in a one-hour window. Based on this projection, we are likely to fail to bill a customer due to missing the AWS billing window.
## Summary
This alert fires when the tally processing rate is insufficient to handle hourly scheduled tasks.
## Access required
-  Console access to the cluster + namespace (crcp01ue1 + rhsm-prod) pods are running in.

## Steps
-  Log into the console / namespace
    - Check each pod here: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/rhsm-prod/pods
    - Evaluate if the service is processing message, but not fast enough scale the number of replicas for swatch-tally service
-  Check if there are any available logs / events for rhsm-prod pods.
    - If any pods have available logs, use browser's "find" feature to search for Java stacktraces
-  Check if any deployments or changes in the application happened closer to the time the error started.
    - In the list of pods for rhsm-prod, check the "Created" column to see if a recent update were made
-  Escalate the alert with all the information available to the engineering team that is responsible for the app.
## Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml
