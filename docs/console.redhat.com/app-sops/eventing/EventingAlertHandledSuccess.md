# Eventing Alert Handled Success
Severity: Pagerduty

## Incidence Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
The Insights Eventing service enables IT administrators to receive updates from various Insights services such as Advisor, Compliance, Drift, and Vulnerability, as events that will land in their Splunk server dashboards.  If Eventing is broken, these events cannot flow through and users will not recieve their events.

## Summary
When our Handled Success Alert fires, there is a success rate that is too low due to events not being successfully sent to Splunk, perhaps a pod needs restarting etc, so the below steps will need to be taken.

## Access required
Console access to the cluster+namespace pods are running in.

## Steps
1. Check [Eventing grafana board](https://grafana.app-sre.devshift.net/d/eventing/eventing?orgId=1) "Success rate" chart. So far, our success rate has generally been pretty high, like 98%, aside from a few times, but we are starting with an initial 90% goal in line with other services.
2. Log into the [console / namespace](https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/eventing-prod/deployments) and verify if all `eventing-splunk-quarkus` pods are running and processing incoming messages.
3. Inspect given components pods logs and search for error logs.
4. Check if any deployments or changes in the application happened closer to the time the error started.
5. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/eventing/app.yml

## Credit
Thanks to Marley Stipich for doing the initial work for the steps in this SOP.
