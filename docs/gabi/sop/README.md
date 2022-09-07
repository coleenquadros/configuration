# SOP : Gabi

## GabiPodDown

### Impact

With a Gabi pod not working, tenants are not able to get a query from their database.

### Summary

Gabi pods are down.

### Access required

- OSD console access to the cluster that contains the Gabi pod.
- Access to cluster resources: Pods/Deployments/Events

### Steps

- Check the pod in question by looking at [grafana](https://grafana.stage.devshift.net/d/rdYb2UZkZ/gabi-performance-overview).
- Login to the cluster that hosts that Gabi pod.
- Inspect the logs for the gabi pod.
    - If there is an issue with the `serviceAccount` not having the necessary permissions then check through the saas files in [app-interface](https://gitlab.cee.redhat.com/service/app-interface) to ensure that the `serviceAccount` name value is the same as the `GABI_INSTANCE` value
    - If there is an issue with not being able to connect to the database, check to see if the database is still available in AWS
        - If the database is not in AWS, ensure that work was intentional with the tenant and remove other mentions of the gabi instance within [app-interface](https://gitlab.cee.redhat.com/service/app-interface)
