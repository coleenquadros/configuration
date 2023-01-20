# Prometheus Disk Full

## Severity: Critical

## Impact

- Prometheus server will not be able to start at all

## Summary

The local disk/volume that Prometheus writes data to is full. Prometheus will fail to start and pods will may be in CrashloopBackoff

## Access required

- Console access to the cluster+namespace the prometheus pod is running in

## Steps

- Take a volume snapshot for the Prometheus PV if needed for a backup
- Since the Prometheus container may not start at all, you will lose terminal access. We need to get clever in that case. Switch to the namespace and start a debug pod. Make sure you replace `prometheus-app-sre-x` with the name of the Prometheus pod: `$ oc debug prometheus-app-sre-x`
- Validate that you're running out of disk space: `$ df -h`
- Go to the `/prometheus` directory and start deleting the oldest blocks. Each block is a directory. You can conveniently use the `ls -lhA` command to get directories sorted by date
- 2/3 days worth of block should give Prometheus enough disk to atleast start up
- Restart Prometheus in one of the stateful set members by killing the pod (or restarting the systemd service if needed).
- Tail the prometheus pod logs and wait for the WAL to have been applied and the pod running fine
- Delete the same amount of directories in the other pod and restart Prometheus.

## Follow-up actions
- Investigate what caused the disk to fill, particularly look at the [Troubleshooting High Cardinality Metrics](/docs/app-sre/sop/prometheus/troubleshooting-high-cardinality-metrics.md) documentation

## Escalations

- Ping more team members in #sd-app-sre-teamchat
- If you have rbac/access restrictions, ping SREP for help.
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
