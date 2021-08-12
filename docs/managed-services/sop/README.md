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
  - [OSD Cluster provisioning latency](#osd-cluster-provisioning-latency)
    - [Impact](#impact-3)
    - [Summary](#summary-3)
    - [Access required](#access-required-3)
    - [Relevant secrets](#relevant-secrets-3)
    - [Steps](#steps-3)
  - [OSD Cluster provisioning correctness](#osd-cluster-provisioning-correctness)
    - [Impact](#impact-4)
    - [Summary](#summary-4)
    - [Access required](#access-required-4)
    - [Relevant secrets](#relevant-secrets-4)
    - [Steps](#steps-4)
  - [Kafka Cluster provisioning latency](#kafka-cluster-provisioning-latency)
    - [Impact](#impact-5)
    - [Summary](#summary-5)
    - [Access required](#access-required-5)
    - [Relevant secrets](#relevant-secrets-5)
    - [Steps](#steps-5)
  - [Kafka Cluster provisioning correctness](#kafka-cluster-provisioning-correctness)
    - [Impact](#impact-6)
    - [Summary](#summary-6)
    - [Access required](#access-required-6)
    - [Relevant secrets](#relevant-secrets-6)
    - [Steps](#steps-6)
  - [Kafka Cluster deletion correctness](#kafka-cluster-deletion-correctness)
    - [Impact](#impact-7)
    - [Summary](#summary-7)
    - [Access required](#access-required-7)
    - [Relevant secrets](#relevant-secrets-7)
    - [Steps](#steps-7)
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
      - Stage: https://grafana.stage.devshift.net/d/Tbw1EgoMz/kas-fleet-manager-slos?orgId=1
      - Production: https://grafana.app-sre.devshift.net/d/Tbw1EgoMz/kas-fleet-manager-slos?orgId=1&var-datasource=app-sre-prod-04-prometheus
  - CPU, Network, Memory, IO
      - Stage: https://grafana.stage.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=managed-services-stage
      - Production: https://grafana.app-sre.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-namespace=managed-services-production
- Check Sentry to investigate possible causes of the crash.  
  - Stage: https://sentry.stage.devshift.net/sentry/managed-services-stage/
  - Production: https://sentry.devshift.net/sentry/managed-services-prod/
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
      - Stage: https://grafana.stage.devshift.net/d/Tbw1EgoMz/kas-fleet-manager-slos?orgId=1
      - Production: https://grafana.app-sre.devshift.net/d/Tbw1EgoMz/kas-fleet-manager-slos?orgId=1&var-datasource=app-sre-prod-04-prometheus
  - CPU, Network, Memory, IO
      - Stage: https://grafana.stage.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-stage-01-prometheus&var-namespace=managed-services-stage
      - Production: https://grafana.app-sre.devshift.net/d/osdv4-tenant-compute-resources-ns/osdv4-tenant-compute-resources-namespace?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-namespace=managed-services-production
- If there are container performance issue are identified (e.g.: CPU spike, high Latency etc), increase the number of replicas.
- Check Sentry to investigate possible causes of the crash.  
  - Stage: https://sentry.stage.devshift.net/sentry/managed-services-stage/
  - Production: https://sentry.devshift.net/sentry/managed-services-prod/
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
- Check the Dependencies: OCM Cluster Service panel in the Kas Fleet Manager Metrics dasboard - https://grafana.app-sre.devshift.net/d/WLBv_KuMz/kas-fleet-manager-metrics?orgId=1&var-datasource=app-sre-prod-04-prometheus&var-consoleurl=https:%2F%2Fconsole-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com
- Check Sentry to investigate possible causes.
  - Stage: https://sentry.stage.devshift.net/sentry/managed-services-stage/
  - Production: https://sentry.devshift.net/sentry/managed-services-prod/
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

- Check Sentry to investigate possible causes.
  - Stage: https://sentry.stage.devshift.net/sentry/managed-services-stage/
  - Production: https://sentry.devshift.net/sentry/managed-services-prod/
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

## Escalations

- Error/exception appears related to Manager Services API or no leader worker is running, try to restart the pods.
- Error/exception related to OCM, check with OCM support to see if they've received OSD cluster request.
- Error/exception events found in the OSD cluster level, check with OCM support.
- Error/exception related to Kafka or strimzi-operator, check with Data Plane or MK SRE support.
- Otherwise, or if unsure about the reason, escalate the issue to the Control Plane team 
