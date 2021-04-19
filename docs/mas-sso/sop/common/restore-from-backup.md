## Restoring MAS SSO from database backup

This guide contains a set steps required to restore a severely damaged MAS SSO from a database backup.

Typically, when a severe MAS SSO damage occurs, the following alerts will be firing:
- MasSSOAvailabilityRHSSOPodsDown
- MasSSOAvailabilityRHSSOOperatorPodDown
- MasSSOAvailability*ErrorBudgetBurn

Usually, when severe service damage occurs, RHSSO Pods are either being down or report errors and are not
able to operate normally.

In order to recover the service, the AppSRE Team member with cluster admin permissions will be required.

Depending on the failure scenario, getting the service up and running may require some (or all) of the steps below:
- [Disable the Operator](#disable-the-operator)
- [Restore the database](#restore-the-database)
- [Run the SaaS deployment](#run-the-saas-deployment)

## Disable the Operator

When replacing the database, it is important to disable the Operator to prevent RHSSO Pods from trying to read and write data to the store.

In order to disable the Operator, please remove the MAS SSO subscription:

`
oc delete subscription mas-sso-operator -n <namespace>
`

## Scale MAS SSO StatefulSet to 0

Depending on the scenario, some misconfigured RHSSO Pods might be trying to write something to the database.
In order to prevent this, scale `keycloak` StatefulSet to 0:

`
oc scale statefulset/keycloak --replicas 0
`

## Restore the database

Depending on a failure scenario, it might be necessary to restore MAS SSO database from a backup.

The following links might be useful to fulfill this task:
- [Amazon SOPs from App-interface repo](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/aws)
- [Restoring a DB instance to a specified time - AWS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html)

The MAS SSO RDS name is `mas-sso-production` and is defined in the [namespaces files](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/mas-sso/namespaces)

It is highly advised to pick the last properly working copy of the database. Such a copy could be identified
by checking when was the last time when all the alerts were not firing. In some cases, such a date could be picked
arbitrary, e.g. a copy before an AWS region failure or OSD cluster failure. 

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
