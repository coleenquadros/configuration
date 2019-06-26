# Prometheus TSDB compactions failing

## Severity: High

## Impact

- Prometheus PV/Disk will fill up rapidly
- Risk running out of storage and taking system down

## Summary

Prometheus failing to compact the metrics in TSDB. This alert need more investigation with upstream 

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

Currently unknown, checking with upstream

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
