# Prometheus Disk Almost Full

## Severity: High

## Impact

- When the disk becomes full, Prometheus server will not be able to start at all

## Summary

This SOP is intended for use for an AppSRE Prometheus instance (running in the `openshift-customer-monitoring` namespace).

The local disk/volume that Prometheus writes data to is becoming full. Prometheus will fail to start and pods will may be in CrashloopBackoff.

To prevent that from happening, we will need to do any of:
1. Increase Prometheus storage
1. Investigate the reason the disk is becoming full.

If the disk is already full, consult [prometheus-DiskFull](/docs/app-sre/sop/prometheus/prometheus-DiskFull.md).

## Access required

- Console access to the cluster+namespace the prometheus pod is running in

## Steps

- In case the disk is filling up quickly and the Prometheus instance is a critical one (production cluster), start by increasing the storage volume of Prometheus by folloing this SOP: [Grow Prometheus storage](docs/app-sre/sop/grow-prometheus-storage.md)
- Investigate the reason the disk is becoming full by looking for metrics with high cardinality (also referred to as cardinality explosion)
  - There is a separate SOP that covers [troubleshooting high cardinality metrics](/docs/app-sre/sop/prometheus/troubleshooting-high-cardinality-metrics.md)

## Escalations

- Follow the service owners' escalation policy as described in the SOP's steps.
- Ping more team members in #sd-app-sre-teamchat
- If you have rbac/access restrictions, ping SREP for help.
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
