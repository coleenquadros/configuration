- [MAS-SSO Multi Availability Zone Pod Distribution](#mas-sso-multi-availability-zone-pod-distribution)
  - [List of alerts](#list-of-alerts)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Alert](#alert)
    - [Monitoring checks](#monitoring-checks)
    - [Make changes to solve alert](#make-changes-to-solve-alert)
  - [Escalation](#escalation)

# MAS-SSO Multi Availability Zone Pod Distribution


## List of alerts

- MasSSOMultiAZPodDistribution
  - **Severity:** warning
  - **Potential Customer Impact:** medium
  
## Overview
MAS SSO is an identity and access management component used by MAS. We use `preferredDuringSchedulingIgnoredDuringExecution` for node affinity settings for the keycloak pods, this is a soft constraint meaning that the scheduler will try to enforce the affinity rules but not guarantee it. We do this to prevent the unavailability of a whole AZ to reduce the amount of replicas. The downside of this approach is that, although highly unlikely, this could in some cases result in all the keycloak pods not evenly distributed in all AZs which is something we want to avoid.
 
## Prerequisites
The mas-sso application information can be found at [mas-sso](https://visual-app-interface.devshift.net/services#/services/mas-sso/app.yml). 

The namespace will be `mas-sso-stage` for staging environment and `mas-sso-production` for the 
production environment. Use the appropriate namespace in the commands.

CLI required to complete this SOP:

- oc
- [podsAz.sh](https://gitlab.cee.redhat.com/service/saas-mas-sso/-/blob/master/scripts/podsAz.sh)

## Alert

### Monitoring checks
- Follow the steps in below link to check observability parts of mas-sso
  
  [Observability checks](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/observability.md)

### Make changes to solve alert

Since the alert is for multi AZ (meaning there are more than one availability zones), we want to make sure an even distribution of the pods as much as we can. The steps below help us to scale down the replica(s) gracefully and let them be rescheduled.

- Run the following command to get the pods and their availability zone information
  
  `
  ./podAz.sh <namespace>
  `

Look for the `keycloak-*` pods information, that should reveal that they are all running in the same availability zone.

- The default minimum replica count is `3`. Scale down one pod at a time. This would depend on whether there are more than two availability zones, and you want the pods to be distributed evenly in each of them.
  
    `
    oc scale statefulset/keycloak --replicas <replicacount - 1>
    `
  
  The below example assumes that the replica count was '3'
    
    `
    oc scale statefulset/keycloak --replicas 2
    `
 
 Since the operator is still running, it would create the new pod and schedule it to a different AZ this time.

- Check if the ready status is 1/1 for the `keycloak-*` pods:  

   `
  oc get pods -n <namespace>
  `

- Check the availability zone information for the `keycloak-*` pods once they are ready
  
    `
    ./podAz.sh <namespace>
    `

Repeat the steps if needed for a maximum of 3 times to get the pod(s) scheduled in more than one availability zone. If the pod(s) fails to distribute, there could be resource issues on one or more of the nodes. This should be investigated.

 
## Escalation
If none of the solutions above helped, please collect all the logs from [gather logs](#gather-logs) and escalate the incident to the corresponding teams.  
  - [Escalation](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/escalation.md)
