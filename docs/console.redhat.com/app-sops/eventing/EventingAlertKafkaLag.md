# Eventing Alert Kafka Lag
Severity: Pagerduty

## Incidence Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
The Insights Eventing service enables IT administrators to receive updates from various Insights services such as Advisor, Compliance, Drift, and Vulnerability, as events that will land in their Splunk server dashboards.  If Eventing is broken, these events cannot flow through and will stack up in the Kafka queue.

## Summary
When our Kafka Lag Alert fires, there is a Kafka lag that is too large due to events not being removed from the queue, i.e. the time in milliseconds to clear the queue is too high, perhaps a pod needs restarting etc, so the below steps will need to be taken.

## Access required
Console access to the cluster+namespace pods are running in.

## Steps
1. Check [Eventing grafana board](https://grafana.app-sre.devshift.net/d/eventing/eventing?orgId=1) "Kafka consumer lag" chart. So far, there has generally been no lag as very few events are being handled.  As our volume of users and thus events increases, we should be able to gather additional data, but for now, we are using similar lag guidance to other Insights apps such as Compliance to determine what lag is appropriate or not. It should generally stay under 1024 on the chart but sometimes there will be spikes that go above this for a short period of time.  Watch for any spikes that do not come back down over a long period of time or any spikes above 100000ms.
 - Topic `platform.notifications.tocamel` lag means `eventing-splunk-quarkus` components issues.
2. Log into the [console / namespace](https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/eventing-prod/deployments) and verify if all `eventing-splunk-quarkus` pods are running and processing incoming messages.
3. Inspect given components pods logs and search for error logs.
4. Check if any deployments or changes in the application happened closer to the time the error started.
5. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/eventing/app.yml

## Credit
Thanks to Marley Stipich for doing the initial work for the steps in this SOP.
