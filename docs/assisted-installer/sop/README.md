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
