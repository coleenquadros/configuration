# Patchman Alert Out Of Date Systems
Severity: Pagerduty

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
Patch allows users to display and manage available patches for their registered systems and generate remediations playbooks. If Patch is broken, customers aren't being able to use these functions.

## Summary
This alert fires when Patch detects unexpectedly low `up-to-date / out-of-date` systems ratio.

## Access required
Console access to the cluster+namespace pods are running in.

## Steps
1. Check Patch grafana board "Database items - systems" chart to see up-to-date and out-of-date systems portions. Check "System evaluations" chart to see whether systems are being evaluated.
2. Log into the console / namespace and verify if all `patchman-listener` and `patchman-evaluator-upload` pods are running and processing incoming messages.
3. Inspect given components pods logs and search for error logs.
4. Check if any deployments or changes in the application happened closer to the time the error started. 
5. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/patchman/app.yml
