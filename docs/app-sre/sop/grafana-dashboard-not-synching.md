# Grafana Dashboard Update not Synching

Sometimes Grafana dashboards are not properly synched.

1. Check [grafana prod pods](https://console-openshift-console.apps.app-sre-prod-01.i7w5.p1.openshiftapps.com/k8s/ns/app-sre-observability-production/deploymentconfigs/grafana/pods) / [grafana staging pods](https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/ns/app-sre-observability-stage/deploymentconfigs/grafana/pods) for error message: `Not saving new dashboard due to restricted database access`
1. If you see the error message in one of the pods, then restart all grafana pods and the dashboards will be synched

