# SOP : OSD Fleet Manager - Override hypershift image

 
[toc]
 
# 1 Introduction
 
This document defines the steps to override hypershift images via ACM
 
 
## 1.1 Reference Articles
 
https://github.com/stolostron/hypershift-addon-operator/blob/main/docs/advanced/upgrading_hypershift_operator.md
 
## 1.2 Use Cases
 
A specific version of the hypershift operator or other component listed in the previous link is/are neded.
## 1.3 Success Indicators
 
The components are running with the desired specific version.
 
## 1.4 Stakeholders
 
Internal users
 
## 1.5 Additional Details
 
N/A 
 
# 2 Procedure
 
## 2.1 Plan
 
Make sure you have access and have mergre permission to [app-interface](https://gitlab.cee.redhat.com/service/app-interface)
 
 
## 2.2 Prerequisites
 
N/A
 
## 2.3 Execute
 
The override configurations are stored in [app-interface](https://gitlab.cee.redhat.com/service/app-interface). 

This configuration in app-interface is pushed into the namespaces where the OSD Fleet Manager application runs as a ConfigMap. The application deployment mounts this ConfigMap as a file and uses it as a template. 
The template is then applied as a syncset to OCM CS.


Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/46512
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm/osd-fleet-manager/cicd/deploy.yaml#L113
 
## 2.4 Validate
 
The configmap in on the service clusters `hypershift-override-images` in the namespaces of the management clusters is updated with the specified versions.
 
## 2.5 Issue All Clear
 
N/A
 
# 3 Troubleshooting
 
* After Fleet Manager requests the creation of the OSD cluster, it applies some configuration on the cluster. How can we watch the FM logs? We have updated HO image overrides twice before. And each time, updates did not happen immediately. Only after we came back the next day.

    * How do we access the FM logs: 
      * PRODUCTION:
      https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/topology/ns/osd-fleet-manager-production?view=graph 
      * STAGE:
      https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/ns/osd-fleet-manager-stage/deployments
      * INTEGRATION:
  https://console-openshift-console.apps.app-sre-stage-0.k3s7.p1.openshiftapps.com/k8s/ns/osd-fleet-manager-integration/deployments

    You can generate your OCP token, and monitor the ‘service’ logs from the terminal as normal

  * For syncsets, you can look for log statement referencing “ext-%s-XXX” stating the this syncset needs to be updated
    * %s being the name of the cluster
    * XXX being the name of the syncset
    * Ie: ext-hs-mc-gvqr9dno0-acm-hs-operator-override

  * If syncset was updated, you can check the actual value by sending a request to OCM CS on `/api/clusters_mgmt/v1/clusters/{cluster_id}/external_configuration/syncsets `:
    * `ocm get $ID/external_configuration/syncsets | jq -r '.items[] | select(.id == "ext-hs-mc-kh70i22l0-acm-hs-operator-override")'`
    * `ocm get $ID/external_configuration/syncsets | jq -r '.items[] | select(.id == "ext-monitoring-stack")' | jq '.resources[] | select(.kind == "MonitoringStack") | .metadata.name'`
 

  * You can also check [the console interface](https://console-openshift-console.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/k8s/ns/osd-fleet-manager-production/core~v1~ConfigMap) to see the configmap that is actually applied (ie: hypershift-override-images-blue)

  * Verify there are no problems in the pipeline jobs
  https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/dev-pipelines/ns/ocm-pipelines/
  
# 4 References
 
N/A
