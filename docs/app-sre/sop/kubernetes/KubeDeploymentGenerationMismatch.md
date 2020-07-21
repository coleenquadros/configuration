# KubeDeploymentGenerationMismatch

## Severity: High

## Impact

Deployment is stuck and potentially requires manual intervention

## Summary

A deployment was attempted and was not successful. It is likely that the previous deployment is still up and running.

## Access required

Cluster and namespace access. For instructions on how to find out the cluster, see the [quickstart SOP][].

## Steps

1. If the alert is for an openshift namespace, escalate to the SRE Platform team.
1. If the alert is for an App SRE managed namespace, make the responsible development team aware.
1. Assist with remedy activities as requested by the development team.

## Escalations

* SRE Platform team: contact @sre-platform-primary on #sd-sre-platform on Slack

[quickstart SOP]: https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/sop/accessing-clusters.md
