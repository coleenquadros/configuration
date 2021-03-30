# SOP : Job Queue Service

<!-- TOC depthTo:2 -->

- [SOP : UHC](#sop--uhc)
    - [AccountManagerDown](#job-queue-down)
    - [JobQueue5xxErrorsHigh](#job-queue-5xx)
    - [JobQueue4xxErrorsHigh](#job-queue-4xx)
    - [JobQueueLatency](#job-queue-latency)
    - [OCM Job Queue Dependencies](#job-queue-dependencies)
    - [Escalations](#escalations)
  
TODO: https://issues.redhat.com/browse/SDB-1936

<!-- /TOC -->

---

## Job Queue Down

### Impact:

No clients of the JQS will be able to pull jobs that need completing. 
These jobs will continue to exist in the queue for up to 4 days. 
This outage should not prevent any jobs from completing, only delay their completion. 
This outage will, however, prevent new jobs from being created.

### Summary:

Job Queue Service is down

### Access required:

- Console access to the cluster that runs job-queue (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/job-queue` logs to determine why pods are down.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Job Queue 5xx

### Impact:

Jobs will not be able to be created or executed.

### Summary:

Job Queue is returning an abnormally high number of 5xx Error requests

### Access required:

- Console access to the cluster that runs job-queue (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/job-queue` logs to determine why errors are occurring.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Job Queue 4xx

### Impact:

Jobs will not be able to be created or executed.

### Summary:

Job Queue is returning an abnormally high number of 4xx Error requests

### Access required:

- Console access to the cluster that runs job-queue (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/job-queue` logs to determine why errors are occurring.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Job Queue Latency

### Impact:

Jobs creation and execution will be delayed.

### Summary:

Job Queue requests are taking an unusually long period of time.

### Access required:

- Console access to the cluster that runs job-queue (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/job-queue` logs to determine why errors are occurring.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Job Queue Dependencies

### Summary:

One or more dependency services is experiencing issues or has been downgraded.

### SQS
- Creating jobs
- Executing jobs

### OCM - UHC Account Manager
- Authorization

### Access required:
- Console access to the cluster that runs job-queue (app-sre)
- AWS SQS access  
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:
- Contact SRE team for a service outage.
- Contact Service Delivery B team otherwise, and inform the greater service delivery team.

---

## Escalations

### Contacts:

- Abhishek Gupta (agupta@redhat.com)
- Timothy Williams (tiwillia@redhat.com)
- Brandon Vulaj (bvulaj@redhat.com)
