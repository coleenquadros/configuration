# Prometheus TSDB WAL corruptions

## Severity: High

## Impact

- Unknown

## Summary

Prometheus TSDB write ahead log is corrupted. Needs more investigation with upstream

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Stop Prometheus, delete WAL, continue
- Take a volume snapshot and report upstream

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
