# ROSLatency
Severity: Pagerduty

## Incident Response Plan
[Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
- If the latency is high for comparison requests, we might have an impact on our latency SLO and the customer experience might be degraded.

## Summary
Note:  This service is deployed via [Clowder](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst).

This alert fires when at least 10% of requests in the last 5 min are slower than 2000ms, which can impact our latency SLO in the long term.

## Access required
-  Console access to the cluster + namespace (crcp01ue1 + ros-prod) pods are running in.

## Steps
-  Log into the console / namespace and verify if all pods are running and receiving requests
    - Check each pod here: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/ros-prod/pods
    - Click the pod and go to "Logs" in the tabs
    - Each pod should have a liveness probe running every 10 seconds: `GET /api/ros/v1/status HTTP/1.1" 200`
-  Check logs / events for ROS API pods
    - In each pod's logs use browser's "find" feature to search for any "Error" or "Timeout" logs
-  Check if any deployments or changes in the application happened closer to the time the requests started to become slow
    - In the list of pods for ros-prod, check the "Created" column to see if a recent update was made to the pod that may be causing the issue
-  Check metrics in Grafana (Latency distribution and SLO for Latency) https://grafana.app-sre.devshift.net/d/slo-dashboard/slo-dashboard?orgId=1&var-datasource=crcp01ue1-prometheus&var-label=ros and take notes.
    - Take note of whether the latency distribution seems to be ongoing or was simply a blip.
    - Are requests taking 2 - 4 seconds, or do they seem to be lasting for much longer.
-  Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/ros/app.yml

