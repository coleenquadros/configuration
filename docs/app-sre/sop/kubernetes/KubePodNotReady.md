# KubePodNotReady

## Severity: Critical

## Impact

Incoming traffic will not be routed to the non-ready pod

## Summary

## Access required

## Steps

`kubectl describe pod/podname` and find out what container is not in a ready state

See the SOP for [kubecontainerwaiting](https://gitlab.cee.redhat.com/service/app-interface/tree/master/docs/app-sre/sop/kubernetes/kubecontainerwaiting.md) if one of the containers is crashlooping or stuck on creation

If the container is running but the pod is still failing the readiness probe, involve the development team and troubleshoot application-specific readiness probe failures

## Escalations

Involve the development team for the corresponding service to get more insights into liveness probe failure or high resource utilization
