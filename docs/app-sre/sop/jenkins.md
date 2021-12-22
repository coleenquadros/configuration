# SOP : Jenkins

<!-- TOC depthTo:2 -->

- [SOP : Jenkins](#sop--jenkins)
- [Alerts](#alerts)
  - [JenkinsHealthCheck](#jenkinshealthcheck)
  - [JenkinsNodeOffline](#jenkinsnodeoffline)
  - [JenkinsExecutorSaturation](#jenkinsexecutorsaturation)
  - [JenkinsJvmMemoryStarvation](#jenkinsjvmmemorystarvation)
  - [JenkinsJvmCPUStarvation](#jenkinsjvmcpustarvation)
- [JenkinsRestart](#Restarting-ci-int)

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

Degraded or even unavailable CI service. PR and MR checks fail,
tenants can't build new images of their applications.

### Summary:

A Jenkins executor is not responding to SSH and thus can't receive
jobs. The integration service is degraded.

### Access required:

See [the general openstack SOP](openstack-ci-int.md).

### Steps:

Reboot or restart all the affected nodes. Identify their names from
the alert, and then use `openstack server reboot --hard $server_name`.

If they don't come back, escalate to PSI. Cut a [Service Now
ticket](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=4c66fd3a1bfbc4d0ebbe43f8bc4bcb6a)
-- yes, really. Mark impact as 3, and urgency as 3 or 2.

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

Unreliable CI service. PR and MR checks fail,
tenants can't build new images of their applications.

### Summary:

Jenkins controller using too much of RAM, after OOM event service might be unreliable
We need to restart the service at least

### Access required:

Admin access to Jenkins controller's Web-UI

### Steps:

- Check if it's really a problem - visit https://ci.int.devshift.net/monitoring?part=heaphisto
Pay attention if bottom line before table shows near to limit usage of RAM

- Check if 'hudson.plugin.git.*' object is present and bigger than a few MegaBytes. 
- Image for reference showing the problem ![before running script](images/ci-int-memory-histogram-before-script-screenshot.png)
- If it's big then need to execute [script](https://plugins.jenkins.io/git/#plugin-content-remove-git-plugin-buildsbybranch-builddata-script)
- Image for reference showing the remediation ![before running script](images/ci-int-memory-histogram-after-script-screenshot.png)

Note: running script also trims down disk usage by removing git revisions' builddata from all builds stored on controller and its backups

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

# Restarting ci-int

Basicaly there are 3 methods of restarting ci-int, depending on severity of problems with service:

## Safe reboot via [Jenkins UI](https://ci.int.devshift.net/safeRestart) - use it only for configuration changes and updating plugins, as it's not a full JVM restart

## Systemd service restart - use it when you can ssh to instance

1. If ci-int UI is responsive, login to UI and hit [Prepare for Shutdown](https://ci.int.devshift.net/prepareShutdown) then wait several minutes for jobs finishing and cancel remaining
2. ssh to instance `ssh ci.int.devshift.net`
3. Restart Jenkins service: `sudo systemctl restart jenkins`

## OpenStack instance reboot

1. Login to [Open Stack](https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard) with your Kerberos credentials
1. Navigate to [Compute -> Instances](https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project/instances/ec831410-8b9f-4d44-97e6-fbfc3d9817f8/)
1. Try to 'Soft Rebot Instance'. If it doesnt help try to 'Hard Reboot Instance' and wait several minutes.
1. If reboot isn't successful add teammates to call or try Stop/Start cycle on instance.

---
