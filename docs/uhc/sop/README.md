# SOP : UHC

<!-- TOC depthTo:2 -->

- [SOP : UHC](#sop--uhc)
    - [AccountManagerDown](#account-manager-down)
    - [UHCAccountManager5xxErrorsHigh](#account-manager-5xx)
    - [UHCAccountManager4xxErrorsHigh](#account-manager-4xx)
    - [UHCAccountManagerBannedUsersHigh](#account-manager-banned-users)
    - [Escalations](#escalations)

<!-- /TOC -->

---

## Account Manager Down

### Impact:

New clusters will be unable to fetch an authorization token.
Users of the UHC portal UI may be receiving unexpected errors.
Consumers of the /api/accounts_mgmt/ API will be receiving timeout errors.
Clusters service will be unable to determine authorization.

### Summary:

Account manager API is down

### Access required:

- Console access to the cluster that runs account-manager (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Relevant secrets:
- secrets/uhc-acct-mngr

### Steps:

- Check `deployment/uhc-acct-mngr` logs to determine why pods are down.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Account Manager 5xx

### Impact:

New clusters will be unable to fetch an authorization token.
Users of the UHC portal UI may be receiving unexpected errors.
Clusters service will be unable to determine authorization.

### Summary:

Account manager API is returning an abnormally high number of 5xx Error requests

### Access required:

- Console access to the cluster that runs account-manager (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Relevant secrets:
- secrets/uhc-acct-mngr

### Steps:

- Check `deployment/uhc-acct-mngr` logs to determine why errors are occurring.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Account Manager 4xx

### Impact:

New clusters will be unable to fetch an authorization token.
Users of the UHC portal UI may be receiving unexpected errors.
Clusters service will be unable to determine authorization.

### Summary:

Account manager API is returning an abnormally high number of 4xx Error requests

### Access required:

- Console access to the cluster that runs account-manager (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Relevant secrets:
- secrets/uhc-acct-mngr

### Steps:

- Check `deployment/uhc-acct-mngr` logs to determine why errors are occurring.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Account Manager Banned Users

### Impact:

There is an abnormal increase of banned users during the past 24 hours.
All banned users see unauthorizated errors and are unable to use UHC portal.

### Summary:

The number of banned users has abnormally increased during the last 24 hours.

### Access required:

- Console access to the cluster that runs account-manager (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Relevant secrets:
- secrets/uhc-acct-mngr

### Steps:

- Contact Service Delivery B team, inform the greater service delivery team.

---

## Escalations
We want a link to app-interface here, but okay to just contacts here for now.

### Contacts:

Abhishek Gupta (agupta@redhat.com)
Timothy Williams (tiwillia@redhat.com)
Mark Turansky (mturansk@redhat.com)
Eric Himmelreich ehimmelr@redhat.com

---

## Clusters Service Down

### Impact:

UHC users will not be able to fetch clusters as well as create new clusters.
Users of api.openshift.com will also not be able to perform any CRUD operations on their clusters.

### Summary:

Clusters service API is down

### Access required:

- Console access to the cluster that runs clusters-service (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Relevant secrets:
- secrets/app-interface/app-sre/uhc-production/clusters-service
- secrets/app-interface/app-sre/uhc-stage/clusters-service

### Steps:

- Check `deployment/clusters-service` logs to determine why pods are down.
- Contact Service Development A team on #service-delivery, sd-mp-devel@redhat.com.
- Inform the greater service delivery team.

---

## Clusters Service 5xx

### Impact:

UHC users will not be able to fetch clusters as well as create new clusters.
Users of api.openshift.com will also not be able to perform any CRUD operations on their clusters.
Users of the UHC portal UI may be receiving unexpected errors.

### Summary:

Clusters service API is returning an abnormally high number of 5xx Error requests

### Access required:

- Console access to the cluster that runs clusters-service (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Relevant secrets:
- secrets/app-interface/app-sre/uhc-production/clusters-service
- secrets/app-interface/app-sre/uhc-stage/clusters-service

### Steps:

- Check `deployment/clusters-service` logs to determine why errors are occurring.
- Contact Service Development A team on #service-delivery, sd-mp-devel@redhat.com.
- Inform the greater service delivery team.

---

## Gateway Down

### Impact:

UHC users will not be able to access any service (including the accounts
management service, the clusters management service and the upgrades information
service) and therefore they will not be able to use the UI or the API.

### Summary:

Gateway is down

### Access required:

- Console access to the cluster that runs the gateway (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/gateway-server` logs to determine why pods are down.
- Contact Service Development A team on #service-delivery, sd-mp-devel@redhat.com.
- Inform the greater service delivery team.

---

## Controller Manager Down

### Impact:

Deployment of new clusters and any other activity that requires processing
events from _Hive_ or from the AWS account operator will not progress.

### Summary:

Controller manager is down.

### Access required:

- Console access to the cluster that runs the clusters service (`app-sre` and
  `app-sre-stage`).

- Console access to the cluster that runs the _Hive_ and the AWS account
  operator (`hive-state` and `hive-production`).

### Steps:

- Check `deployment/clusters-service` logs to determine why the controller
  manager is down.

- Check that the configuration maps used for the OCM leader election
  mechanism are being updated regularly. These configuration maps are
  inside the `uhc-leadership` namespace of the `hive-production` or
  `hive-stage` clusters. If the controller managers are running correctly
  they should be updating these configuration maps every two seconds
  approximately.

  The relevant data is inside the `control-plane.alpha.kubernetes.io/leader`
  annotation of the configuration map. For example, to display the data for
  the leader election process used to interact with _Hive_:

    ```
    $ oc get configmap production -n uhc-leadership -o json \
    jq -r '.metadata.annotations["control-plane.alpha.kubernetes.io/leader"]' |
    jq
    ```

  That will display something like this:

    ```json
    {
      "holderIdentity": "clusters-service-f5bf5dc8c-jdsnx_2feca4f4-...",
      "leaseDurationSeconds": 15,
      "acquireTime": "2019-10-11T13:43:40Z",
      "renewTime": "2019-10-15T10:19:55Z",
      "leaderTransitions": 0
    }
    ```

  The `renewTime` indicates when the last time that the leader renewed
  its lease. That should be updated every two seconds approximately. If
  it isn't then most probably the leader election process is failing.

  The OCM clusters service will automatically restart this leader election
  mechanism when it fails, after waiting a minute. But this will repeatedly
  fail if communications are lost or if permissions aren't correct.

- Check the communications between the between the cluster where the OCM
  services run (the `app-sre` or `app-sre-stage` cluster) and the cluster
  where the _Hive_ and AWS account operators run (the `hive-production` or
  `hive-stage` cluster).

- Check that the service account used by the OCM clusters service to talk
  to the _Hive_ and AWS account operator exists and has the required
  permissions. The complete _kubeconfig_ files containing the details
  of these service accounts are stored in the `hive.kubeconfig` and
  `aws_account_operator.kubeconfig` keys of the `clusters-service`
  secret.
  
  Note:
  Soon this will be changed - both hive and AWS account operator configs will be stored
  in `external_cluster_services.config`. This file contains the complete _kubeconfig_ of
  those services.

  The OCM clusters service needs full permissions on configuration maps
  and permissions to create events inside the `uhc-leaderhsip` namespace.

- Contact Service Development A team on #service-delivery, sd-mp-devel@redhat.com.

- Inform the greater service delivery team.

## Escalations

We want a link to app-interface here, but okay to just contacts here for now.

### Contacts:

Juan Hernandez (jhernand@redhat.com)
Oved Ourfali (oourfali@redhat.com)
Nimrod Shneor (nshneor@redhat.com)
