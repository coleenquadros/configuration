## Restoring MAS SSO from database backup

This guide contains a set steps required to restore a severely damaged MAS SSO from a database backup.

This SOP should only be run after escalation to the engineering team and the engineering team recommend this as a solution.
Part of the esacaltion should involve helping to identify which backup to restore from. 


- [Disable the Operator](#disable-the-operator)
- [Restore the database](#restore-the-database)
- [Run the SaaS deployment](#run-the-saas-deployment)
- [Scale MAS SSO StatefulSet to 0](#scale-mas-sso-statefulset-to-0)

## Disable the Operator

When replacing the database, it is important to disable the Operator to prevent it from keeping the RHSSO pods running and attempting writes to the database and also to prevent it from interacting with the MAS SSO API. 

In order to disable the Operator, please remove the MAS SSO subscription:

`
oc delete subscription mas-sso-operator -n <namespace>
`

## Scale MAS SSO StatefulSet to 0

To avoid MAS SSO attempting to write new data to the database scale the stateful set to 0

`
oc scale statefulset/keycloak --replicas 0
`

## Restore the database

This should be restored using the APP SRE standard procedure for restoring an AWS RDS database.
The MAS SSO RDS name is `mas-sso-production` and is defined in the [namespaces files](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/mas-sso/namespaces)

It is highly advised to pick the last properly working copy of the database. Such a copy could be identified
by checking when was the last time when all the alerts were not firing. In some cases, such a date could be picked
arbitrary, e.g. a copy before an AWS region failure or OSD cluster failure. This should be clarified with engineering during the escalation process. 

## Run the SaaS deployment

Once the database is restored and healthy, re-synchronize all the resources by calling the SaaS deployment job.
The Jenkins jobs might be found here
- [Staging](https://ci.int.devshift.net/view/mas-sso/job/openshift-saas-deploy-saas-deployment-mas-sso-osd-stage/)
- [Production](https://ci.int.devshift.net/view/mas-sso/job/openshift-saas-deploy-saas-deployment-mas-sso-osd-production/)

Once the jobs are done, wait 2-3 minutes till everything settles down. Then, make sure everything is running:

  `
  oc get pods -n <namespace>
  `

  Depending upon the replicas (default is 3) , the keycloak-<id> pods should be running.

    ```
    NAME                                                              READY   STATUS     
    keycloak-0                                                        1/1     Running    
    keycloak-1                                                        1/1     Running    
    keycloak-2                                                        1/1     Running    
    ```
