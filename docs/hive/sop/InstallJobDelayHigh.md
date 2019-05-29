# SOP : InstallJobDelayHigh Alert

<!-- TOC depthTo:2 -->

- [SOP : InstallJobDelayHigh](#installjobdelayhigh)

<!-- /TOC -->

---

## InstallJobDelayHigh

### Impact:
Long delays from the creation of a ClusterDeployment object to the install job being started.

### Summary:
When a new ClusterDeployment object has been created, there should be a Job created that will start the installation process to instantiate the cluster.

### Access required:
Access to stg/prod hive cluster (for access to Kibana and potentiall oc CLI access).

### Relevant secrets:

### Steps:
1. Open a browser to the appropriate (eg stg or prod) logs URL.
2. Search for "calculated time to install job".
3. From the results find log entries where the 'elapsed' field is abnormally large (greater than 600 seconds).

Now you can search for more log info related to the cluster with a Kibana query like 'message:("controller=clusterDeployment" AND "namespace=NAMESPACE_OF_CLUSTER_FROM_PREVIOUS_KIBANA_SEARCH_RESULTS")'

Or you can use the oc CLI access to investigate the various objects related to the cluster in the namespace.

---
