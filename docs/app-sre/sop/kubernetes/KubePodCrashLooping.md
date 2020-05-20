# KubePodCrashLooping

## Severity: high

## Impact

## Summary

## Access required

## Steps

Check `containerStatuses.lastState.reason` on the Pod. The common causes and solutions are

- OOMkilled : Check if CPU is being throttled, involve development team
- Liveness probe failures : Check for CPU saturation, involve the development team
- A bug in application code : Escalate this to the development team

- See: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/ for some more tips for debugging running pods

## Escalations

Involve the development team for the corresponding service to get more insights into liveness probe failure or high resource utilization
