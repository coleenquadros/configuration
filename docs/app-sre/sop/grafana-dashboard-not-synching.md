# Grafana Dashboard Update not Synching

Sometimes Grafana dashboards are not properly synched.

1. Check [grafana prod pods](https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/k8s/ns/app-sre-observability-production/deployments/grafana/pods) / [grafana staging pods](https://console-openshift-console.apps.appsres03ue1.5nvu.p1.openshiftapps.com/k8s/ns/app-sre-observability-stage/deployments/grafana/pods) for error message: `Not saving new dashboard due to restricted database access`
1. If you see the error message in one of the pods, then restart all grafana pods and the dashboards will be synched
