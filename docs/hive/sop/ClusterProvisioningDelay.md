# SOP : ClusterProvisioningDelay Alert

<!-- TOC depthTo:2 -->

- [SOP : ClusterProvisioningDelay](#clusterprovisioningdelay)

<!-- /TOC -->

---

## ClusterProvisioningDelay

### Impact:
Cluster provisioning taking over 2 hours.

### Summary:
When a new ClusterDeployment object has been created, there should be a Job created that will start the installation process to instantiate the cluster.

If the installation process is taking more than 2 hours (this includes installation retries and restarts), then this alert will fire.

### Access required:
Access to stg/prod hive cluster (for access to Kibana and potentiall oc CLI access).

### Relevant secrets:

### TroubleShooting The Alert:
#### Common to all steps
1. Login to the hive cluster using `oc`.
1. Get the namespace of the hive cluster from the alert string. For this example, we'll use namespace `uhc-staging-1639ukj4fdufqtitlh4gvjl0ae1s5ju3`.

#### Troubleshoot using pod status
1. Look at the pods in the namespace to see what STATUS they have:

   ```bash
   $ oc get pods -n uhc-staging-1631haelkqe0fmsrhghk5ldemgitetk4
   ```

1. Check the output of `oc get pods` with the following:

#### Completed
1. If the install pod has a status of `Completed`. This usually means that the install has completed. Move on to troubleshooting using.

#### ImagePullBackOff
1. If the pod status is in `ImagePullBackOff` check the name of the pod. If the name contains `yuwan-` then send an e-mail to the e-mail thread with the subject "Re: Yuwan UHC Stage Clusters Installer ImagePullBackOff" with the latest alerts. If you are not on that thread, then ask dgoodwin or twiest to add you to the thread.
1.  Here is an example of what that looks like.

   ```
   NAME                               READY   STATUS             RESTARTS   AGE
   yuwan-test-2606-1-imageset-p8plb   0/2     Completed          0          18h
   yuwan-test-2606-1-install-45jvl    1/2     ImagePullBackOff   0          18h
   ```

1. If the name is _not_ yuwan, then investigate further by seeing what imageset is being used and if the image URLs are indeed valid.


#### CrashLoopBackOff
1. This can be caused by a number of factors.


#### Troubleshoot using ClusterDeployment Conditions:

1. Look at the conditions on the current namespace using the following command:

   ```bash
   $ oc get clusterdeployment -n uhc-staging-1631haelkqe0fmsrhghk5ldemgitetk4 -o json | jq '.items[].status.conditions'
   ```

1. The output from ClusterDeployment Conditions can say a lot about the cluster.
1. TODO: Add specific conditions from alerts that are firing and state how to troubleshoot them.
