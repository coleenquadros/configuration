# Design doc: manage status page component status

## Author/date
Gerd Oberlechner - March 2022

## Problem Statement
Red Hat uses status pages like status.redhat.com to communicate the status of offered services. Since management access to status pages is not widely available to service owners, the creation of status page components has been implemented as a self service in app-interface for `OnBoarded` services (see [AppSRE dev guidelines](https://service.pages.redhat.com/dev-guidelines/docs/appsre/advanced/statuspage/) for details about the `/dependencies/status-page-component-1.yml` schema). What is still missing is a way for service owners to manage the status of a component.

## Goals
Allow tenants to manage the state of their status page components via app-interface.

## Non-objectives
Manage incidents on status pages.

## Proposal
Add declarative configuration options to [status page components](https://github.com/app-sre/qontract-schemas/blob/main/schemas/dependencies/status-page-component-1.yml) in app-interface to define how the status of a component should be determined and managed. Using the [provider pattern](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-interface/qontract-reconcile-patterns.md) will enable AppSRE to provide different strategies and data sources for status information.

```yaml
---
$schema: /dependencies/status-page-component-1.yml
name: yakk-shaving-service
...
status:
- provider: provider
  <provider specific information>
- provider: another-provider
  <provider specific information>
```

If a component has no `status` section or an empty `status` section, the status of the component on the status page will not be managed by app-interface. The default status value of a component is `Operational`.

Status page components have one of the following status value: `Operational`, `Degraded performance`, `Partial outage`, `Major outage`, `Under maintenance`.

This proposal focuses on two provider strategies that will enable status management based on prometheus alerts or manual status management.

### Prometheus alert based status management
The `prometheus-alerts` provider watches for active Prometheus alerts matching the expressions defined in `status.prometheusAlerts.matchers`. When an active alert matches a `matchExpression`, the respective `componentStatus` is applied to the component. If multiple `matchExpressions` match active alerts, the most severe `componentStatus` gets applied to the status page component.

The reference in `status.prometheusAlerts.namespace` points to the namespace that defines the alerts. This way the cluster and Alertmanager instance responsible for alerting can be identified via `/openshift/clusters-1.yml#alertmanagerUrl`.

```yaml
---
$schema: /dependencies/status-page-component-1.yml
name: yakk-shaving-service
...
status:
- provider: prometheus-alerts
  prometheusAlerts:
    namespace: /services/yakk-shaving/namespaces/yakk-stable.yml
    matchers:
    - matchExpression:
        alert: YakkIsInBadMood
        labels:
          service: yakk-shaving-service
          severity: high
      componentStatus: Degraded performance
    - matchExpression:
        labels:
          service: yakk-shaving-service
          severity: critical
        # note that we don't have an alert name here
        # anything critical about our Yakk is a Major Outage
      componentStatus: Major Outage
```

### Manual status management
The `manual` provider has the capability to manually set the status of a component.

The optional `status.manual.from` and `status.manual.until` fields can be used to declare maintenance windows. Within the time windows, the status is managed by this provider but hands over status management to other proviers when the timewindow is not active.

```yaml
---
$schema: /dependencies/status-page-component-1.yml
name: yakk-shaving-service
...
status:
- provider: manual
  manual:
    componentStatus: Under Maintenance
    from: timestamp-with-timezone [optional]
    until: timestamp-with-timezone [optional]
```

### Combining providers
If multiple providers are defined for a status page component, the first listed provider yielding a status is used for status management. A provider is "yielding a status" when its internal condition is active, e.g.
* `manual` provider declared without a time windows definition or with an active time window definition
* `prometheus-alerts` provider declared with at least one matching alert

In the following example, the status of the component is `Under Maintenance` until the defined timestamp in `manual.until` has passed. After that, the status is managed based on Prometheus alerts.

```yaml
---
$schema: /dependencies/status-page-component-1.yml
name: yakk-shaving-service
...
status:
- provider: manual
  manual:
    until: timestamp-with-timezone
    componentStatus: Under Maintenance
- provider: prometheus-alerts
  prometheusAlerts:
    namespace: /services/yakk-shaving/namespaces/yakk-stable.yml
    matchers:
    - matchExpression:
        alert: YakkIsInBadMood
        labels:
          service: yakk-shaving-service
          severity: high
      componentStatus: Degraded performance
```

If none of the listed providers are active (none is yielding a status), the status of the component reverts to `Operational`.

### Self-service app-interface MR
Merge requests including `/dependencies/status-page-component-1.yml` files can not be self serviced by tenants right now. The reactive nature of the `manual` provider justifies self-servicing merge requests in app-interface, as long as they only add or change a `status.provider: manual` section.

## Implementation suggestions
Alertmanager offers an [API](https://github.com/prometheus/alertmanager/blob/main/api/v2/openapi.yaml) to query information about currently active alerts and silences. Using this API allows the implementing qontract-reconcile integration to be stateless and job oriented.

## Related work

### Catchpoint integration
[APPSRE-3905](https://issues.redhat.com/browse/APPSRE-3905) is also covering attaching Catchpoint checks to status page components. The work that has been done in [app-sre/signalfx-prometheus-exporter](https://github.com/app-sre/signalfx-prometheus-exporter) and [APPSRE-4700](https://issues.redhat.com/browse/APPSRE-4700) brings Catchpoint check results into AppSREs Prometheus, where they can be turned into alerts that can be referenced by the `prometheus-alerts` provider. This way Catchpoint checks can be attached to status page components completely via app-interface.

### Maintenance windows
[APPSRE-3906](https://issues.redhat.com/browse/APPSRE-3906) requests maintenance windows for services listed on status page components. The `status.manual.from` and `status.manual.until` fields of the `manual` provider can be used to set maintenance windows.

## Future enhancements
When RHOBS starts to gain traction, a dedicated provider similar to the `prometheus-alerts` can be implemented to watch for alerts there.

## Milestones
The implementation of both suggested providers will be delivered in one go. Multiple milestones are not required.
