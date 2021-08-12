# SOP : UHC / AMS / OCM

<!-- TOC depthTo:2 -->

- [SOP : UHC](#sop--uhc)
    - [Things to verify is Hive is not working](#things-to-verify-if-hive-is-not-working)  
    - [AccountManagerDown](#account-manager-down)
    - [UHCAccountManager5xxErrorsHigh](#account-manager-5xx)
    - [UHCAccountManager4xxErrorsHigh](#account-manager-4xx)
    - [UHCAccountManagerBannedUsersHigh](#account-manager-banned-users)
    - [OCM Account Manager Dependencies](#account-manager-dependencies)
    - [Escalations](#escalations)

<!-- /TOC -->

---

## Things to verify if hive is not working

Below is a list of things to verify in case Hive is misbehaving or not working

### ServiceAccounts

OCM uses serviceaccounts to communicate with the hive clusters. These serviceaccounts may get rotated for some reasons (olm bug, etc) and so they have to be updated

The secret `external_cluster_services.config` (https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre-stage/uhc-stage/clusters-service) must contain a valid kubeconfig as well as serviceaccount token matching the ones on the cluster

- aws-account-operator-client (for AWS account creation)
- hive-frontend (for frontend communication)

The secret is automatically updated by a combination of the openshift-resources and openshift-serviceaccount-tokens integrations:
- [uhc-integration](/resources/hive-integration/uhc-integration/clusters-service.secret.yaml)
- [uhc-stage](/resources/app-sre-stage/uhc-stage/clusters-service.secret.yaml)
- [uhc-production](/resources/app-sre/uhc-production/clusters-service.secret.yaml)

### hive-admission

hive-admission uses the API to create ClusterProvision objects. Sometimes the hive-admission ServiceAccount token is rotated and the pods don't pick up the new token automatically. Deleting the pods will ensure they are re-created with the proper token mount

`oc -n hive delete pods -l app=hiveadmission --grace-period=0 --force`

### hive-operator CSV

hive-operator CSV may get in a bad (Pending) state. This is due to an OLM bug. The following are observed:
- hive-operator deployment is absent
- hive-operator pods are gone
- hive-operator serviceaccount is absent

The above indicate that we have likely hit a known bug in OLM / kube GC. The workaround is to get a copy of the Subscription and then delete the CSV and re-create the Subscription 

```
# Observe current state
oc -n hive get subscription,installplan,csv

# Get copy of subscription
oc -n hive get subscription hive-operator -oyaml --export > /tmp/hive-operator.subscription.yaml

# Delete csv and subscription
oc -n hive delete csv hive-operator.vx.y.z-sha
oc -n hive delete subscription hive-operator

# Observe subscription, csv and installplans have been deleted
oc -n hive get subscription,installplan,csv

# Re-create subscription
oc -n hive create -f /tmp/hive-operator.subscription.yaml

# Observe subscription, csv and installplans have been re-created. Deployment and pods should also be created
oc -n hive get subscription,installplan,csv,deployment,pods
```

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

## Account Manager Dependencies

### Summary:

One or more dependency services is experiencing issues or has been downgraded.

### Quay.io
- Creating a robot user
- Adding a robot user to a team
- Removing a robot user from a team

### RHIT
- Creating Service Accounts
- Retrieving a Service Account
- Removing a Service Account
- Creating Auto Entitlements
- Find OCP Subscriptions of an Account
- Retrieving User's Information
- Retrieving User's Status of Acknowledgement of Terms and Conditions

### Hydra
- Creating support cases
- Getting support cases
- Closing a support case

### Access required:
- Console access to the cluster that runs account-manager (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Relevant secrets:
- secrets/uhc-acct-mngr

### Steps:
- Contact SRE team for a service outage.
- Contact Service Delivery B team otherwise, and inform the greater service delivery team.

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

Users will not be able to access services that use the gateway. That doesn't
include the OCM services because those use an OpenShift path route, so the
communication goes directly from the OpenShift router to the pods. But it does
affect services like the upgrades information service (a.k.a. Cincinnati), the
assisted install service and the Kafka management service.

To find out which services are affected exactly check the configuration of the
Envoy proxy of the affected environment. For example, these are the Envoy
upstream clusters of the production environment at the time this was written:

https://gitlab.cee.redhat.com/service/app-interface/-/blob/9e4295cb7f531991ef2fc18f87ab794a6bfd4b82/resources/services/ocm/production/gateway-envoy.configmap.yaml#L81-172

### Summary:

Gateway is down

### Access required:

- Console access to the cluster that runs the gateway (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/gateway-envoy` logs to determine why pods are down.
- Contact Service Development A team on #service-development, sd-mp-devel@redhat.com.
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
  fail if communications are lost or if permissions arn't correct.

- Check the communications between the between the cluster where the OCM
  services run (the `app-sre` or `app-sre-stage` cluster) and the cluster
  where the _Hive_ and AWS account operators run (the `hive-production` or
  `hive-stage` cluster).

- Check that the service account used by the OCM clusters service to talk
  to the _Hive_ and AWS account operator exists and has the required
  permissions. The complete _kubeconfig_ files containing the details
  of these service accounts are stored in `provision_shards.config`.
  This file contains the complete _kubeconfig_ of those services.

  The OCM clusters service needs full permissions on configuration maps
  and permissions to create events inside the `uhc-leaderhsip` namespace.

- Contact Service Development A team on #service-delivery, sd-mp-devel@redhat.com.

- Inform the greater service delivery team.

---

## Metrics Worker Down

### Impact:

Metrics will not be reported for existing and new clusters.

### Summary:

Cluster Service cannot report metrics for the clusters. This may be because telemetry is down.

https://infogw-proxy.api.openshift.com/ (data from prod telemeter)
https://infogw-proxy.api.stage.openshift.com/ (data from staging telemeter)


### Access required:
 
- Console access to the cluster that runs the clusters service (`app-sre` and
  `app-sre-stage`).
- /app-interface/blob/master/data/services/observability/permissions/observability-access.yml.

### Steps:

- Check `deployment/clusters-service` logs to confirm the telemetry down.
- Contact Service Development A team on #service-delivery, sd-mp-devel@redhat.com.
- Contact #forum-telemetry slack channel,monitoring-telemeter-service@redhat.com

---

## Clusters Service Rejecting Requests Due To Exceeded Rate Limits

### Impact:

Requests that exceed the rate limits will be rejected with HTTP status code 429
so some clients, probably those abusing the service, will be blocked.

### Summary:

Clusters service is rejecting requests due to exceeded rate limits.

### Access required:

- Console access to the cluster that runs the clusters service.

- Edit access to the affected UHC namespaces:
  - `uhc-stage`
  - `uhc-production`

### Steps:

Check the logs of the `envoy` container of the `clusters-service` pods to find
out more details about the rejected requests. To do that you can use a Kibana
query like this:

```
kubernetes.namespace_name:uhc-stage AND kubernetes.pod_name:clusters-service-* AND kubernetes.container_name=envoy AND message:429
```

For each are rejected requests you will see messages like this:

```
[2021-02-03T12:02:32.490Z] POST /api/clusters_mgmt/v1/register_cluster HTTP/1.1" 429 - 3 126 2 -
"79.155.131.35,10.131.8.13" "OCM/0.1.145" "4e7b443e-c039-4339-bd02-a0f2b551aeac" "api.stage.openshift.com" "-"
```

Inform Service Development A team on #service-development, sd-mp-devel@redhat.com.

---

## Escalations

We want a link to app-interface here, but okay to just contacts here for now.

### Contacts:

Juan Hernandez (jhernand@redhat.com)
Oved Ourfali (oourfali@redhat.com)
Nimrod Shneor (nshneor@redhat.com)

