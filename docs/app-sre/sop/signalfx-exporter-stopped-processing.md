# SignalFX Prometheus Exporter Stopped Processing

## Severity: High

## Impact

[Catchpoint monitoring](/docs/app-sre/design-docs/service-endpoint-monitoring.md#catchpoint-provider) will be unavailable within Prometheus. 

## Steps
- Review pod logs within the `app-sre-observability-production/stage` namespace
- Recycle the pod within OpenShift 
