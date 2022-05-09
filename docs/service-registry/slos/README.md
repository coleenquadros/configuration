# Summary of Service Registry SLIs, SLOs and Metrics

This document provides a summary of the Service Registry SLIs and SLOs, and links to other related resources. It follows
the [authoritative definitions](../../../data/services/service-registry/slo-documents). It references production
configuration only, but the staging configuration uses the same values.

## Control Plane

- [Definitions](../../../data/services/service-registry/slo-documents/srs-fleet-manager.yaml)
- Alerts
    - [Availability](../../../resources/observability/prometheusrules/srs-fleet-manager-slos-availability-production.prometheusrules.yaml)
    - [Latency](../../../resources/observability/prometheusrules/srs-fleet-manager-slos-latency-production.prometheusrulestest.yaml)
- [Grafana Dashboards](https://grafana.app-sre.devshift.net/d/Tbw1Eg2Mz/srs-fleet-manager-metrics?var-datasource=app-sre-prod-04-prometheus&var-namespace=service-registry-production)

| Category | SLI | SLO | Alerts | Contributes to SLA
|---|---|---|---|---
| [Control Plane Availability](./srs-fleet-manager-api-availability.md) | Proportion of requests that are served successfully | 95% success | [Multi-window, multi-burn-rate alerts](https://sre.google/workbook/alerting-on-slos): <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d</li><li>10% budget burn over 3d</li></ul> | No
| [Control Plane Latency](./srs-fleet-manager-api-latency.md) (Base) | Proportion of successful requests served faster than 0.1s | 90% of requests < 100ms | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d or 3d</li></ul> | No
| [Control Plane Latency](./srs-fleet-manager-api-latency.md) (High) | Proportion of successful requests served faster than 1s | 99% of requests < 1000ms | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d or 3d</li></ul> | No

## Data Plane - Service Registry API

- [Definitions](../../../data/services/service-registry/slo-documents/srs-service-registry.yaml)
- Alerts
    - [Availability](../../../resources/observability/prometheusrules/srs-service-registry-slos-availability-production.prometheusrules.yaml)
    - [Latency](../../../resources/observability/prometheusrules/srs-service-registry-slos-latency-production.prometheusrules.yaml)
- [Grafana Dashboards](https://grafana.app-sre.devshift.net/d/VRxU14jZ1/service-registry-data-plane-metrics?var-datasource=app-sre-prod-04-prometheus&var-namespace=service-registry-production&var-datasouce_aws=AWS%20app-sre&var-DBInstanceIdentifier_aws=srs-service-registry-production&var-interval=5m)

| Category | SLI | SLO | Alerts | Contributes to SLA
|---|---|---|---|---
| [Data Plane Availability](./srs-service-registry-api-availability.md) (All) | Proportion of requests that are served successfully, applies to all operations | 99% success | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d</li><li>10% budget burn over 3d</li></ul> | No
| [Data Plane Availability](./srs-service-registry-api-availability.md) (Read) | Proportion of requests that are served successfully, applies to read operations | 99.95% success | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d</li><li>10% budget burn over 3d</li></ul> | **Yes**
| [Data Plane Availability](./srs-service-registry-api-availability.md) (Write) | Proportion of requests that are served successfully, applies to write operations | 99% success | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d</li><li>10% budget burn over 3d</li></ul> | No
| [Data Plane Availability](./srs-service-registry-api-availability.md) (Search)| Proportion of requests that are served successfully, applies to search operations | 99% success | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d</li><li>10% budget burn over 3d</li></ul> | No
| [Data Plane Latency](./srs-service-registry-api-latency.md) (All) | Proportion of requests served faster than 1s, applies to all operations | 99% of requests < 1000ms | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d or 3d</li></ul> | No
| [Data Plane Latency](./srs-service-registry-api-latency.md) (Read) | Proportion of requests served faster than 0.25s, applies to read operations | 99% of requests < 250ms | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d or 3d</li></ul> | No
| [Data Plane Latency](./srs-service-registry-api-latency.md) (Write) | Proportion of requests served faster than 1s, applies to write operations | 99% of requests < 1000ms | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d or 3d</li></ul> | No
| [Data Plane Latency](./srs-service-registry-api-latency.md) (Search) | Proportion of requests served faster than 1s, applies to search operations | 99% of requests < 1000ms | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d or 3d</li></ul> | No

## Data Plane - Tenant Manager API

- [Definitions](../../../data/services/service-registry/slo-documents/srs-service-registry.yaml)
- Alerts
    - [Availability](../../../resources/observability/prometheusrules/srs-tenant-manager-slos-availability-production.prometheusrules.yaml)
    - [Latency](../../../resources/observability/prometheusrules/srs-tenant-manager-slos-latency-production.prometheusrules.yaml)
- [Grafana Dashboards](https://grafana.app-sre.devshift.net/d/VRxU14jZ1/service-registry-data-plane-metrics?var-datasource=app-sre-prod-04-prometheus&var-namespace=service-registry-production&var-datasouce_aws=AWS%20app-sre&var-DBInstanceIdentifier_aws=srs-service-registry-production&var-interval=5m)

| Category | SLI | SLO | Alerts | Contributes to SLA
|---|---|---|---|---
| [Data Plane - Tenant Manager Availability](./srs-tenant-manager-api-availability.md) | Proportion of requests that are served successfully | 95% success | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d</li><li>10% budget burn over 3d</li></ul> | No
| [Data Plane - Tenant Manager Latency](./srs-tenant-manager-api-latency.md) (Base) | Proportion of successful requests served faster than 0.1s | 90% of requests < 100ms | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d or 3d</li></ul> | No
| [Data Plane - Tenant Manager Latency](./srs-tenant-manager-api-latency.md) (High) | Proportion of successful requests served faster than 0.1s | 90% of requests < 100ms | Multi-window, multi-burn-rate alerts: <ul><li>5% budget burn over 6h</li><li>10% budget burn over 1d or 3d</li></ul> | No

## Metrics

Each SLO definition has associated metrics, and then alerts based on them. Specific links to Grafana are located in the
definition files, but following is an overview:

- [Grafana](https://grafana.app-sre.devshift.net/?query=serviceregistry&search=open&orgId=1) (Production)

(TODO)

## Related Resources

- [SOP Definitions](../../../data/services/service-registry/slo-documents)
- [Alert Definitions](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/resources/observability/prometheusrules) (
  files starting with `srs-`)
- [Grafana](https://grafana.app-sre.devshift.net/?query=serviceregistry&search=open&orgId=1) (Production)
- [Standard Operating Procedures (SOPs)](https://gitlab.cee.redhat.com/service-registry/srs-sops)
