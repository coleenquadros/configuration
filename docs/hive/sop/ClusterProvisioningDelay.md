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
1. Get the namespace of the hive cluster from the alert string and set a variable:
   ```
   export NAMESPACE=uhc-staging-1639ukj4fdufqtitlh4gvjl0ae1s5ju3
   ```

#### Troubleshooting using logs
Hive stores the non-debug installer log entries in `clusterprovision` objects in the same namespace as the cluster deployment.

1. Get a list of `clusterprovision` objects:
   ```
   oc get clusterprovision -n $NAMESPACE
   ```
1. Hive keeps around the first attempted cluster provision object (`*-0-*`) as well as the most recent 3 cluster provision objects.
   Choose which attempt you'd like to look at the logs and set a variable. This example uses the first attempted cluster provision object.
   ```
   export CLSTRPROV=sreusr-clstr-0-bkhnd
   ```
1. View the installer log data
   ```
   oc get clusterprovision -n $NAMESPACE -o json $CLSTRPROV | jq -r '.spec.installLog'
   ```
1. If the output for that command is `null`, this means that the `installLog` part of the spec was not filled out for some reason.

#### Troubleshoot using pod status
1. Look at the pods in the namespace to see what STATUS they have:

   ```bash
   $ oc get pods -n $NAMESPACE
   ```

1. Check the output of `oc get pods` with the following:

##### Completed
1. If the install pod has a status of `Completed`. This usually means that the install has completed. Move on to troubleshooting using.

##### ImagePullBackOff
1. If the pod status is in `ImagePullBackOff` check the name of the pod. If the name contains `yuwan-` then send an e-mail to the e-mail thread with the subject "Re: Yuwan UHC Stage Clusters Installer ImagePullBackOff" with the latest alerts. If you are not on that thread, then ask dgoodwin or twiest to add you to the thread.
1.  Here is an example of what that looks like.
   ```
   NAME                               READY   STATUS             RESTARTS   AGE
   yuwan-test-2606-1-imageset-p8plb   0/2     Completed          0          18h
   yuwan-test-2606-1-install-45jvl    1/2     ImagePullBackOff   0          18h
   ```
1. If the name is _not_ yuwan, then investigate further by seeing what imageset is being used and if the image URLs are indeed valid.


##### CrashLoopBackOff
1. This can be caused by a number of factors.


#### Troubleshoot using ClusterDeployment Conditions:

1. Look at the conditions on the current namespace using the following command:
   ```bash
   $ oc get clusterdeployment -n $NAMESPACE -o json | jq '.items[].status.conditions'
   ```
1. The output from ClusterDeployment Conditions can say a lot about the cluster.

##### Previously observed conditions:

###### DNSNotReady

1. The ClusterDeployment is showing a DNS not ready condition (literally condition type 'DNSNotReady').
1. Looking at the logs for the hive controllers ('oc logs' in the hive namespace), you might see:
   ```
   time="2019-10-08T15:40:13Z" level=info msg="looking up domain SOA record" controller=dnszone dnszone=jsica-testing-zone namespace=uhc-production-18l35214uc8rva7471atoi75huenv3q4 servers="[10.121.19.148:53]"
   
   time="2019-10-08T15:40:13Z" level=info msg="no answer for SOA record returned" controller=dnszone dnszone=jsica-testing-zone namespace=uhc-production-18l35214uc8rva7471atoi75huenv3q4 server="10.121.19.148:53"
   
   time="2019-10-08T15:40:13Z" level=info msg="SOA record for DNS zone not available" controller=dnszone dnszone=jsica-testing-zone namespace=uhc-production-18l35214uc8rva7471atoi75huenv3q4
   ```
1. The external-dns pod (runs in the hive namespace) is responsible for making DNS entries for hive. Check the logs on the external-dns pod.
1. If the pod's most recent log messages are the following repeated every minute (Kibana query 'kubernetes.container_name=external-dns AND kubernetes.namesapce_name=hive'):
   ```
   time=\"2019-10-08T18:27:21Z\" level=error msg=Unauthorized
   ```
   The external-dns pod has hit an unresolved state (still not root-caused as this is intermittent). Being tracked in [Jira](https://issues.redhat.com/browse/CO-590).
1. Deleting the external-dns pod will cause it to relaunch and things should return to a working state.

#### Determined That it's Not a Hive issue
As described in the [Hive SLA document](https://docs.google.com/document/d/1_kAbsz28XpVzzkya1XsSnuAH-dF4vj7MonMotp1pwhQ/edit#heading=h.hklz0i1jef0m), the Hive team's responsibility is to ensure that Hive is correctly launching the installer.

This means that if the Hive cop has determined that the installer failed in a way that is unrelated to Hive, then the Hive cop is not responsible to investigate further.

Instead, as a courtesy, we should e-mail the owner of the cluster to notify them to the fact that their cluster is alerting.

Example e-mail (manually substitute the variables):
```
To: $USER
CC: dgoodwin@redhat.com
Subject: Cluster $CLUSTER failing to provision...
Body:
Hey $USER,
   Just letting you know that your cluster "$CLUSTER" in namespace "$NAMESPACE"  is failing to provision in ocm / hive $ENVIRONMENT. This is alerting on the Hive alert slack channel "team-hive-alert" (which is why I'm e-mailing you). 

Your cluster is failing to provision and as far as I can tell it's not Hive related. In other words, it seems that Hive is correctly launching the installer.

The installer (non-debug) log is:
"$INSTALLER_FAILURE_LOG"

For failures, Hive attempts to gather the full installer logs. If available, you can access them by following the instructions here:

https://github.com/openshift/hive/blob/master/docs/troubleshooting.md#cluster-install-failure-logs

Thanks,
Hive Cop
```
