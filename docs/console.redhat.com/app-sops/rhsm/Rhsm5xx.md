# Rhsm5xx
Severity: Medium

## Impact
Customer facing API doesn't work properly so there's a visible outage in the service.

## Summary
This alert fires when the RHSM API returns error status code (5**) more than 10% of the time.

## Access required
Console access to the cluster+namespace (crcp01ue1 + rhsm-prod) pods are running in.

## Steps
-  Log into the console / namespace and verify if all pods are running and receiving requests
    - Check each pod here: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/rhsm-prod/pods
    - Click the pod and go to "Logs" in the tabs
    - Each pod should have a liveness probe running every 10 seconds: `GET /health/liveness`
-  Check logs / events for RHSM API pods
    - In each pod's logs use browser's "find" feature to search for any "Error", "Timeout", or "Exception" logs
-  Check if any deployments or changes in the application happened closer to the time the requests started to become slow
    - In the list of pods for rhsm-prod, check the "Created" column to see if a recent update was made to the pod that may be causing the issue
-  Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml
