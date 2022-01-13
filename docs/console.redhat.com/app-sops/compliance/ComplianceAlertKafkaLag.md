# Compliance Alert Kafka Lag
Severity: Pagerduty

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
The Insights Compliance service enables IT security and compliance administrators to assess, monitor, and report on the security-policy compliance of RHEL systems. The compliance service provides a simple but powerful user interface, enabling the creation, configuration, and management of SCAP security policies. If Compliance is broken, customers aren't being able to use these functions.

## Summary
This alert fires when Compliance consumer components aren't able to process incoming messages and so Kafka lag increases too much.

## Access required
Console access to the cluster+namespace pods are running in.

## Steps
1. Check [Compliance grafana board](https://grafana.app-sre.devshift.net/d/compliance/compliance?orgId=1) "Kafka consumer lag" chart. It should generally stay under 1024 on the chart but sometimes there will be spikes that go above this for a short period of time. Watch for any spikes that do not come back down over a long period of time or any spikes above 100000ms. 
 - Topic `platform.inventory.events` lag means `compliance-inventory` components issues.
2. Log into the [console / namespace](https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/compliance-prod/deployments) and verify if all `compliance-inventory` pods are running and processing incoming messages.
3. Inspect given components pods logs and search for error logs.
4. Check if any deployments or changes in the application happened closer to the time the error started. 
5. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/compliance/app.yml
