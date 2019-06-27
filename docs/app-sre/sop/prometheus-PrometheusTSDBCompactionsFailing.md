# Prometheus TSDB compactions failing

## Severity: High

## Impact

- Prometheus PV/Disk will fill up rapidly
- Risk running out of storage and taking system down

## Summary

This is most critical if it happens to the head block, as the write ahead log will continue to grow, and this is what eats disk space quickly

## Access required

- Console access to the cluster+namespace this operator pod is running in

## Steps

- Check Prometheus logs, troubleshoot forward from the error seen in logs
- Worst case: Deleting the WAL `rm -rf wal/` and restart Prometheus Pod or Systemd Service if the head chunk can't be compacted

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If its the prometheus operator in `openshift-monitoring`, escalate to SRE-P
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
