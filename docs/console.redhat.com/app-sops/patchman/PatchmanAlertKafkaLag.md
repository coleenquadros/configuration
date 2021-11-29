# Patchman Alert Kafka Lag
Severity: Pagerduty

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
Patch allows users to display and manage available patches for their registered systems and generate remediations playbooks. If Patch is broken, customers aren't being able to use these functions.

## Summary
This alert fires when Patch consumer components don't make it to process incomming messages and so Kafka lag increases too much.

## Access required
Console access to the cluster+namespace pods are running in.

## Steps
1. Check Patch grafana board "Kafka consumer lag" chart.
 - Topic `platform.inventory.events` lag means `patchman-listener` components issues.
 - Topic `patchman.evaluator.upload` lag means `patchman-evaluator-upload` components issues.
2. Log into the console / namespace and verify if all `patchman-listener` and `patchman-evaluator-upload` pods are running and processing incoming messages.
3. Inspect given components pods logs and search for error logs.
4. Check if any deployments or changes in the application happened closer to the time the error started. 
5. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/patchman/app.yml
