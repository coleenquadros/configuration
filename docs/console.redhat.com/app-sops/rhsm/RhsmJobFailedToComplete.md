# RHSM Job Failed To Complete
Severity: Warning

## Impact
- If an RHSM job is failing, services will be degraded and customers will be
  unable to see up-to-date information.  

## Summary
This alert fires when jobs failures occur in the last hour.

## Access required
-  Console access to the cluster + namespace (crcp01ue1 + rhsm-prod) pods are running in.

## Steps
-  Log into the console / namespace
    - Check each pod here: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/rhsm-prod/pods
-  Check if there are any available logs / events for rhsm-prod pods that have
   owners of type Job
    - Check for resource limits being hit and if so redeploy with increased limits
    - If any failing pods have available logs, use browser's "find" feature to search for Java stacktraces
-  Check if any deployments or changes in the application happened close to the time the error started.
    - In the list of pods for rhsm-prod, check the "Created" column to see if a recent update were made
-  Escalate the alert with all the information available to the engineering team that is responsible for the app.

# Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml
