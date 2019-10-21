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

### Initial Data Gathering
The purpose of this section is to give a starting point for investigating possible causes.

This alert is an "aggregated" alert, meaning that several alert conditions are grouped into a single alert. Aggregated alerts
are more efficient use of the monitoring infrastructure, but they also don't allow for the alert to tell you which ClusterDeployments / 
Namespaces are causing the alert (Note: it can be multiple).

Because of this, this section it is necessary to gather information from logs in order to determine which clusters are causing the alert.

This section steps through how to gather that information.

#### Steps to investigate:
1. Open a browser to the appropriate (eg stg or prod) logs URL.
1. Ensure that the drop down in the upper left says `project.hive.<uuid>`
1. Change the `Time Range` in the upper right to appropriate value e.g. `Last 24 hours`.
1. Search for "calculated time to first provision seconds".
   ```
   message:("msg=calculated time to first provision seconds")
   ```
1. From the results find log entries where the `elapsed` field is abnormally large (greater than 600 seconds) and note down the `elapsed` and `namespace` values.


### Possible Cause - DNS Propogation Delay
SRE is using a feature of Hive where Hive will create and manage DNS infrastructure (zones and NS entries) for each cluster.

Without the DNS infrastructure correctly setup, the install will fail.

As such, Hive will NOT start an install until all of the DNS has been successfully set up and is correctly resolving.
#### Steps to investigate:
1. Using the data previously gathered, run a query to see how long dns took to become resolvable:
   ```
   message:("controller=clusterDeployment" AND "namespace=NAMESPACE_OF_CLUSTER_FROM_PREVIOUS_KIBANA_SEARCH_RESULTS" AND "msg=DNS ready")
   ```
1. Note the `duration` field. If the duration is close to the same amount of time as the `elapsed` field gathered previously, then this indicates that the problem was likely caused because DNS propagation took too long. If this is the case, then this is likely NOT a hive issue (out of our control).


### Possible Cause - None of the above / Catch All
If none of the above possible causes were found to be true, further investigation needs to take place.

This section describes a more generalized way to investigate this issue. When the cause is ultimately determined, a new section should be added to this SOP describing how to determine that new cause.

#### Steps to investigate:
1. Search for more log info related to the cluster with a Kibana query:
   ```
   message:("controller=clusterDeployment" AND "namespace=NAMESPACE_OF_CLUSTER_FROM_PREVIOUS_KIBANA_SEARCH_RESULTS")
   ```
1. Another approach is to use the oc CLI access to investigate the various objects related to the cluster in the namespace.










