# Patchman Alert External Service
Severity: Pagerduty

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
Patch allows users to display and manage available patches for their registered systems and generate remediations playbooks. If Patch is broken, customers aren't being able to use these functions.

## Summary
This alert fires when Patch fails to call some dependency service (e.g. RBAC).

## Access required
Console access to the cluster+namespace pods are running in.

## Steps
1. Check Patch grafana board "External services" chart.
2. Log into the console / namespace.
3. Inspect `patchman-manager` component pods logs and search for error logs.
4. Check if any deployments or changes in the application happened closer to the time the error started. 
5. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/patchman/app.yml
