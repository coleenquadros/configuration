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

Stage Logs: 		https://logs.hive-stage.openshift.com/
Production Logs: 	https://logs.hive-production.openshift.com/

### Relevant secrets:

### TroubleShooting The Alert:
### Steps:
1. Open a browser to the appropriate (eg stg or prod) logs URL.
2. Select the hive namespace from the dropdown in Kibana to be able to view the hive-controller pod logs.
3. Select appropriate `Time Range` in Kibana(default last 15 minutes).
3. Get the namespace from the alert. Search for the namespace in Kibana e.g. `message:("namespace=uhc-staging-1665jrb1hi0u017786kdqjemq675mcnf")`.
4. Search for error or failure in the Kibana logs.

Or you can use the oc CLI access to investigate the various objects related to the cluster in the namespace.

### Common failures:
#### No API token found for service account "default", retry after the token is automatically created and added to the service account 
This issue has been seen more than once. The deprovision job cannot get started, and running 'oc describe' on the job shows:

```
Events:
  Type     Reason        Age                 From            Message
  ----     ------        ----                ----            -------
  Warning  FailedCreate  2m (x1235 over 2d)  job-controller  Error creating: No API token found for service account "default", retry after the token is automatically created and added to the service account
```

The default service account in the namespace for the job appears to have lost its reference to the token secret. 'oc get sa' on the default service account would show:

```
apiVersion: v1
imagePullSecrets:
- name: default-dockercfg-7jd6q
kind: ServiceAccount
metadata:
  creationTimestamp: 2019-07-05T03:23:14Z
  name: default
  namespace: uhc-staging-16m7987hm2ilb29d48mgk0kfvpogb2cu
  resourceVersion: "49843847"
  selfLink: /api/v1/namespaces/uhc-staging-16m7987hm2ilb29d48mgk0kfvpogb2cu/serviceaccounts/default
  uid: 391d82be-9ed4-11e9-aa89-0e3666d6b70e
secrets:
- name: default-token-xtrmz # <----- ***this secret reference missing in a "bad" SA***
- name: default-dockercfg-7jd6q
```

Update the service account secret list to add an entry for the existing token secret, and hive will eventually re-try the uninstall, and it should work.
