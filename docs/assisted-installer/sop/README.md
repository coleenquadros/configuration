# SOP

## Assisted Installer Low Availability
[alert-stage](/resources/observability/prometheusrules/assisted-installer-stage.prometheusrules.yaml#L15)
[alert-prod](/resources/observability/prometheusrules/assisted-installer-production.prometheusrules.yaml#L15)

### Severity: Medium

### Impact
Users are getting errors on API requests

### Summary
Assisted Installer  service API is returning an abnormally high number of 5xx Error requests

### Access required

- Access to the cluster that runs the assisted-service Pod
- View access to the namespaces:
  - assisted-installer

### Steps
- Check for error level logs in the pod.
    `oc logs pod/<pod> -n assisted-installer-<stage|production> | grep level=error`
- In each log you will see a `request-id`, you can then filter the logs with that `request-id` in order to track a single request.
    `oc logs pod/<pod> -n assisted-installer-<stage|production> | grep level=error  | grep <request-id>`

### Escalations
- Ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert

## Assisted Installer High Latency
[alert-stage](/resources/observability/prometheusrules/assisted-installer-stage.prometheusrules.yaml#L128)
[alert-prod](/resources/observability/prometheusrules/assisted-installer-production.prometheusrules.yaml#L128)

### Severity: Medium

### Impact
Users are experiencing hight latency on API requests

### Summary
Assisted Installer service API is having an abnormally high number of requests with high latency

### Access required

- Access to the cluster that runs the assisted-service Pod
  - stage: https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/cluster/projects
  - prod: https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/k8s/cluster/projects
- View access to the namespaces:
  - assisted-installer-<stage|production>

### Steps
- Make sure the service has all its replicas running
- Check service distribution of requests between the different pods.

### Escalations
- Ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert

## Assisted Installer Service Is Down

### Severity: Critical

### Impact
Users are unable to access Assisted Installer service

### Summary
There are 0 pods serving Assisted-installer service.

### Access required

- Access to the cluster that runs the assisted-service Pod
  - stage: https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/cluster/projects
  - prod: https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/k8s/cluster/projects
- View access to the namespaces:
  - assisted-installer-<stage|production>

### Steps
- Check the endpoint:

    - Stage:
    `curl https://api.stage.openshift.com/api/assisted-install/v1/clusters -H "Authorization: bearer $(ocm token)"`

    - Production:
    `curl https://api.openshift.com/api/assisted-install/v1/clusters -H "Authorization: bearer $(ocm token)"`

  If service is up you should get a list of clusters, might be `[]` if you never created any clusters.

- Check that the Pods are running in the `assisted-installer-<stage|production>` Namespace on the `app-sre-stage-01|app-sre-prod-04` cluster.

- Check what is the reason the pods aren't running:
    `oc describe pod/<pod> -n assisted-installer-<stage|production>`

  When a pod restarts it is possible for it to have about 3 restarts in case the DB just came up as well because it fails to connect to it until DB is ready, this process shouldn't take more than 5 minutes so we shouldn't get an alert for it from the first place.

- Check for error level logs in the pod.
    `oc logs pod/<pod> -n assisted-installer-<stage|production> | grep error`

### Escalations
- Ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert

## Assisted Installer Version Upgrade Failed

### Severity: Info

### Impact
Incremental version upgrade on the service pods has failed.

### Summary
When a version upgrade occurs, it is first deployed on a single pod and only if it is deployed without
errors the reset of the pods will be upgraded as well.

If the first pods failed to upgrade we want to be notified about it regardless the job which handle the upgrade.

### Access required

- Access to the cluster that runs the assisted-service Pod
- View access to the namespaces:
  - assisted-installer

### Steps
- Check which pod failed
- Describe the pod to identify the reason of the failure - look at the events.

## Assisted Installer Cluster Installation

### Severity: Medium

### Impact
Users are unable to deploy new bare-metal OpenShift clusters using Assisted Installer

### Summary
Assisted-installer based cluster installation fails to complete.

### Access required

- Access to the cluster that runs the assisted-service Pod
- View access to the namespaces:
  - assisted-installer

### Steps
- Check the production endpoint:

    `curl https://api.openshift.com/api/assisted-install/v1/clusters -H "Authorization: bearer $(ocm token)"`

   => Both might return `[]` if you never created any clusters

- Check that the Pods are running in the `assisted-installer` Namespace on the `app-sre-prod-04` cluster.

### Escalations
- Ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert)

## Assisted Installer Events Is Down

### Severity: Info

### Impact
Usage statistics might lagging and not be near-real-time

### Summary
When the process storing usage statistics fails, it might lead to restarts. Some are controlled restarts (when there are too many errors), other might be non-controlled errors.

### Access required

- Access to the cluster that runs the assisted-events-scrape Pod
- View access to the namespaces:
  - assisted-installer

### Steps
- Check why pod failed
- Check pod logs for failure that triggered the restarts

## Assisted Installer Events No CPU activity

### Severity: Info

### Impact
Usage statistics stop updating

### Summary
Due to unknown issue(s), the process might "hang" and stop computing.
We should find out what causes this and ultimately fix the root cause.

### Access required

- Access to the cluster that runs the assisted-events-scrape Pod
- View access to the namespaces:
  - assisted-installer

### Steps
- Check why pod is hanging
- If unable to understand the reason within a reasonable time, restart the pod

## Assisted Installer Events ingestion reduced

### Severity: Info

### Impact
Usage statistics stop updating

### Summary
Due to unknown issue(s), we are not saving enough data to elasticsearch.
We must find out why this is happening

### Access required

- Access to the cluster that runs the assisted-events-scrape Pod
- View access to the namespaces:
  - assisted-installer
- Access to elasticsearch instance https://kibana-assisted.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/_dashboards/app

### Steps
- check if document ratio between elasticsearch and DB is close to 0
- if close to 0
  - check if event-scrape hang
  - check if elasticsearch is having issues
- if not close to 0, check why we are not ingesting as many events
  - many events that are not being imported (deleted clusters?)
  - issues with some type of documents in elasticsearch/scraper logic?

## Memory Consumption is too high

### Severity: Warning

### Impact
Possibly pods will get OOMKilled, and some requests might return 500.
If the problem is severe and restart happen too frequently, we might get service downtime.


### Summary
Pods are consuming much more memory than expected.
This can be due to several reasons.

### Access required

To mitigate this issue, the only requirement is the ability to change MEMORY_LIMIT/MEMORY_REQUEST
openshift template parameters in the manifest (they can be changed [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/assisted-installer/cicd/saas.yaml#L73) ).
To solve this issue, we must first identify the root cause.

### Steps
- Check if the pod is being OOMKilled or it's risking to be OOMKilled
- If there is no real risk, or minor risk, this can be raised to @edge-support in CoreOS slack
- If we are having many OOMKills, we can mitigate this by increasing MEMORY_LIMIT/MEMORY_REQUESTS
- Run a deeper analysis to understand what's the root cause behind this. This might be due to a memory leak of many forms, due to our own code, third part libraries, or underlying data not properly handled

### Escalations
- If `@edge-support` is unresponsive, ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert


## Anomaly detected

### Severity: Warning

### Impact
Depending on what is the anomaly, this might be having an effect on the product (or might have soon)
degrading the quality of service.


### Summary
Anomalies could be related to incoming http requests, CPU usage, events generation.

### Access required

Grafana access is usually enough to determine what impact is the anomaly having on the product.

### Steps
- Deterimne impact of the anomaly on the product
- Share findings with `@edge-support` and decide best route to take

### Escalations
- If `@edge-support` is unresponsive, ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert


## Pods restarting

### Severity: Warning

### Impact
Some connections will be killed resulting in 500s.
If the problem is severe and restart happen too frequently, we might get service downtime.


### Summary
This can be due to uncaught exceptions, panics, and the likes or OOMKills.
Not always OOMKills are marked as such: if the pod it's not above its limit but there is no memory
in the node, it can get be marked as Error instead of OOMKilled, although the reason it's still related.

### Access required

Depending on the solution, we need different level of access.

* Access to Grafana [log dashboard](https://grafana.app-sre.devshift.net/d/F8vaevHVz/assisted-installer-logs?orgId=1)
* Ability to change MEMORY_LIMIT and/or MEMORY_REQUEST [parameters](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/assisted-installer/cicd/saas.yaml#L73)

### Steps
- Check why the containers are being restarted
- If this is due to panic/uncaught exception or some other code error, escalate to `@edge-support` or `@assisted-installer-team`
- If this is due to memory consumption, we need to run a deeper investigation on why this is happening

### Escalations
- If `@edge-support` is unresponsive, ping the `@assistedinstaller-team` user on Slack channel #team-assisted-installer-alert
