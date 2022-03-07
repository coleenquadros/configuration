## OCM managed services 5xx

### Impact:

Customers will not be able to deploy new managed services.
Customers will not be able to monitor, configure, manage or decomission existing managed services.

### Summary:

OCM managed services is returning an abnormally high number of 5xx Error requests

### Access required:

- Console access to the cluster that runs ocm-managed-services (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/ocm-managed-services` logs to determine why errors are occurring.
- Contact @sda-team on #service-development.
- inform the greater service delivery team.

---
