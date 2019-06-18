# SOP : UHC

<!-- TOC depthTo:2 -->

- [SOP : UHC](#sop--uhc)
    - [AccountManagerDown](#account-manager-down)
    - [UHCAccountManager5xxErrorsHigh](#account-manager-5xx)
    - [UHCAccountManager4xxErrorsHigh](#account-manager-4xx)
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
  - uhc-staging
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
  - uhc-staging
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
  - uhc-staging
  - uhc-production

### Relevant secrets:
- secrets/uhc-acct-mngr

### Steps:

- Check `deployment/uhc-acct-mngr` logs to determine why errors are occurring.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Escalations
We want a link to app-interface here, but okay to just contacts here for now.

### Contacts:

Abhishek Gupta (agupta@redhat.com)
Timothy Williams (tiwillia@redhat.com)
Mark Turansky (mturansk@redhat.com)


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
  - uhc-staging
  - uhc-production

### Relevant secrets:
- secrets/app-interface/app-sre/uhc-production/clusters-service
- secrets/app-interface/app-sre/uhc-staging/clusters-service

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
  - uhc-staging
  - uhc-production

### Relevant secrets:
- secrets/app-interface/app-sre/uhc-production/clusters-service
- secrets/app-interface/app-sre/uhc-staging/clusters-service

### Steps:

- Check `deployment/clusters-service` logs to determine why errors are occurring.
- Contact Service Development A team on #service-delivery, sd-mp-devel@redhat.com.
- Inform the greater service delivery team.

---

## Escalations
We want a link to app-interface here, but okay to just contacts here for now.

### Contacts:

Juan Hernandes (jhernand@redhat.com)
Oved Ourfali (oourfali@redhat.com)
Nimrod Shneor (nshneor@redhat.com)
