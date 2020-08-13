# KubeDaemonSetNotScheduled

## Severity: High

## Impact

Possible service degradation depending on the characteristics of the application and the volume of traffic

## Summary

A number of pods within a DaemonSet are not being scheduled.

## Access required

Cluster and namespace access. For instructions on how to find out the cluster, see the [quickstart SOP][].

## Steps

Look at the namespace Events. In normal circumstances Kubernetes will log one or more warnings that willl indicate why some pods cannot be scheduled

Check the `status` field on the DaemonSet object to tell how many pods are not scheduled.

Check the status of the pods related to the DaemonSet. The pods typically have a name that starts with the same name as the DaemonSet itself.

For troubleshooting the pods, refer to the [KubePodCrashLooping.md](KubePodCrashLooping.md) SOP

## Escalations

If the problem if found to be related to the application or the application configuration, escalate to the development team.

If the problem if found to be related to the cluster, escalate to SREP
