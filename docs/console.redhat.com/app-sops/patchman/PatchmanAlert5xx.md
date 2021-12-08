# Patchman alert 5xx
Severity: Pagerduty

## Incident Response Plan
 [Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact
Patch allows users to display and manage available patches for their registered systems and generate remediations playbooks. If Patch is broken, customers aren't being able to use these functions.

## Summary
This alert fires when Patch api returns error status code (5**). That means some fatal error appeared in API container (patchman-manager).

## Access required
Console access to the cluster+namespace pods are running in.

## Steps
1. Log into the console / namespace and verify if all patchman-manager pods are running and receiving requests.
2. Inspect patchman-manager pods logs and search for error logs.
3. Check if any deployments or changes in the application happened closer to the time the error started. 
4. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/patchman/app.yml
