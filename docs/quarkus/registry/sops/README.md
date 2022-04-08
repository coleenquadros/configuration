# SOP

## Quarkus Registry Low Availability
[alert-prod](/resources/observability/prometheusrules/registry-quarkus-redhat-production.prometheusrules.yaml#L15)

### Severity: Medium

### Impact
Users are getting errors on API requests

### Summary
Quarkus Registry service API is returning an abnormally high number of 5xx Error requests

### Access required

- Access to the cluster that runs the registry-quarkus Pod
- View access to the namespaces:
  - registry-quarkus-redhat-production

### Steps
- Check for error level logs in the pod.
    `oc logs pod/<pod> -n registry-quarkus-redhat-<stage|production> | grep level=error`
- In each log you will see a `request-id`, you can then filter the logs with that `request-id` in order to track a single request.
    `oc logs pod/<pod> -n registry-quarkus-redhat-<stage|production> | grep level=error  | grep <request-id>`

### Escalations
- Ping the `#team-quarkus-info` channel on Slack

## Quarkus Registry High Latency
[alert-prod](/resources/observability/prometheusrules/registry-quarkus-redhat-production.prometheusrules.yaml#L128)

### Severity: Medium

### Impact
Users are experiencing high latency on API requests

### Summary
Quarkus Registry service API is having an abnormally high number of requests with high latency

### Access required

- Access to the cluster that runs the quarkus-registry Pod
  - stage: https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/cluster/projects/registry-quarkus-redhat-stage
  - prod: https://console-openshift-console.apps.app-sre-prod-01.i7w5.p1.openshiftapps.com/k8s/cluster/projects/registry-quarkus-redhat-production
- View access to the namespaces:
  - registry-quarkus-redhat-<stage|production>

### Steps
- Make sure the service has all its replicas running
- Check service distribution of requests between the different pods.

### Escalations
- Ping the `#team-quarkus-info` channel on Slack

## Quarkus Registry Service Is Down

### Severity: Critical

### Impact
Users are unable to access the Quarkus Registry service

### Summary
There are 0 pods serving the `quarkus-registry` service.

### Access required

- Access to the cluster that runs the assisted-service Pod
  - stage: https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/cluster/projects/registry-quarkus-redhat-stage
  - prod: https://console-openshift-console.apps.app-sre-prod-01.i7w5.p1.openshiftapps.com/k8s/cluster/projects/registry-quarkus-redhat-production
- View access to the namespaces:
  - registry-quarkus-redhat-<stage|production>

### Steps
- Check the endpoint:

    - Stage:
    `curl https://registry.quarkus.stage.redhat.com/q/health`

    - Production:
    `curl https://registry.quarkus.redhat.com/q/health`

  If the service is up you should get a JSON containing a `"status":"UP"` attribute.

- Check that the Pods are running in the `registry-quarkus-redhat-<stage|production>` namespace on the `app-sre-stage-01|app-sre-prod-04` cluster.

- Check what is the reason the pods aren't running:
    `oc describe pod/<pod> -n registry-quarkus-redhat-<stage|production>`

  When a pod restarts it is possible for it to have about 3 restarts in case the DB just came up as well because it fails to connect to it until DB is ready, this process shouldn't take more than 5 minutes, so we shouldn't get an alert for it from the first place.

- Check for error level logs in the pod.
    `oc logs pod/<pod> -n registry-quarkus-redhat-<stage|production> | grep error`

### Escalations
- Ping the `#team-quarkus-info` channel on Slack

## Quarkus Registry Version Upgrade Failed

### Severity: Info

### Impact
Incremental version upgrade on the service pods has failed.

### Summary
When a version upgrade occurs, it is first deployed on a single pod and only if it is deployed without
errors the reset of the pods will be upgraded as well.

If the first pods failed to upgrade we want to be notified about it regardless the job which handle the upgrade.

### Access required

- Access to the cluster that runs the registry-quarkus Pod
- View access to the namespaces:
  - registry-quarkus-redhat-production

### Steps
- Check which pod failed
- Describe the pod to identify the reason of the failure - look at the events.

