# SOP : OCM Managed Services

Grafana: https://grafana.app-sre.devshift.net/d/ocm-managed-services/ocm-managed-services

<!-- TOC depthTo:2 -->

- [SOP : OCM Managed Services](#sop--uhc)
    - [Base Functionality](#base-functionality)
    - [Service Is Down](#service-down)
    - [Disaster Recovery](#disaster-recovery)
    - [OCM Managed Services 5xx](#OCM-Managed-Services-5xx)
    - [Escalations](#escalations)

<!-- /TOC -->

---

## Base Functionality

### Summary:

Basic check to verify the service is running properly

### Access required:

- None

### Steps:

- Ensure `https://api.openshift.org/api/service_mgmt/` is responding with a valid json and no errors.

---

## Service Is Down

### Impact:

Customers will not be able to deploy new managed services.
Customers will not be able to monitor, configure, manage or decomission existing managed services.

### Summary:

OCM Managed Services pods are down

### Access required:

- Console access to the cluster that runs ocm-managed-services (app-sre)
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Check `deployment/ocm-managed-services` logs to determine why pods are down.
- Contact @sda-team on #service-development.
- inform the greater service delivery team.

---

## Disaster Recovery

### Impact:

Customers will not be able to deploy new managed services.
Customers will not be able to monitor, configure, manage or decomission existing managed services.
Any actions performed after the latest backup will be lost, potentially leading to inconsistant state.

### Summary:

OCM Managed Services data is stored in RDS. If data is lost, recovery will be required.

### Access required:

- Access to RDS backup & restore service.
- Edit access to the uhc namespaces:
  - uhc-stage
  - uhc-production

### Steps:

- Restore latest backups from RDS
- Restart all service pods
- Contact @sda-team on #service-development.
- inform the greater service delivery team.

---

## OCM Managed Services 5xx

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

## Escalations

### Contacts:

- Irit Goihman (igoihman@redhat.com)
- Ciaran Roche (croche@redhat.com)
- Tomer Brisker (tbrisker@redhat.com)
