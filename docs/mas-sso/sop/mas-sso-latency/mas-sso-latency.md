- [MAS-SSO Latency](#mas-sso-latency)
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
  - [Escalation](#escalation)
# MAS-SSO Latency


## List of alerts

- MasSSOLatency5mto1hrBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** High
* MasSSOLatency30to6hrBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** High
- MasSSOLatency2hto1dBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** Low
- MasSSOLatency6hto3dBudgetBurn
  - **Severity:** critical
  - **Potential Customer Impact:** Low

## Overview
MAS SSO is an identity and access management component used by MAS.
The alert fires when MAS SSO service experiencing latency.

## Prerequisites
The mas-sso application information can be found at [mas-sso](https://visual-app-interface.devshift.net/services#/services/mas-sso/app.yml). 

The namespace will be `mas-sso-stage` for staging environment and `mas-sso-production` for the production environment. Use the appropriate namespace in the commands.

CLI required to complete this SOP:

- oc

##  Alert
### Gather logs
Follow the steps in the below link to gather the necessary logs

[gathering logs](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/gather-logs.md)

### Thread Dump

Follow the steps in the below link to gather the thread dumps

[thread-dump](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/thread-dump.md)

### Monitoring checks
- Follow the steps in below link to check observability parts of mas-sso
  
  [Observability checks](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/observability.md)

- Check RDS for latency (query latency, connection timeouts and other metrics). This would require the following:
  - Enable Postgresql logs (included query logging as well) using the steps mentioned in this [link](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.PostgreSQL.html). This should log the queries and using the `log_min_duration_statement` parameter we can verify the queries that experience more latency.
  - An alternative method for query latency: (once we know the query from the logs)
    - A PostgresSQL available POD to connect to the RDS instance
    ```
    postgres=> \timing
    Timing is on.
    postgres=> <Execute the suspected query>;
    ```
  - For network latency measurements follow standard operations such as ping or traceroute to determine the same.
- 


### Make changes to solve alert

-  Check if the desired number of keycloak instances (replicas) are running.

    `
    oc get pods -n <namespace>
    `

- Check for `keyclaok-*` pods status should be `running.
  If the desired number of instances are not running analyse logs.

- If there are container performance issues identified in the keycloak pods  (e.g.: CPU spike, high Latency etc), increase the number of replicas by a factor of 2 (ensure that we have a odd number of replicas). The default number of replicas is 3. The CPU and memory request and limits can be modified via the SaaS deployment file. 
  

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

- If not, follow steps for [rhsso](#rhsso), if the pods are up and running, it could be that there is a large volume of requests
  and the `haproxy.router.openshift.io/pod-concurrent-connections` parameter in the [route](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/services/mas-sso/mas-sso.route.yaml) needs to be increased. 
  

### RHSSO
#### RHSSO-Operator Restart

- Follow the steps in the below link to restart the rhsso-operator

  [rhsso-operator restart](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/rhsso-operator-restart.md)

- If the RHSSO Operator is present but the keycloak instance was not deployed please continue with the 
  [next-step](#rhsso-instance-restart)

#### RHSSO Instance Restart
- Follow the steps in the below link to restart the rhsso instance

[rhsso instance restart](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/rhsso-instance-restart.md)

- At this stage, keycloak pods should be up, however, if the alert is still firing, there is most likely an error within the pod

- Collect RHSSO Instance logs following the [gathering logs](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/gather-logs.md)   and check for any errors. 

## Escalation
If none of the solutions above helped, please collect all the logs from [gather logs](#gather-logs) and escalate the incident to the corresponding teams.  
  - [escalation](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/mas-sso/sop/common/escalation.md)
