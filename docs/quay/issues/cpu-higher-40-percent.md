# The Quay Pod CPU usage is higher than 40% for 5 minutes.

To resolve this issue

1. Login to cluster on your CLI.
2. Identify the pod if you don't have pod name available using command `oc get pods -n quay -o wide | grep <IP_ADDRESS>`
3. Terminate the pod. `oc delete pod <pod_name>`.

