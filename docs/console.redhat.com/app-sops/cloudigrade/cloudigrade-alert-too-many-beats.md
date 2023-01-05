# cloudigrade alert too many beats

Severity: High

## Incident Response Plan

[Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact

cloudigrade inspects images in public clouds to identify RHEL presense and tracks customer use to report on RHEL usage. If cloudigrade is broken, customers will not have accurate data reported via Subscription Watch. If `cloudigrade-beat` specifically has too many instances running, cloudigrade's scheduled periodic tasks will run more frequently than expected, and therefore cloudigrade's data may be calculated incorrectly.

## Summary

This alert fires when there has been more than 1 `cloudigrade-beat` pod with a ready status for an extended period of time.

At the time of this writing, there are no known causes for `cloudigrade-beat` to have more than 1 pod, and this should never happen under normal circumstances. It may indicate underlying infrastructure problems (Clowder, OpenShift, etc.).

## Access required

Console access to the cluster+namespace pods are running in.

## Steps

1. Log into the console / namespace and verify if any `cloudigrade-beat` pod is running.
2. Inspect given cloudigrade pods logs and search for error logs.
3. Check if any deployments or changes in the application happened closer to the time the error started.
4. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
