# Previously seen problems with the Argo CD running in the fleet manager

## Pre-requisites

Follow the steps in [Getting Access](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/getting-access.md) to do the following:
* Gain view access to RHTAP clusters
* Gain view access to the fleet manager cluster
* Gain view access to RHTAP logs
* Gain view access to AppSRE logs
* Manage RHTAP deployments using Argo CD

## My app's latest changes haven't been picked up

### Indicators of this problem

* A recent bug-fix or upgrade hasn't been applied to one or more clusters as expected
* The [Argo CD dashboard](https://argocd-server-argocd.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/applications) shows that an application is out of sync.

### Steps

* Navigate to the [Argo CD dashboard](https://argocd-server-argocd.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/applications) and find your application. Click on the Refresh button to see if it picks up your latest changes.
* Drill down into your application details to look for failures, and check the deployment logs.
* If a single pod is unable to start, try deleting the pod and letting OpenShift re-create it.

## Refresh/Sync not working for multiple apps

### Errors in Argo CD

* "I have clicked on Refresh button for build-service-stone-prd-m01 the [Argo CD dashboard](https://argocd-server-argocd.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/applications) and it's still refreshing and build-service-stone-prd-rh01 is wating to start sync for more then 1 hour." 
* "Some apps the [Argo CD dashboard](https://argocd-server-argocd.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/applications) are stuck at Syncing."
* In the [Argo CD dashboard](https://argocd-server-argocd.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/applications) some applications will repeatedly try to synchronize.
* [Slack thread example](https://redhat-internal.slack.com/archives/C02CTEB3MMF/p1681383674386309?thread_ts=1681383617.843429&cid=C02CTEB3MMF)

### Errors in the fleet manager cluster

* Containers with unready status: [argocd-application-controller] in the [fleet manager console](https://console-openshift-console.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/)
* Resource usage: the `argocd-application-controller` pod is reaching its memory limit in the [fleet manager console](https://console-openshift-console.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/k8s/ns/argocd/pods/argocd-application-controller-0) and consistently consuming 2 CPUs.
* When viewing the pod details for the `argocd-application-controller` pod in the [fleet manager console](https://console-openshift-console.apps.stonesoupp01ue1.kt4n.p1.openshiftapps.com/k8s/ns/argocd/pods/argocd-application-controller-0/events), the Events tab shows many "Readiness probe failed" errors.

### Errors in the AppSRE logs

* `W0413 09:06:54.023261 1 reflector.go:442] pkg/mod/k8s.io/client-go@v0.24.2/tools/cache/reflector.go:167: watch of *v1.Secret ended with: an error on the server ("unable to decode an event from the watch stream: http2: client connection lost") has prevented the request from succeeding`
* `E0413 09:06:54.038852 1 retrywatcher.go:130] "Watch failed" err="Get \"https://api.stone-prd-rh01.pg1f.p1.openshiftapps.com:6443/apis/console.openshift.io/v1/consoleplugins?allowWatchBookmarks=true&resourceVersion=105984487&watch=true\": http2: client connection lost"`
* `98s         Warning   Unhealthy          pod/argocd-application-controller-0          Readiness probe failed: Get "http://10.129.2.6:8082/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)`
* `ClusterRoleBinding/pipeline-service-exporter-reader-binding is part of applications argocd/pipeline-service-stone-prd-m01 and monitoring-workload-prometheus-stone-prd-m01`
* `CustomResourceDefinition/repositories.pipelinesascode.tekton.dev is part of applications argocd/pipeline-service-stone-prd-m01 and build`

### Steps to resolve

* Someone from AppSRE can delete the pod `argocd-application-controller-0` and let OpenShift re-create it automatically. Verify that the pod is able to get into the Ready state. We can request this help in #wg-sre-rhtap.
* To resolve duplicated rolebindings, developer intervention was needed. See this [Slack thread](https://redhat-internal.slack.com/archives/C02CTEB3MMF/p1681400556399389?thread_ts=1681383617.843429&cid=C02CTEB3MMF) for the resulting PRs in infra-deployments.
