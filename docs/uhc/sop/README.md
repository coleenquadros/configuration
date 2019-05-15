# SOP : UHC

<!-- TOC depthTo:2 -->

- [SOP : UHC](#sop--uhc)
    - [AccountManagerDown](#accountmanageddown)
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

- Console access to the cluster that runs accoutn-manager (app-sre)
- Edit access to the uhc namespaces:
  - uhc-staging
  - uhc-production

### Relevant secrets:
- secrets/uhc-acct-mngr

### Steps: 

- Check `deployment/uhc-acct-mngr` logs to determine why pods are down.
- Contact Service Delivery B team, inform the greater service delivery team.

---

## Escalations
We want a link to app-interface here, but okay to just contacts here for now. 

### Contacts:

Abhishek Gupta (agupta@redhat.com)
Timothy Williams (tiwillia@redhat.com)
Mark Turansky (mturansk@redhat.com)
