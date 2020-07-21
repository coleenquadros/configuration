# KubeContainerWaiting

## Severity: High

## Impact

The impact of this alert depends on what kind of workload the pods have been running, and if we have other replicas of the pod in a ready state. 

In the case we don't have other replicas ready and a single pod (for example an operator) is stuck in the waiting state, this may result in a full outage.

## Summary

## Access required

Cluster and namespace access. For instructions on how to find out the cluster, see the quickstart SOP https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/sop/accessing-clusters.md

## Steps

- Step 1: Look at the 'reason'

- Step 2: Follow the SOP corresponding to the reason:

### InvalidImageName

The container image specified is not valid according to the container image format

The correct format is `REGISTRY:REPOSITORY:TAG`

### ContainerCreating

The container is stuck in a 'creating' state. There can be a couple of root causes for this.

A common root cause is if the container has a PVC that's waiting to be bound. Check the events in the namespace to get an idea of why the container is stuck in this state.

### CrashLoopBackOff

Check `containerStatuses.lastState.reason` on the Pod. The common causes and solutions are

- OOMkilled : Check if CPU is being throttled, involve development team
- Liveness probe failures : Check for CPU saturation, involve the development team
- A bug in application code : Escalate this to the development team

- See: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/ for some more tips for debugging running pods

### CreateContainerConfigError

A secret or configmap referenced from the pod template isn't actually present in the namespace

- Check the namespace' events
- Get the name of the secret/configmap
- Add the missing secret/configmap to the namespace

### CreateContainerError

- Check the events on the namespace
- This may be surfacing one of the following issues:
  - The cluster doesn't have enough available resources to schedule this pod
  - The kubelet or container runtime are not healthy
- Involve SREP in case the errors point to the container runtime

### ErrImagePull

- Make sure that you have the name of the image specified correctly and in the format `REGISTRY:REPOSITORY:TAG`
- Go to the registry and list available images to see if the image is listed

Note: You may not be able to pull private images on your local machine if you're not logged in to the registry via the CLI.

### ImagePullBackOff

The container enters this state after multiple attempts to start resulting in an ErrImagePull. Please follow the SOP for ErrImagePull

## Escalations

In case of Kubelet or Container runtime issues, escalate to SREP via a ServiceNow ticket: https://redhat.service-now.com/help?id=sc_cat_item&sys_id=200813d513e3f600dce03ff18144b0fd
