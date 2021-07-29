# SOP : Service Registry Service SOPs

<!-- TOC depthTo:3 -->
- [SOP : Service Registry Service SOPs](#sops)
  - [SOP : Service Registry Service Fleet Manager](#sop--srs-fleet-manager)
    - [SRS Fleet Manager Down](#srs-fleet-manager-down)
      - [Impact](#impact)
      - [Summary](#summary)
      - [Access required](#access-required)
      - [Relevant secrets](#relevant-secrets)
      - [Steps](#steps)
    - [SRS Fleet Manager availability](#srs-fleet-manager-availability)
      - [Impact](#impact-1)
      - [Summary](#summary-1)
      - [Access required](#access-required-1)
      - [Relevant secrets](#relevant-secrets-1)
      - [Steps](#steps-1)
    - [SRS Fleet Manager latency](#srs-fleet-manager-latency)
      - [Impact](#impact-2)
      - [Summary](#summary-2)
      - [Access required](#access-required-2)
      - [Relevant secrets](#relevant-secrets-2)
      - [Steps](#steps-2)
  - [SOP : Service Registry Service Data Plane](#sop--service-registry)
    - [SRS Service Registry Down](#service-registry-down)
      - [Impact](#impact-3)
      - [Summary](#summary-3)
      - [Access required](#access-required-3)
      - [Relevant secrets](#relevant-secrets-3)
      - [Steps](#steps-3)
    - [SRS Service Registry availability](#srs-service-registry-availability)
      - [Impact](#impact-4)
      - [Summary](#summary-4)
      - [Access required](#access-required-4)
      - [Relevant secrets](#relevant-secrets-4)
      - [Steps](#steps-4)
    - [SRS Service Registry latency](#srs-service-registry-latency)
      - [Impact](#impact-5)
      - [Summary](#summary-5)
      - [Access required](#access-required-5)
      - [Relevant secrets](#relevant-secrets-5)
      - [Steps](#steps-5)
    - [SRS Tenant Manager availability](#srs-tenant-manager-availability)
      - [Impact](#impact-6)
      - [Summary](#summary-6)
      - [Access required](#access-required-6)
      - [Relevant secrets](#relevant-secrets-6)
      - [Steps](#steps-6)
    - [SRS Tenant Manager latency](#srs-tenant-manager-latency)
      - [Impact](#impact-7)
      - [Summary](#summary-7)
      - [Access required](#access-required-7)
      - [Relevant secrets](#relevant-secrets-7)
      - [Steps](#steps-7)
  - [Escalations](#escalations)

<!-- /TOC -->

---

# SOP : Service Registry Service Fleet Manager

## SRS Fleet Manager Down

### Impact

No incoming request can be received or processed. 
The existing registered Service Registry provisioning jobs will not be able to be processed.  
Users will not be able to retrieve their Service Registry instances status and connection details.
Service Registry UI in console.redhat.com will not work properly, because of errors in API calls.

### Summary

SRS Fleet Manager (all of the replicas or pods) are down.

### Access required

- OSD console access to the cluster that runs the SRS Fleet Manager.
- Access to cluster resources: Pods/Deployments/Events

### Relevant secrets

### Steps

- Check Deployments/srs-fleet-manager: check details page to make sure pods are configured and started; make sure pod number is configured to default: 3.
- Check cluster event logs to ensure there is no abnormality in the cluster level that could impact SRS Fleet Manager API.
  - Search Error/exception events with keywords "SRS Fleet Manager " and with text "image", "deployment" etc.
- Investigate the metrics in Grafana for any possible evidences of the crash.
  - Application: Volume, Latency, Error
      - Stage: https://grafana.stage.devshift.net/d/Tbw1Eg2Mz/srs-fleet-manager-metrics
      - Production: TODO
  - CPU, Network, Memory, IO
      - Stage: https://grafana.stage.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=service-registry-stage
      - Production: https://grafana.app-sre.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-namespace=service-registry-production
- Sentry -- TODO
- If necessary, escalate the incident to the corresponding teams.  
  - Check [Escalations](#escalations) section below.

---

## SRS Fleet Manager availability

### Impact

Users are getting numerous amount of errors on API requests.

### Summary

SRS Fleet Manager is not performing normally and is returning an abnormally high number of 5xx Error requests.

### Access required

- OSD Console access to the cluster that runs the SRS Fleet Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

- Investigate the metrics in Grafana for any possible cause of the issue
  - Application: Volume, Latency, Error
      - Stage: https://grafana.stage.devshift.net/d/Tbw1Eg2Mz/srs-fleet-manager-metrics
      - Production: TODO
  - CPU, Network, Memory, IO
      - Stage: https://grafana.stage.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=service-registry-stage
      - Production: https://grafana.app-sre.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-namespace=service-registry-production
- If there are container performance issue are identified (e.g.: CPU spike, high Latency etc), increase the number of replicas.
- Sentry -- TODO
- Check Deployments/srs-fleet-manager, check details page to make sure pods are configured and started. Start the pod if none is running (default:3).
- Check if the SRS Fleet Manager pods are running and verify the logs.
    ```
    #example
    oc get pods -n <service-registry-stage|service-registry-production>

    srs-fleet-manager-58f7b8b649-2mgcp   1/1     Running
    srs-fleet-manager-58f7b8b649-blf5h   1/1     Running
    srs-fleet-manager-58f7b8b649-lzxms   1/1     Running

    # Check the pod logs to investigate possible causes of the issue (e.g. look for any Error/Exception messages)

    oc logs srs-fleet-manager-58f7b8b649-2mgcp  | less
- If necessary, escalate the incident to the corresponding teams.  
  - Check [Escalations](#escalations) section below.

---

## SRS Fleet Manager latency

### Impact

SRS Fleet Manager service is experiencing latency, or has been downgraded.

### Summary

SRS Fleet Manager is not performing normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the SRS Fleet Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

refer to the steps in [SRS Fleet Manager availability](#srs-fleet-manager-availability)

---

# SOP : Service Registry Service Data Plane

## SRS Service Registry Down

### Impact

No incoming request can be received or processed.
Service Registry Service users cannot use the service, requests to Service Registry Apicurio Registry will get rejected.
Service Registry Data Plane UI in console.redhat.com will not work properly, because of errors in API calls.

### Summary

SRS Service Registry (all of the replicas or pods) are down.

### Access required

- OSD console access to the cluster that runs the SRS Service Registry.
- Access to cluster resources: Pods/Deployments/Events

### Relevant secrets

### Steps

- Check Deployments/apicurio-registry: check details page to make sure pods are configured and started; make sure pod number is configured to default: 3.
- Check cluster event logs to ensure there is no abnormality in the cluster level that could impact SRS Service Registry.
  - Search Error/exception events with keywords "Apicurio Registry" and with text "image", "deployment" etc.
- Investigate the metrics in Grafana for any possible evidences of the crash.
  - Application: Volume, Latency, Error
      - Stage: https://grafana.stage.devshift.net/d/VRxU14jZ1/service-registry-data-plane-metrics?orgId=1
      - Production: TODO
  - CPU, Network, Memory, IO
      - Stage: https://grafana.stage.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=service-registry-stage
      - Production: https://grafana.app-sre.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-namespace=service-registry-production
- Sentry -- TODO
- If necessary, escalate the incident to the corresponding teams.
  - Check [Escalations](#escalations) section below.

---

## SRS Service Registry availability

### Impact

Users are getting numerous amount of errors on API requests.

### Summary

SRS Service Registry is not performing normally and is returning an abnormally high number of 5xx Error requests.

### Access required

- OSD Console access to the cluster that runs the SRS Service Registry .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

- Investigate the metrics in Grafana for any possible cause of the issue
  - Application: Volume, Latency, Error
      - Stage: https://grafana.stage.devshift.net/d/VRxU14jZ1/service-registry-data-plane-metrics?orgId=1
      - Production: TODO
  - CPU, Network, Memory, IO
      - Stage: https://grafana.stage.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=service-registry-stage
      - Production: https://grafana.app-sre.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-namespace=service-registry-production
- If there are container performance issue are identified (e.g.: CPU spike, high Latency etc), increase the number of replicas.
- Sentry -- TODO
- Check Deployments/apicurio-registry, check details page to make sure pods are configured and started. Start the pod if none is running (default:3).
- Check if the SRS Service Registry pods are running and verify the logs.
    ```
    #example
    oc get pods -n <service-registry-stage|service-registry-production>

    apicurio-registry-58f7b8b649-2mgcp   1/1     Running
    apicurio-registry-58f7b8b649-blf5h   1/1     Running
    apicurio-registry-58f7b8b649-lzxms   1/1     Running

    # Check the pod logs to investigate possible causes of the issue (e.g. look for any Error/Exception messages)

    oc logs apicurio-registry-58f7b8b649-2mgcp  | less
- If necessary, escalate the incident to the corresponding teams.
  - Check [Escalations](#escalations) section below.

---

## SRS Service Registry latency

### Impact

SRS Service Registry service is experiencing latency, or has been downgraded.

### Summary

SRS Service Registry is not performing normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the SRS Service Registry .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

refer to the steps in [SRS Service Registry availability](#srs-service-registry-availability)

---

## SRS Tenant Manager availability

### Impact

Users are getting numerous amount of errors on API requests.

### Summary

SRS Tenant Manager is not performing normally and is returning an abnormally high number of 5xx Error requests.

### Access required

- OSD Console access to the cluster that runs the SRS Tenant Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

Tenant Manager is deployed as a sidecar to Service Registry. Refer to the steps in [SRS Service Registry availability](#srs-service-registry-availability)

---

## SRS Tenant Manager latency

### Impact

SRS Tenant Manager service is experiencing latency, or has been downgraded.

### Summary

SRS Tenant Manager is not performing normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the SRS Tenant Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

Tenant Manager is deployed as a sidecar to Service Registry. Refer to the steps in [SRS Service Registry availability](#srs-service-registry-availability)

---

## Escalations

- Error/exception appears related to SRS Fleet Manager API or no leader worker is running, try to restart the pods.
- Error/exception events found in the OSD cluster level, check with OCM support.
- Otherwise, or if unsure about the reason, escalate the issue to the Service Registry team 
