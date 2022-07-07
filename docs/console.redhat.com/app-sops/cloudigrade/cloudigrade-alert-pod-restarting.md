# cloudigrade alert pod restarting

Severity: High

## Incident Response Plan

[Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact

cloudigrade inspects images in public clouds to identify RHEL presense and tracks customer use to report on RHEL usage. If cloudigrade is broken, customers will not have accurate data reported via Subscription Watch. If pods are restarting frequently, some functionality may be misconfigured or broken, and therefore new customers may fail to be onboarded and any existing customer data presented via Subscription Watch may not be updated.

## Summary

This alert fires when frequent cloudigrade pod restarting is detected.

At the time of this writing, there are no known causes for pods to restart frequently, and this should never happen under normal circumstances. It may indicate underlying infrastructure problems (Clowder, OpenShift, etc.).

## Access required

Console access to the cluster+namespace pods are running in.

## Steps

1. Check in alert detail which cloudigrade component was restarted.
2. Log into the console / namespace and verify if all cloudigrade pods are running.
2. Verify that runtime service dependencies are operating normally. See [cloudigrade-general-troubleshooting](cloudigrade-general-troubleshooting.md) for details.
3. Inspect given cloudigrade pods logs and search for error logs.
4. Check if any deployments or changes in the application happened closer to the time the error started.
5. Connect to the terminal for a running pod, and attempt to manually run its liveness and readiness probe commands. Search a deployment's definition to find `livenessProbe` and `readinessProbe` or see [cloudigrade-health-checks](cloudigrade-health-checks.md) for details. Record the output, command exit code, and duration of time the command took to complete.
6. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
