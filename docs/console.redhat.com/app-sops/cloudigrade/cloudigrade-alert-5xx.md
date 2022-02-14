# cloudigrade alert 5xx

Severity: High

## Incident Response Plan

[Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact

cloudigrade inspects images in public clouds to identify RHEL presense and tracks customer use to report on RHEL usage. If cloudigrade is broken, customers will not have accurate data reported via Subscription Watch. If cloudigrade's responses have 5xx status, other services like Sources and Subscription Watch that depend on cloudigrade's API may be fail in unexpected ways.

## Summary

This alert fires when cloudigrade's HTTP API responds with error status code (5xx) too frequently. That means some fatal error appeared in at least one of the `cloudigrade-api` pods.

At the time of this writing, there are no known causes for 5xx error responses, which should never happen under normal circumstances. It may indicate underlying infrastructure problems (Clowder, OpenShift, etc.). The steps below are just instructions for generic troubleshooting and investigation. If or when the dev team finds a recurring pattern of HTTP 5xx errors that cannot promptly be fixed in the backend, we will update the steps below with more details.

## Access required

Console access to the cluster+namespace pods are running in.

## Steps

1. Log into the console / namespace and verify `cloudigrade-api` pods are running and receiving requests.
2. Inspect `cloudigrade-api` pods logs and search for error logs.
3. Check if any deployments or changes in the application happened closer to the time the error started.
4. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
