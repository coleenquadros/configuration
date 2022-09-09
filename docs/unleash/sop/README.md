# SOP : Unleash

## UnleashPodDown

### Impact

With a unleash pod not working, tenants ability to toggle their services may not work.

### Summary

Unleash pods are down.

### Access required

- OSD console access to the cluster that contains the Unleash pod.
- Access to cluster resources: Pods/Deployments/Events

### Steps

- Check the pod in question by looking at [grafana](https://grafana.app-sre.devshift.net/d/6kpIaoM5z/unleash-performance-overview).
- Login to the cluster that hosts that Unleash pod.
- Inspect the logs for the unleash pod.
- Compare the logs from the unleash pod to recent changes in app-interface to see if there is some correlation.
    - Also check qontract-reconcile changes to see if there is a correlation in the timeframe of the alert firing.
- Ping app-sre team members in the teamchat for more guidance if needed.
