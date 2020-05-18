# Prometheus Target scrapes duplicate

## Severity: Medium

## Impact

- Duplicate timeseries in Prometheus

## Summary

Prometheus has a duplicate job entry 

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Find duplicate entries in prometheus targets/jobs
- Remove duplicate entry

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
