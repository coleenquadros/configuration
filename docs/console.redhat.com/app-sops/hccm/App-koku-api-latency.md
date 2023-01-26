# App-koku-api-latency

Severity: High

## Incident Response Plan

[Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
- Cost provides visibilty of cloud and OpenShift costs to customers. If requests are slow the expereince may be degraded or effect any downstream customer tooling that expects a quicker response. If the latency is high for requests, we might have an impact on our latency SLO and the customer experience might be degraded.

## Summary
This alert fires when at least 10% of requests in the last 5 min are slower than 2000ms, which can impact our latency SLO in the long term.

## Access required
-  Console access to the cluster + namespace (crcp01ue1 + hccm-prod) pods are running in.

## Steps
-  Log into the console / namespace and verify if all pods are running and receiving requests
    - Check each pod here: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/hccm-prod/pods
    - Click the pod and go to "Logs" in the tabs
    - Each pod should have a liveness probe running every 10 seconds: `GET /health/liveness`
-  Check logs / events for Koku API pods
    - In each pod's logs use browser's "find" feature to search for any "Error", "Timeout", or "Exception" logs
-  Check if any deployments or changes in the application happened closer to the time the requests started to become slow
    - In the list of pods for hccmp-prod, check the "Created" column to see if a recent update was made to the pod that may be causing the issue
-  Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/hccm/app.yml
