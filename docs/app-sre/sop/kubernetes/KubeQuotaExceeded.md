# KubeQuotaExceeded

## Severity: High

## Impact

Storage quota exceeded: pods requesting a PV will not be able to schedule

CPU/Memory quota exceeded: new Pods will be unschedulable

## Summary

Used quota in a namespace is bigger than the allowed quota. Quotas are defined in `ResourceQuota` resources.

More information: https://kubernetes.io/docs/concepts/policy/resource-quotas/

## Access required

Cluster and namespace access. For instructions on how to find out the cluster, see the [quickstart SOP][]

## Steps

1. If the alert is for an openshift namespace, escalate to the SRE Platform team.
1. If the alert is for an App SRE managed namespace, check the defined resource quotas for that namespace ([docs][]) and let the responsible development team know.
1. If the additional quota is required - the defined resource quotas should be updated by the development team.
1. If the additional quota is not required - the quota requests defined by the services should be updated by the development team.

## Escalations

* SRE Platform team: contact @sre-platform-primary on #sd-sre-platform on Slack

[quickstart SOP]: https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/sop/accessing-clusters.md
[docs]: https://gitlab.cee.redhat.com/service/app-interface#manage-openshift-resourcequotas-via-app-interface-openshiftquota-1yml
