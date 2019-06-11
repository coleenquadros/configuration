# SOP : ClusterDeprovisioningDelay Alert

<!-- TOC depthTo:2 -->

- [SOP : ClusterDeprovisioningDelay](#clusterdeprovisioningdelay)

<!-- /TOC -->

---

## ClusterProvisioningDelay

### Impact:
Cluster deprovisioning taking over 2 hours.

### Summary:
When a new ClusterDeployment object has been created, there should be a Job created that will start the installation process to instantiate the cluster.

If the installation process is taking more than 2 hours (this includes installation retries and restarts), then this alert will fire.

### Access required:
Access to stg/prod hive cluster (for access to Kibana and potentiall oc CLI access).

### Relevant secrets:

### TroubleShooting The Alert:
### Steps:
1. Open a browser to the appropriate (eg stg or prod) logs URL.
2. Get the namespace from the alert. Search for the namespace in Kibana e.g. `message:("namespace=uhc-staging-1665jrb1hi0u017786kdqjemq675mcnf")`.
3. Search for error or failure in the Kibana logs.

Or you can use the oc CLI access to investigate the various objects related to the cluster in the namespace.


