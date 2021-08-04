## Token refresher down

### Impact

No data can be sent or received from Observatorium, directly impacting dashboards as well as user facing metrics via the Kas fleet manager API.

### Summary

The Managed Services Token refresher (Pod) is down.

### Access required

- OSD console access to the cluster that runs the Managed services token refresher.
- Access to cluster resources: Pods/Deployments/Events.

### Relevant secrets

### Steps

1. Check the events for any errors
2. Check the token refresher deployment ensuring the pod count is 1 and and if any conditions have failed.
3. Check the status located in the deployment yaml.

## Escalations

If problem cannot not be solved escalate the issue to the Control Plane team 

