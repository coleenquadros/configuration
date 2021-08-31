## OCM service log 5xx

### Impact:

Cluster logs will not be able to be created.
As a result, triggers such as email notifications or webhooks will not be able to be executed.

### Summary:

OCM service log is returning an abnormally high number of 5xx Error requests

### Access required:

- Console access to the cluster that runs ocm-service-log (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/ocm-service-log` logs to determine why errors are occurring.
- Contact Service Delivery B team, inform the greater service delivery team.

---
