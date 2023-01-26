# Prometheus

[TOC]

## Overview

Prometheus is used in several ways on AppSRE clusters:

1. OpenShift comes installed with Prometheus, in the `openshift-monitoring` namespace,
   for cluster-specific metrics and alerts
2. AppSRE installs Prometheus in the `openshift-customer-monitoring` for AppSRE tenant
   metrics and alerts
    * The deployment and code repositories for this are associated with
      the [app-sre-observability service](https://visual-app-interface.devshift.net/services#/services/observability/app.yml)
    * There's
      a [ticket to evaluate moving this to UWM](https://issues.redhat.com/browse/APPSRE-6523)
3. Tenant-specific Prometheus deployments like `prometheus-ams`
   and [prometheus-quay-aggregation](/docs/quay/monitoring.md)
    * These are edge-cases with specific requirements not met by
      the `app-sre-observability` stack
    * Ownership of these instances is a case-by-case basis, but they're being mentioned
      here because it can often be a surprise to new team members that they exist

## SOPs

* [Prometheus SOPs for specific alerts](/docs/app-sre/sop/prometheus)
* [Increase Prometheus Storage](/docs/app-sre/sop/grow-prometheus-storage.md)
* [Troubleshooting high cardinality metrics](/docs/app-sre/sop/prometheus/troubleshooting-high-cardinality-metrics.md)

## Troubleshooting

### High CPU/memory utilization

You probably want to start
with [Troubleshooting high cardinality metrics](/docs/app-sre/sop/prometheus/troubleshooting-high-cardinality-metrics.md)
.

## Known Issues

Many of the Prometheus container configurations are missing CPU limits. We've observed
at least one case where this resulted in the Prometheus container using all the CPU
resources of a node, affecting other critical workloads on that node.

(Insert RCA + ticket link)
