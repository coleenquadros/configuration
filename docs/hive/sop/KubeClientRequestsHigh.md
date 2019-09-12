# SOP : KubeClientRequestsHigh Alert

<!-- TOC depthTo:2 -->

- [SOP : KubeClientRequestsHigh](#kubeclientrequestshigh)

<!-- /TOC -->

---

## KubeClientRequestsHigh

### Impact:
Abnormal rate of requests to the Kubernetes API from Hive.

### Summary:
This alert monitors for excessive API requests and is intended to prevent infinite loops which can exhaust etcd and take down an entire cluster. If this alert is firing manual intervention should be taken as quickly as possible to prevent filling up etcd.

There are two variants of this alert, one for requests to the remote clusters Hive manages, and one for local requests to the Hive cluster API itself.

### Access required:
SRE-P is require to take action for this alert by scaling down the hive-controllers pod.

Hive team will need to determine if the problem is expected or not which will likely involve examining logs and recent PRs merged.

Access to stg/prod hive cluster (for access to Kibana and potentiall oc CLI access).

Stage Logs: 		https://logs.hive-stage.openshift.com/
Production Logs: 	https://logs.hive-production.openshift.com/

### Relevant secrets:

### TroubleShooting The Alert:
### Steps:
1. Contact @sre-primary or @sre-secondary and request they immediately scale down hive-controllers on the affected cluster: `kubectl scale -n hive deployment.v1.apps/hive-controllers --replicas=0`
1. If the problem is surfacing in the stage cluster, also contact @hive-team and request they immediately make a /hold comment on any pending PRs: https://github.com/openshift/hive/pulls. This prevents additional PRs for merging, deploying a new version, and scaling up the hive-controllers pod just scaled down.
1. Notify @hive-team of the issue and request they investigate why the app is making excessive API calls.
1. If hive team determines this to be expected and normal, scale controllers back up and wait for alert to resolve.

### Common failures:
