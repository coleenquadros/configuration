# SOP : Managed Services API

<!-- TOC depthTo:2 -->

- [SOP : Managed Services API](#sop--managed-services-api)
  - [Managed Services API Down](#managed-services-api-down)
  - [Managed Services API availability](#managed-services-api-availability)
  - [Managed Services API latency](#managed-services-api-latency)
  - [OSD Cluster provisioning latency](#osd-cluster-provisioning-latency)
  - [OSD Cluster provisioning correctness](#osd-cluster-provisioning-correctness)
  - [Kafka Cluster provisioning latency](#kafka-cluster-provisioning-latency)
  - [Kafka Cluster provisioning correctness](#kafka-cluster-provisioning-correctness)
  - [Kafka Cluster deletion correctness](#kafka-cluster-deletion-correctness)
  - [Escalations](#escalations)
  - [Contacts](#contacts)

<!-- /TOC -->

---

## Managed Services API Down

### Impact

No incoming request can be received or processed. 
The existing registered OCD or Kafka jobs will not be able to be processed.  
The OSD or Kafka cluster status will not be retrieved from OCM and updated to Managed Services API database.

### Summary

Managed Services API (all of the replicas or pods) are down.

### Access required

- OSD console access to the cluster that runs the Managed Services API.
- Access to cluster resources: Pods/Deployments/Events

### Relevant secrets

### Steps

- Check Deployments/managed-services-api: check details page to make sure pods are configured and started; make sure pod number is configured to default: 3.
- Check cluster event logs to ensure there is no abnormality in the cluster level that could impact Manager Services API.
  - Search Error/exception events with keywords "Managed Services API" and with text "image", "deployment" etc.
- Investigate the metrics in Grafana for any possible evidences of the crash.
  - Application: Volume, Latency, Error
      - Stage: https://grafana.stage.devshift.net/d/Tbw1EgoMz/managed-services-api-slos?orgId=1
      - Production: TODO
  - CPU, Network, Memory, IO
      - Stage: TODO
      - Production: TODO
- Check Sentry to investigate possible causes of the crash.  
  - Stage: https://sentry.stage.devshift.net
  - Production: https://sentry.devshift.net
- If necessary, escalate the incident to the corresponding teams.  
  - Check [Escalations](#escalations) section below.

---

## Managed Services API availability

### Impact

Possible SLO breach, for users are getting numerous amount of errors on API requests.

### Summary

Managed Services API is not performing normally and is returning an abnormally high number of 5xx Error requests.

### Access required

- OSD Console access to the cluster that runs the Managed Services API.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

- Investigate the metrics in Grafana for any possible cause of the issue
  - Application: Volume, Latency, Error
      - Stage: https://grafana.stage.devshift.net/d/Tbw1EgoMz/managed-services-api-slos?orgId=1
      - Production: TODO
  - CPU, Network, Memory, IO
      - Stage: TODO
      - Production: TODO
- If there are container performance issue are identified (e.g.: CPU spike, high Latency etc), increase the number of replicas.
  - (TODO enhancement is needed for Service API to scale the background workers.)
- Check Sentry to investigate possible causes.
  - Stage: https://sentry.stage.devshift.net
  - Production: https://sentry.devshift.net
- Check Deployments/managed-services-api, check details page to make sure pods are configured and started. Start the pod if none is running (default:3).
- Check if the Managed Services API pods are running and verify the logs.
    ```
    #example
    oc get pods -n <managed-services-stage|managed-services-production>

    managed-services-api-58f7b8b649-2mgcp   1/1     Running
    managed-services-api-58f7b8b649-blf5h   1/1     Running
    managed-services-api-58f7b8b649-lzxms   1/1     Running

    # Check the pod logs to investigate possible causes of the issue (e.g. look for any Error/Exception messages)

    oc logs managed-services-api-58f7b8b649-2mgcp  | less
- If necessary, escalate the incident to the corresponding teams.  
  - Check [Escalations](#escalations) section below.

---

## Managed Services API latency

### Impact

Managed Services API service is experiencing latency, or has been downgraded.

### Summary

Managed Services API is not performing normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the Managed Services API.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

refer to the steps in [Managed Services API availability](#managed-services-api-availability)

---

## OSD Cluster provisioning latency

### Impact

Managed Services API service is experiencing issue while provisioning OSD clusters.

### Summary

Managed Services API is not provisioning OSD cluster normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the Managed Services API.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

managed-services-api-rds

### Steps

- Check Sentry to investigate possible causes.
  - Stage: https://sentry.stage.devshift.net
  - Production: https://sentry.devshift.net
- Check if the Managed Services API pods are running and verify the logs.
    ```
    #example
    oc get pods -n <managed-services-stage|managed-services-production>

    managed-services-api-58f7b8b649-2mgcp   1/1     Running
    managed-services-api-58f7b8b649-blf5h   1/1     Running
    managed-services-api-58f7b8b649-lzxms   1/1     Running

    # Check the pod logs to investigate possible causes (e.g. look for any Error/Exception messages)

    oc logs managed-services-api-58f7b8b649-2mgcp  | less
    ```
    check the log to ensure the OSD Cluster worker is started, and there is exactly one OSD cluster leader running:
    ```
    oc logs <pod-name> | grep 'Running as the leader.*ClusterManager' 
     
    You should see output similar to the below from any one of the pods: 
    "Running as the leader and starting worker *workers.ClusterManager"
    ``` 
- Check database to investigate if the OSD is created, and there is record in the table:
   ```
   #Look up secret/managed-services-api-rds, login to database.
   psql
   #connect to services API DB
   \c managed-services-api
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

Managed Services API service is experiencing issue while provisioning OSD clusters.

### Summary

Managed Services API is not provisioning OSD cluster correctly

### Access required

- OSD Console access to the cluster that runs the Managed Services API.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

### Steps

refer to the steps in [OSD Cluster provisioning latency](#osd-cluster-provisioning-latency)

---

## Kafka Cluster provisioning latency

### Impact

Managed Services API service is experiencing issue while provisioning Kafka clusters.

### Summary

Managed Services API is not able to perform Kafka cluster provisioning normally and is not able to handle the load.

### Access required

- OSD Console access to the cluster that runs the Managed Services API.
- Access to cluster resources: Pods/Deployments/Events

### Relevant secrets

managed-services-api-rds

### Steps

- Check Sentry to investigate possible causes.
  - Stage: https://sentry.stage.devshift.net
  - Production: https://sentry.devshift.net
- Check if the Managed Services API pods are running and verify the logs.
    ```
    #example
    oc get pods -n <managed-services-stage|managed-services-production>

    managed-services-api-58f7b8b649-2mgcp   1/1     Running
    managed-services-api-58f7b8b649-blf5h   1/1     Running
    managed-services-api-58f7b8b649-lzxms   1/1     Running

    # Check the pod logs to investigate possible causes of the latency: look for Error/Exception message.

    oc logs managed-services-api-58f7b8b649-2mgcp  | less
    ```
    check the log to ensure Kafka worker is started: there is exactly one Kafka cluster leader running.
    ```
    oc logs <pod-name> | grep 'Running as the leader.*KafkaManager' 
     
    You should see output similar to the below from either one of the pods: 
    "Running as the leader and starting worker *workers.KafkaManager"
    ``` 
- Check database to investigate if the request is created in the table:
   ```
   #Look up secret/managed-services-api-rds, login to database.
   psql
   #connect to services API DB
   \c managed-services-api
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

Managed Services API service is experiencing issue while provisioning Kafka clusters.

### Summary

Managed Services API is not able to provision Kafka cluster correctly.

### Access required

- OSD Console access to the cluster that runs the Managed Services API.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

managed-services-api-rds

### Steps

refer to the steps [Kafka cluster provisioning latency](#kafka-cluster-provisioning-latency)
 
---

## Kafka Cluster deletion correctness

### Impact

Managed Services API service is experiencing issue while deleting Kafka clusters.

### Summary

Managed Services API is not able to performing Kafka cluster deletion correctly.

### Access required

- OSD Console access to the cluster that runs the Managed Services API.
- Access to cluster resources: Pods/Deployments

### Relevant secrets

managed-services-api-rds

### Steps

refer to the steps [Kafka cluster provisioning latency](#kafka-cluster-provisioning-latency)
 
---

## Escalations

- Error/exception appears related to Manager Services API or no leader worker is running, try to restart the pods.
- Error/exception related to OCM, check with OCM support to see if they've received OSD cluster request.
- Error/exception events found in the OSD cluster level, check with OCM support.
- Error/exception related to Kafka or strimzi-operator, check with Data Plane or MK SRE support.
- Otherwise, or if unsure about the reason, escalate the issue to the Control Plane team 

## Contacts

TODO: Slack/emails etc
