# Prometheus Notification queue running full

## Severity: High

## Impact

- Prometheus operator will fail to apply any new changes to the configuration

## Summary

Prometheus has too many alerts queued in its queue

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

Currently unknown, checking with upstream

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P

- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
