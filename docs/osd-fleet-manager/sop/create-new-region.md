# SOP : OSD Fleet Manager - Create new region

 
[toc]
 
# 1 Introduction
 
This document defines the required steps to take to create a new region in Fleet Manager in order to support it
 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
A new region needs to be supported

## 1.3 Success Indicators
 
A new Service Cluster is created for the given region, enabling its support.
 
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
 
Supported regions and their related configurations are stored in [app-interface](https://gitlab.cee.redhat.com/service/app-interface). 

This configuration in app-interface is pushed into the namespaces where the OSD Fleet Manager application runs as a ConfigMap. The application deployment mounts this ConfigMap and uses the config within to determine which regions to create service/management clusters within.

NOTE: Adding a supported region will result in immediate creation of a service and management cluster in that region. These clusters can be large and incur high cost.

Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/46512
https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm/osd-fleet-manager/cicd/deploy.yaml#L113

## 2.4 Validate
 
Once the MR is merged, check that at least 1 Service Cluster exists in the created region  (ie: GET `/api/osd_fleet_mgmt/v1/service_clusters`)
 
## 2.5 Issue All Clear
 
N/A
 
# 3 Troubleshooting
 
N/A

# 4 References
 
N/A
