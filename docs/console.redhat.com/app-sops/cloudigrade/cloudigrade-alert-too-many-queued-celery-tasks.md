# cloudigrade alert too many queued Celery tasks

Severity: High

## Incident Response Plan

[Incident Response Doc](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE) for console.redhat.com

## Impact

cloudigrade inspects images in public clouds to identify RHEL presense and tracks customer use to report on RHEL usage. If cloudigrade is broken, customers will not have accurate data reported via Subscription Watch. If there are many queued Celery tasks, that indicates cloudigrade's workers are not keeping up with demand, and cloudigrade may be late or fail to successfully process changes to user sources (from sources-api), capture and record customer activity data, and calculate aggregate reporting data. These could result in data lost and an unsatisfactory customer experience.

## Summary

This alert fires when there has been more than 2000 cumulative queued Celery tasks for an extended period of time.

At the time of this writing, there are no known normal conditions that would results in this many queued Celery tasks. The presence of many queued tasks may indicate the `cloudigrade-worker` pods are not functioning correctly or do not have enough resources to keep up with demand.

## Access required

Console access to the cluster+namespace pods are running in.

## Steps

1. Log into the console and namespace and verify that `cloudigrade-worker` pods are running.
2. Verify a reasonable number of `cloudigrade-worker` pods are running within the deployment's latest ReplicaSet/HPA specification.
3. Check the `cloudigrade-worker` deployment's metrics for anomalous CPU or memory use
4. Verify that `cloudigrade-worker` pods are not frequently crashing and restarting.
5. Inspect active `cloudigrade-worker` pods logs and search for recent error messages.
6. Check if any deployments or changes in the application happened closer to the time the error started.
7. Escalate the alert with all the information available to the engineering team that is responsible for the app.

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/cloudigrade/app.yml
