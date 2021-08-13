- [MAS-SSO Availability](#mas-sso-availability)
  - [List of alerts](#list-of-alerts)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
  - [Alert](#alert)
    - [Gather logs](#gather-logs)
    - [Thread Dump](#thread-dump)
    - [Monitoring checks](#monitoring-checks)
    - [Make changes to solve alert](#make-changes-to-solve-alert)
    - [RHSSO](#rhsso)
      - [RHSSO-Operator Restart](#rhsso-operator-restart)
      - [RHSSO Instance Restart](#rhsso-instance-restart)
    - [Postgres Database error](#postgres-database-error)
  - [Escalation](#escalation)

# MAS-SSO Availability


## List of alerts

- MasSSOAvailability5mto1hErrorBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** High
- MasSSOAvailability30mto6hErrorBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** High
- MasSSOAvailability2hto1dErrorBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** Low
- MasSSOAvailability6hto3dErrorBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** Low
  
## Overview
MAS SSO is an identity and access management component used by MAS. The alert fires when keycloak 
fails to fulfil  valid request(s) i.e. responds (or received) with 5xx error codes.
 
## Prerequisites
The mas-sso application information can be found at [mas-sso](https://visual-app-interface.devshift.net/services#/services/mas-sso/app.yml). 

The namespace will be `mas-sso-stage` for staging environment and `mas-sso-production` for the 
production environment. Use the appropriate namespace in the commands.

CLI required to complete this SOP:

- oc

## Alert
### Gather logs

Follow the steps in the below link to gather the necessary logs

[gather logs](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/gather-logs.md)

### Thread Dump

Follow the steps in the below link to gather the thread dumps

[thread-dump](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/thread-dump.md)

### Monitoring checks
- Follow the steps in below link to check observability parts of mas-sso
  
  [Observability checks](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/observability.md)

### Make changes to solve alert

- Run the following command to get the status of keycloak instance for MAS SSO:
  
  `
  oc get pods -n <namespace>
  `

- Check if the Ready status is 1/1 for the following pods:
  
  ```
    keycloak-*
    mas-sso-operator-catalog-*
    rhsso-operator-*
  ```

- If not, follow steps for [rhsso](#rhsso)

### RHSSO
#### RHSSO-Operator Restart
- Follow the steps in the below link to restart the rhsso-operator

  [rhsso-operator restart](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/rhsso-operator-restart.md)

- If the RHSSO Operator is present but the keycloak instance was not deployed 
  please continue with the [next-step](#rhsso-instance-restart)

#### RHSSO Instance Restart
- Follow the steps in the below link to restart the rhsso instance

[rhsso instance restart](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/rhsso-instance-restart.md)

- At this stage, keycloak pods should be up, however, if the alert is still firing, 
  there is most likely an error within the pod

Collect RHSSO Instance logs following the [gathering logs](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/gather-logs.md) and check for any errors. 

### Postgres Database error
MAS SSO requires a RDS  to be provisioned, it might happen that for some reason the RDS is not available or cannot be connected.

- `keycloak-db-secret` secret should be available in the namespace
- Check if the RDS instance is available
- Verify that the DB can be connected using the parameters in the above mentioned secret
- "Enhanced monitoring" can be used in RDS to gather metrics regarding resource usage. 
   Follow the [Using Enhanced Monitoring](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html)
   to enable/disable enhanced monitoring and steps to monitor the resource usage and gather metrics.
  
## Escalation
If none of the solutions above helped, please collect all the logs from [gather logs](#gather-logs) and escalate the incident to the corresponding teams.  
  - [escalation](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/escalation.md)
