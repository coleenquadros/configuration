# cloudigrade alert no listener

Severity: High

## Incident Response Plan

[Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact

cloudigrade inspects images in public clouds to identify RHEL presense and tracks customer use to report on RHEL usage. If cloudigrade is broken, customers will not have accurate data reported via Subscription Watch. If `cloudigrade-listener` specifically is not running, cloudigrade will stop processing new events from `sources-api`, and therefore cloudigrade's customer source metadata will be stale, resulting in new customers not being onboarded and existing customers not getting updated sources.

## Summary

This alert fires when there has been no `cloudigrade-listener` pod with a ready status for an extended period of time.

At the time of this writing, there are no known causes for `cloudigrade-listener` to be absent, and this should never happen under normal circumstances. It may indicate underlying infrastructure problems (Clowder, OpenShift, etc.).

## Access required

Console access to the cluster+namespace pods are running in.

## Steps

1. Log into the console / namespace and verify if any `cloudigrade-listener` pod is running.
2. Inspect given cloudigrade pods logs and search for error logs.
3. Check if any deployments or changes in the application happened closer to the time the error started.
4. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
