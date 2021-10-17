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

If the disk is already full, consult (prometheus-DiskAlmostFull)[docs/app-sre/sop/prometheus/prometheus-DiskAlmostFull.md].

## Access required

- Console access to the cluster+namespace the prometheus pod is running in

## Steps

- In case the disk is filling up quickly and the Prometheus instance is a critical one (production cluster), start by increasing the storage volume of Prometheus by folloing this SOP: [Grow Prometheus storage](docs/app-sre/sop/grow-prometheus-storage.md)
- Investigate the reason the disk is becoming full by looking for metrics with [high cardinality](https://www.robustperception.io/cardinality-is-key) (also referred to as cardinality explosion):
    - Navigate to the Prometheus instance (https://prometheus.<cluster_name>.devshift.net)
    - Execute the following query: `topk(10, count by (__name__)({__name__=~".+"}))` (Normal values should be up to ~10k)
    - Execute each of the highest metrics and try to look for:
        - The label which may cause the high cardinality. Some common label examples: `account`, `tenant`.
        - Try to trace the metric back to a service in app-interface using the labels, follow the service's [escalation policy](README.md#define-an-escalation-policy-for-a-service) and reach out to the service owners to ask them to take action on reducing the metric's cardinality (preferable via a Jira ticket).

## Escalations

- Follow the service owners' escalation policy as described in the SOP's steps.
- Ping more team members in #sd-app-sre-teamchat
- If you have rbac/access restrictions, ping SREP for help.
- An additional resource is #forum-monitoring on slack where monitoring engineering team hangs out
