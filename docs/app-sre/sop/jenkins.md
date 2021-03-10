# SOP : Jenkins

<!-- TOC depthTo:2 -->

- [SOP : Jenkins](#sop--jenkins)
- [Alerts](#alerts)
  - [JenkinsHealthCheck](#jenkinshealthcheck)
  - [JenkinsNodeOffline](#jenkinsnodeoffline)
  - [JenkinsExecutorSaturation](#jenkinsexecutorsaturation)
  - [JenkinsJvmMemoryStarvation](#jenkinsjvmmemorystarvation)
  - [JenkinsJvmCPUStarvation](#jenkinsjvmcpustarvation)

<!-- /TOC -->

---

# Alerts

## JenkinsHealthCheck

This checks the health score `jenkins_health_check_score` of the jenkins instance, which include the state of the nodes/slaves.

A score below 1 do not necessarily mean there is an impact on the normal operations.

### Impact:

Variable

### Summary:

https://wiki.jenkins.io/display/JENKINS/Metrics+Plugin

### Access required:

Admin access to jenkins is required to troubleshoot this alert

### Steps:

Things to check:
- https://ci.int.devshift.net/metrics/currentUser/healthcheck?pretty=true or https://ci.ext.devshift.net/metrics/currentUser/healthcheck?pretty=true
- Nodes status:
  - Manage Jenkins -> Manage Nodes

- Nodes available disk space
  - Verify /tmp (/) 
  - Verify /var/lib/jenkins
  - Verify /var/lib/docker. Clean with `docker system prune -a`.
  - Duplicity backups cache can fill up in /root/.cache/duplicity
    - Clear old backups with: /backup/backup.sh remove-older-than 3M

---

## JenkinsNodeOffline

### Impact:

TODO

### Summary:

TODO

### Access required:

TODO

### Steps:

TODO

---

## JenkinsExecutorSaturation

### Impact:

TODO

### Summary:

TODO

### Access required:

TODO

### Steps:

TODO

---

## JenkinsJvmMemoryStarvation

### Impact:

TODO

### Summary:

TODO

### Access required:

TODO

### Steps:

TODO

---

## JenkinsJvmCPUStarvation

### Impact:

TODO

### Summary:

TODO

### Access required:

TODO

### Steps:

TODO

---
