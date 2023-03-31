# SOP : Kafka Service Fleet Manager 

<!-- TOC depthTo:2 -->

- [SOP : Kafka Service Fleet Manager](#sop--kafka-service-fleet-manager)
  - [Kafka Service Fleet Manager Down](#kafka-service-fleet-manager-down)
    - [Impact](#impact)
    - [Summary](#summary)
    - [Access required](#access-required)
    - [Relevant secrets](#relevant-secrets)
    - [Steps](#steps)
  - [Kafka Service Fleet Manager availability](#kafka-service-fleet-manager-availability)
    - [Impact](#impact-1)
    - [Summary](#summary-1)
    - [Access required](#access-required-1)
    - [Relevant secrets](#relevant-secrets-1)
    - [Steps](#steps-1)
  - [Kafka Service Fleet Manager latency](#kafka-service-fleet-manager-latency)
    - [Impact](#impact-2)
    - [Summary](#summary-2)
    - [Access required](#access-required-2)
    - [Relevant secrets](#relevant-secrets-2)
    - [Steps](#steps-2)
  - [Kafka Service Fleet Manager federate metrics endpoint latency](#kafka-service-fleet-manager-federate-metrics-endpoint-latency)
    - [Impact](#impact-3)
    - [Summary](#summary-3)
    - [Access required](#access-required-3)
    - [Relevant secrets](#relevant-secrets-3)
    - [Steps](#steps-3)
  - [OSD Cluster provisioning latency](#osd-cluster-provisioning-latency)
    - [Impact](#impact-4)
    - [Summary](#summary-4)
    - [Access required](#access-required-4)
    - [Relevant secrets](#relevant-secrets-4)
    - [Steps](#steps-4)
  - [OSD Cluster provisioning correctness](#osd-cluster-provisioning-correctness)
    - [Impact](#impact-5)
    - [Summary](#summary-5)
    - [Access required](#access-required-5)
    - [Relevant secrets](#relevant-secrets-5)
    - [Steps](#steps-5)
  - [Kafka Cluster provisioning latency](#kafka-cluster-provisioning-latency)
    - [Impact](#impact-6)
    - [Summary](#summary-6)
    - [Access required](#access-required-6)
    - [Relevant secrets](#relevant-secrets-6)
    - [Steps](#steps-6)
  - [Kafka Cluster provisioning correctness](#kafka-cluster-provisioning-correctness)
    - [Impact](#impact-7)
    - [Summary](#summary-7)
    - [Access required](#access-required-7)
    - [Relevant secrets](#relevant-secrets-7)
    - [Steps](#steps-7)
  - [Kafka Cluster deletion correctness](#kafka-cluster-deletion-correctness)
    - [Impact](#impact-8)
    - [Summary](#summary-8)
    - [Access required](#access-required-8)
    - [Relevant secrets](#relevant-secrets-8)
    - [Steps](#steps-8)
  - [Kas Fleet Manager Version Mismatch](#kas-fleet-manager-version-mismatch)
    - [Impact](#impact-9)
    - [Summary](#summary-9)
    - [Access required](#access-required-9)
    - [Relevant secrets](#relevant-secrets-9)
    - [Steps](#steps-9)
  - [Kas Fleet Manager Kafkas Stuck in Suspending State](#kas-fleet-manager-kafkas-stuck-in-suspending-status)
    - [Impact](#impact-10)
    - [Summary](#summary-10)
    - [Access required](#access-required-10)
    - [Relevant secrets](#relevant-secrets-10)
    - [Steps](#steps-10)
  - [Kas Fleet Manager Kafkas Stuck in Resuming State](#kas-fleet-manager-kafkas-stuck-in-resuming-status)
    - [Impact](#impact-11)
    - [Summary](#summary-11)
    - [Access required](#access-required-11)
    - [Relevant secrets](#relevant-secrets-11)
    - [Steps](#steps-11)

  - [Escalations](#escalations)

<!-- /TOC -->

---

## Kafka Service Fleet Manager Down

### Impact

No incoming request can be received or processed. 
The existing registered OCD or Kafka jobs will not be able to be processed.  
The OSD or Kafka cluster status will not be retrieved from OCM and updated to Kafka Service Fleet Manager database.

### Summary

Kafka Service Fleet Manager (all of the replicas or pods) are down.

### Access required

- OSD console access to the cluster that runs the Kafka Service Fleet Manager.
- Access to cluster resources: Pods/Deployments/Events

### Relevant secrets

### Steps

- Check Deployments/kas-fleet-manager: check details page to make sure pods are configured and started; make sure pod number is configured to default: 6.
- Check cluster event logs to ensure there is no abnormality in the cluster level that could impact Manager Services API.
  - Search Error/exception events with keywords "Kafka Service Fleet Manager " and with text "image", "deployment" etc.
- Investigate the metrics in Grafana for any possible evidences of the crash.
  - Application: Volume, Latency, Error
      - Stage: https://grafana.stage.devshift.net/d/ynZ7TU3Fv/kas-fleet-manager-slos?orgId=1
      - Production: https://grafana.app-sre.devshift.net/d/ynZ7TU3Fv/kas-fleet-manager-slos?orgId=1&var-datasource=app-sre-prod-04-prometheus
  - CPU, Network, Memory, IO
      - Stage: https://grafana.stage.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=managed-services-stage
      - Production: https://grafana.app-sre.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-namespace=managed-services-production
- Check GlitchTip to investigate possible causes of the crash.
  - Stage: https://glitchtip.devshift.net/managed-services/issues?project=23
  - Production: https://glitchtip.devshift.net/managed-services/issues?project=27
- If necessary, escalate the incident to the corresponding teams.  
  - Check [Escalations](#escalations) section below.

---

## Kafka Service Fleet Manager availability

### Impact

Users are getting numerous amount of errors on API requests.

### Summary

Kafka Service Fleet Manager is not performing normally and is returning an abnormally high number of 5xx Error requests.

### Access required

- OSD Console access to the cluster that runs the Kafka Service Fleet Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

- Investigate the metrics in Grafana for any possible cause of the issue
  - Application: Volume, Latency, Error
      - Stage: https://grafana.stage.devshift.net/d/ynZ7TU3Fv/kas-fleet-manager-slos?orgId=1
      - Production: https://grafana.app-sre.devshift.net/d/ynZ7TU3Fv/kas-fleet-manager-slos?orgId=1&var-datasource=app-sre-prod-04-prometheus
  - CPU, Network, Memory, IO
      - Stage: https://grafana.stage.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=managed-services-stage
      - Production: https://grafana.app-sre.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-namespace=managed-services-production
- If there are container performance issue are identified (e.g.: CPU spike, high Latency etc), increase the number of replicas.
- Check GlitchTip to investigate possible causes of the crash.
  - Stage: https://glitchtip.devshift.net/managed-services/issues?project=23
  - Production: https://glitchtip.devshift.net/managed-services/issues?project=27
- Check Deployments/kas-fleet-manager, check details page to make sure pods are configured and started. Start the pod if none is running (default:6).
- Check if the Kafka Service Fleet Manager pods are running and verify the logs.
    ```
    #example
    oc get pods -n <kas-fleet-manager-stage|kas-fleet-manager-production>

    kas-fleet-manager-58f7b8b649-2mgcp   1/1     Running
    kas-fleet-manager-58f7b8b649-blf5h   1/1     Running
    kas-fleet-manager-58f7b8b649-lzxms   1/1     Running

    # Check the pod logs to investigate possible causes of the issue (e.g. look for any Error/Exception messages)

    oc logs kas-fleet-manager-58f7b8b649-2mgcp  | less
- If necessary, escalate the incident to the corresponding teams.  
  - Check [Escalations](#escalations) section below.

---

## Kafka Service Fleet Manager latency

### Impact

Kafka Service Fleet Manager service is experiencing latency, or has been downgraded.

### Summary

Kafka Service Fleet Manager is not performing normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the Kafka Service Fleet Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

refer to the steps in [Kafka Service Fleet Manager availability](#kafka-service-fleet-manager-availability)

---

## Kafka Service Fleet Manager federate metrics endpoint latency

### Impact

Kafka Service Fleet Manager /metrics/federate endpoint is experiencing high latency, or has been downgraded.

### Summary

Kafka Service Fleet Manager /metrics/federate endpoint is not performing normally and is not able to handle the load within [agreed SLOs](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/managed-services/slos/kas-fleet-manager-api-latency.md)

### Access required

- OSD Console access to the cluster that runs the Kafka Service Fleet Manager .
- Access to cluster resources: Pods/Deployments
- Access to AppSRE Grafana dashboards

### Relevant secrets
N/A

### Steps

- Check the state of the MST Observatorium API service to see if there are any issues indicating the cause of the high latency for the /query and /query_range endpoints
  - Ensure Observatorium is operational. See the following panels in the [AppSRE/Blackbox Exporter Overview](https://grafana.app-sre.devshift.net/d/xtkCtBkiz/blackbox-exporter-overview?orgId=1&refresh=1m) dashboard.
    - For Production, see [https://observatorium-mst.api.openshift.com](https://grafana.app-sre.devshift.net/d/xtkCtBkiz/blackbox-exporter-overview?orgId=1&refresh=1m&var-interval=%24__auto_interval_interval&var-targets=https:%2F%2Fobservatorium-mst.api.openshift.com)
    - For Stage, see [https://observatorium-mst.api.stage.openshift.com](https://grafana.app-sre.devshift.net/d/xtkCtBkiz/blackbox-exporter-overview?orgId=1&refresh=1m&var-interval=$__auto_interval_interval&var-targets=https:%2F%2Fobservatorium-mst.api.stage.openshift.com)
  - Check the Observatorium API dashboards for further information on error rates and duration of requests to the /query and /query_range endpoints.
    - [Production](https://grafana.app-sre.devshift.net/d/Tg-mH0rizaSJDKSADX/api?orgId=1&refresh=1m&var-datasource=telemeter-prod-01-prometheus&var-namespace=telemeter-production&var-handler=All)
    - [Stage](https://grafana.app-sre.devshift.net/d/Tg-mH0rizaSJDKSADX/api?orgId=1&refresh=1m&var-datasource=app-sre-stage-01-prometheus&var-namespace=telemeter-stage&var-handler=All)

    > **IMPORTANT**: If the issue is due to performance issues with Stage MST Observatorium, the alert can be ignored. The Observatorium team does not enforce SLOs in Stage. It is a greatly scaled down deployment and it is not intended to offer production like levels of service or performance. If the alert continues to fire due to continued increase in latency, sync with the MK Control Plane team if it's worth considering increasing the latency target. Note that this should only ever be considered for Stage. 

- Check the token refresher Kubernetes deployments in [Production](https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/k8s/ns/managed-services-production/core~v1~Pod) or [Stage](https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/ns/managed-services-stage/core~v1~Pod). The token refresher pods are prefixed with `token-refresher-`.
  - Ensure that the number of ready pods matches the desired number specified by the parameter `OBSERVATORIUM_TOKEN_REFRESHER_REPLICAS` of the `observatorium-token-refresher` resource template per namespace in the [saas-kas-fleet-manager.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/managed-services/cicd/saas/saas-kas-fleet-manager.yaml).
  - Ensure there are no errors or warnings displayed in the logs of these pods. 

- Check to see if there are any issues with sso.redhat.com. The token refresher communicates with this service to fetch tokens for authenticating requests to Observatorium.
  - Ensure RHSSO is up and communication is possible by checking the following:
    - Check the [RHSSO health endpoint](https://sso.redhat.com/auth/realms/redhat-external/health/v3/health) to see if it is functioning and communication is possible. The `healthy` field should have the value `true`.
    - Check the [sso.redhat.com](https://grafana.app-sre.devshift.net/d/xtkCtBkiz/blackbox-exporter-overview?orgId=1&refresh=1m&var-interval=$__auto_interval_interval&var-targets=https:%2F%2Fsso.redhat.com&var-targets=https:%2F%2Fsso.redhat.com%2Fauth%2Frealms%2Fredhat-external%2F.well-known%2Fopenid-configuration) panels in the AppSRE/Blackbox Exporter Overview Grafana dashboard.
  - Check [status.redhat.com](https://status.redhat.com) to see if there are any announcements or notifications indicating that the service is down or experiencing issues.

  > If the resources above does not give enough information to confirm that the cause of the issue is due to or not due to underlying performance issues with sso.redhat.com, please reach out to the [CIAM team](../../../data/teams/ciam/permissions/ciam-s-client-integration-sre-coreos-slack.yml).

- Otherwise refer to the steps in [Kafka Service Fleet Manager availability](#kafka-service-fleet-manager-availability).

---

## OSD Cluster provisioning latency

### Impact

Kafka Service Fleet Manager service is experiencing issue while provisioning OSD clusters.

### Summary

Kafka Service Fleet Manager is not provisioning OSD cluster normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the Kafka Service Fleet Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

kas-fleet-manager-rds

### Steps
- Check the Dependencies: OCM Cluster Service panel in the Kas Fleet Manager Metrics dasboard - https://grafana.app-sre.devshift.net/d/z1CmsruDn/kas-fleet-manager-metrics?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-consoleurl=https:%2F%2Fconsole-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com
- Check GlitchTip to investigate possible causes of the crash.
  - Stage: https://glitchtip.devshift.net/managed-services/issues?project=23
  - Production: https://glitchtip.devshift.net/managed-services/issues?project=27
- Check if the Kafka Service Fleet Manager pods are running and verify the logs.
    ```
    #example
    oc get pods -n <kas-fleet-manager-stage|kas-fleet-manager-production>

    kas-fleet-manager-58f7b8b649-2mgcp   1/1     Running
    kas-fleet-manager-58f7b8b649-blf5h   1/1     Running
    kas-fleet-manager-58f7b8b649-lzxms   1/1     Running

    # Check the pod logs to investigate possible causes (e.g. look for any Error/Exception messages)

    oc logs kas-fleet-manager-58f7b8b649-2mgcp  | less
    ```
    check the log to ensure the OSD Cluster worker is started, and there is exactly one OSD cluster leader running:
    ```
    oc logs <pod-name> | grep 'Running as the leader.*ClusterManager' 
     
    You should see output similar to the below from any one of the pods: 
    "Running as the leader and starting worker *workers.ClusterManager"
    ``` 
- Check database to investigate if the OSD is created, and there is record in the table:
   ```
   #Look up secret/kas-fleet-manager-rds, login to database.
   psql
   #connect to services API DB
   \c kas-fleet-manager
   ```
   ```
   #Investigate the data in the following table:
   #Table: OSD Clusters
   #Check if there is at least one OSD cluster created and in `ready` status.
   select status,  to_char(now() - updated_at,'HH24:MI') idle_time, count(1) from clusters group by status, to_char(now() - updated_at,'HH24:MI');
   
   #In case there are records with `cluster_accepted`, `cluster_provisioning`, or `cluster_provisioned` status, and the idle_time is over 45 mins, check the log for any abnormality.
   #In case there is record with `failed` status, check the log for the error message.
   ```
- How to handle
    - Error/exception appears related to Manager Services API or no leader worker is running, try to restart the pods.
    - If the cluster request in DB is `cluster_accepted` status, and their idle_time is over 3 mins, try to restart the pods.
    - Error/exception related to OCM, or cluster requests in DB that are not `ready` and not in `cluster_accepted` status, and their idle_time is over 45 mins, check with OCM support to see if they've received OSD cluster request.
    - Otherwise, or if unsure about the reason, escalate the issue to the Control Plane team 

---

## OSD Cluster provisioning correctness

### Impact

Kafka Service Fleet Manager service is experiencing issue while provisioning OSD clusters.

### Summary

Kafka Service Fleet Manager is not provisioning OSD cluster correctly

### Access required

- OSD Console access to the cluster that runs the Kafka Service Fleet Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

refer to the steps in [OSD Cluster provisioning latency](#osd-cluster-provisioning-latency)

---

## Kafka Cluster provisioning latency

### Impact

Kafka Service Fleet Manager service is experiencing issue while provisioning Kafka clusters.

### Summary

Kafka Service Fleet Manager is not able to perform Kafka cluster provisioning normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the Kafka Service Fleet Manager .
- Access to cluster resources: Pods/Deployments/Events

### Relevant secrets

kas-fleet-manager-rds

### Steps

- Check GlitchTip to investigate possible causes of the crash.
  - Stage: https://glitchtip.devshift.net/managed-services/issues?project=23
  - Production: https://glitchtip.devshift.net/managed-services/issues?project=27
- Check if the Kafka Service Fleet Manager pods are running and verify the logs.
    ```
    #example
    oc get pods -n <kas-fleet-manager-stage|kas-fleet-manager-production>

    kas-fleet-manager-58f7b8b649-2mgcp   1/1     Running
    kas-fleet-manager-58f7b8b649-blf5h   1/1     Running
    kas-fleet-manager-58f7b8b649-lzxms   1/1     Running

    # Check the pod logs to investigate possible causes of the latency: look for Error/Exception message.

    oc logs kas-fleet-manager-58f7b8b649-2mgcp  | less
    ```
    check the log to ensure Kafka worker is started: there is exactly one Kafka cluster leader running.
    ```
    oc logs <pod-name> | grep 'Running as the leader.*KafkaManager' 
     
    You should see output similar to the below from either one of the pods: 
    "Running as the leader and starting worker *workers.KafkaManager"
    ``` 
- Check database to investigate if the request is created in the table:
   ```
   #Look up secret/kas-fleet-manager-rds, login to database.
   psql
   #connect to services API DB
   \c kas-fleet-manager
  ```
  ```
   #Investigate the data in the following tables;
   #Table: OSD Clusters
   #Check if there is at least one OSD cluster created and in `ready` status.
   select status,  to_char(now() - updated_at,'HH24:MI') idle_time,count(1) from clusters group by status, to_char(now() - updated_at,'HH24:MI');
   
   #In case there are records with `cluster_accepted`, `cluster_provisioning`, or `cluster_provisioned` status, and the idle_time is over 45 mins, check the log for any abnormality.
   #In case there is record with `failed` status, check the log for any abnormality.
  
   #Table Kafka Request
   #Check if all records are in `ready` status
   select status, to_char(now() - updated_at,'HH24:MI'), count(1) from kafka_requests group by status, to_char(now() - updated_at,'HH24:MI');
  
   #In case there are records with `accepted`, `provisioning`, `resource_creating` status, and the idle_time is over 45 mins, check the log for any abnormality.
   #In case there is record with 'failed' status, check the log for any abnormality.
   ```
- How to handle:
  - Error/exception appears related to Manager Services API or no leader worker is running, try to restart the pods.
  - Error/exception related to OCM, or cluster requests in DB that are not in `ready` status and not in `cluster_accepted`, and their idle_time is over 45 mins, check with OCM support to see if they've received OSD cluster request.
  - Error/exception related to OCM, check with OCM support to see if they've received OSD cluster request.
  - Error/exception related to Kafka, strimzi-operator, or Kafka requests in DB that are not in `ready` and not in `accepted` status, and their idle_time is over 45 mins, check with Data Plane or MK SRE support.
  - Otherwise, or if unsure about the reason, escalate the issue to the Control Plane team.

---

## Kafka Cluster provisioning correctness

### Impact

Kafka Service Fleet Manager service is experiencing issue while provisioning Kafka clusters.

### Summary

Kafka Service Fleet Manager is not able to provision Kafka cluster correctly.

### Access required

- OSD Console access to the cluster that runs the Kafka Service Fleet Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

kas-fleet-manager-rds

### Steps

NOTE: This SLO is currently not active. More details here: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/19100 and https://issues.redhat.com/browse/MGDSTRM-2940.
The alerts are firing because The Kafka instance can go into a failed state during creation but will eventually provision successfully. Our Kafka correctness (create) SLO only makes sense if a Kafka instance stays in a failed state.

Based on the conversation with the Instance Team, it was the intention that a "Failed" state from the fleetshard would be terminal. There are a couple of Strimzi defects currently that cause the fleetshard to report failed during creation when it shouldn't.

https://github.com/strimzi/strimzi-kafka-operator/issues/4855
https://github.com/strimzi/strimzi-kafka-operator/issues/4856
https://github.com/strimzi/strimzi-kafka-operator/issues/4869
https://github.com/strimzi/strimzi-kafka-operator/issues/4872

Until these issues are resolved which will likely take weeks or 1-2 months, we need to turn this alert off in stage and prod. We do so by silencing this alert here:
https://alertmanager.app-sre-prod-04.devshift.net/#/silences/

```
alertname=~KasFleetManagerKafkaCreationSuccess.*
cluster=app-sre-prod-04
environment=production
namespace=managed-services-production
operation=create
prometheus=openshift-customer-monitoring/app-sre
service=kas-fleet-manager
severity=info
infoalertname=~KasFleetManagerKafkaCreationSuccess.*
```

Once these issues have been fixed, this note can be removed, the silenced alert removed, and the steps mentioned below unstriked.
~~refer to the steps [Kafka cluster provisioning latency](#kafka-cluster-provisioning-latency)~~
 
---

## Kafka Cluster deletion correctness

### Impact

Kafka Service Fleet Manager service is experiencing issue while deleting Kafka clusters.

### Summary

Kafka Service Fleet Manager is not able to performing Kafka cluster deletion correctly.

### Access required

- OSD Console access to the cluster that runs the Kafka Service Fleet Manager .
- Access to cluster resources: Pods/Deployments

### Relevant secrets

kas-fleet-manager-rds

### Steps

refer to the steps [Kafka cluster provisioning latency](#kafka-cluster-provisioning-latency)
 
---

## Kas Fleet Manager Version Mismatch

### Impact

Kafka cluster has mismatched version(s) for more than 15 minutes

### Summary

Kafka cluster has a mismatch (actual vs desired) of one or more versions (ibp version, strimzi version, kafka version). This can potentially be happening due to unsuccessful kafka upgrade.

### Access required

- OSD Console access to the cluster that runs the Kas Service Fleet Manager.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

kas-fleet-manager-rds

### Steps

Check the status of relevant kafka (by its id returned in the alert) and see if its failed. Check if there is a reason for failure. Find the relevant kafka in [this dashboard](https://grafana.app-sre.devshift.net/d/viefn9LMz/mk-fleet-links?orgId=1&refresh=1m) to see more information about not matching kafka versions.
If unsure about the reason or how to resolve the issue, refer to [Escalations](#escalations) section below.

---

## Kas Fleet Manager Kafkas Stuck In Suspending State

### Impact

Kafka cluster stuck in suspending state for more than 5 minutes

### Summary

Kafka cluster is stuck in suspending state for more than 5 minutes. The transition from suspending to suspended status should normally be a fast process and if it exceeds 5 minutes, it indicates that there is an issue that requires investigation

### Access required

- OSD Console access to the cluster that runs the Kas Service Fleet Manager.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

Check the relevant kafka(s) (by the id(s) returned in the alert) on the dataplane cluster. Check if there are any errors in the kas-fleetshard operator logs.
If unsure about the reason or how to resolve the issue, refer to [Escalations](#escalations) section below.

---

## Kas Fleet Manager Kafkas Stuck In Resuming State

### Impact

Kafka cluster stuck in resuming state for more than 15 minutes

### Summary

Kafka cluster is stuck in resuming state for more than 15 minutes. The transition from resuming to ready status should normally be similar to kafka request creation time. If it takes much longer, it might indicate that there is an issue that requires investigation.

### Access required

- OSD Console access to the cluster that runs the Kas Service Fleet Manager.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

Check the relevant kafka(s) (by the id(s) returned in the alert) on the dataplane cluster. Check if there are any errors in the kas-fleetshard operator logs, running pods or if any pods are crashlooping.
If unsure about the reason or how to resolve the issue, refer to [Escalations](#escalations) section below.

---

## Escalations

- Error/exception appears related to Manager Services API or no leader worker is running, try to restart the pods.
- Error/exception related to OCM, check with OCM support to see if they've received OSD cluster request.
- Error/exception events found in the OSD cluster level, check with OCM support.
- Error/exception related to Kafka or strimzi-operator, check with Data Plane or MK SRE support.
- Otherwise, or if unsure about the reason, escalate the issue to the Control Plane team 
