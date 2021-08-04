## Token refresher sending status codes other then 200

### Impact

No data can be sent or received from Observatorium, directly impacting dashboards as well as user facing metrics via the Kas fleet manager API.

### Summary

The Managed Services Token refresher is not able to send or receive metrics resulting in status codes other then 2xx being sent.

### Access required

- OSD console access to the cluster that runs the Managed services token refresher.
- Access to cluster resources: Pods/Secrets

### Relevant secrets

### Steps

1. Check the pod logs for any errors
2. Check the observatorium url is correct.
    Stage: `https://observatorium-mst.api.stage.openshift.com/api/metrics/v1/managedkafka`
    Production: `https://observatorium-mst.api.production.openshift.com/api/metrics/v1/managedkafka`
3. Check Client ID, Client Secret and Issuer URL are being populated.

## Escalations

If problem cannot not be solved escalate the issue to the Control Plane team.
