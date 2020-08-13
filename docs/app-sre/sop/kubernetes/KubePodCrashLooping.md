# KubePodCrashLooping

## Severity: high

## Impact

The pod is unable to start normally, which may cause a partial to complete degradation of the service

## Summary

A `PodSpec` has a `restartPolicy` field with possible values `Always`, `OnFailure`, and `Never` which applies to all containers in a pod. The default value is `Always` and the `restartPolicy` only refers to restarts of the containers by the kubelet on the same node (so the restart count will reset if the pod is rescheduled in a different node). Failed containers that are restarted by the kubelet are restarted with an exponential back-off delay (10s, 20s, 40s …) capped at five minutes, and is reset after ten minutes of successful execution.

Some common reasons a `Pod` may end up in a `CrashLoopBackOff` state:
- The application inside of the container keeps terminating (zero or non-zero exit code)
- The kubelet is terminating the pod because it has reached it's resource limits (OOMkilled)
- The kubelet is terminating the pod because the liveness probes are failing
- Some parameters of the pod have been configured incorrectly
- The kubernetes cluster / kubelet is misbehaving

Kubernetes is reporting that a pod has terminated repeatedly and has put it in a CrashLoopBackOff state. 

## Access required

Cluster and namespace access. For instructions on how to find out the cluster, see the [quickstart SOP][].

## Steps

Check `containerStatuses.lastState.reason` on the Pod. The common causes and solutions are

- OOMkilled:
  - From the console, verify the pod memory usage under the Metrics tab
  - Involve the development team as this will likely require in depth knowledge of the app to determine if the memory utilization is normal
- Liveness probe failures:
  - Look at the pod logs and see if there are any errors that might explain why the app is misbehaving
  - From the console, verify the pod CPU usage under the Metrics tab. An app that has reached it's CPU  limits may be slow to respond and may trigger liveness probe failures

Look at the pod logs and see if the container is exiting abnormally. Escalate to the development team.

Look at the namespace Events. Kubernetes will normally log warnings when a pod is failing to schedule because of a misconfiguration

See: https://kubernetes.io/docs/tasks/debug-application-cluster/debug-running-pod/ for some more tips for debugging running pods

## Escalations

Involve the development team for the corresponding service to get more insights into liveness probe failure or high resource utilization
