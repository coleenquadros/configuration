# Prometheus TSDB WAL corruptions

## Severity: High

## Impact

- Unknown

## Summary

Prometheus TSDB write ahead log is corrupted. Needs more investigation with upstream

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Take a volume snapshot for the Prometheus PV for reporting upstream
- Delete the WAL `rm -rf wal/` 
- Restart Prometheus by killing the pod or restarting the systemd service as relevant

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
