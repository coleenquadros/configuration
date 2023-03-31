# SOP : OSD Fleet Manager - Short-lived clusters

 
[toc]
 
# 1 Introduction
 
This document defines the steps to follow to create and use short-lived (aka detached) Service and/or Management Clusters in any region without enabling any support for any not supported region.

 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
Creating a region, as described in [this SOP](create-new-region.md), is intended for situations where support for HyperShift is needed in the given region. In that case, OSD Fleet Manager will guarantee capacity in the given region by automatically provisioning and scaling clusters and putting safeguards in place preventing existing service/management clusters to be enabled.

While this behavior fits the requirements of the ROSA(HyperShift) service, it may be too restrictive in situations where short-lived ad-hoc capacity is needed (e.g. for testing the fleet manager itself). In order to address this, OSD Fleet Manager supports provisioning of ad-hoc clusters in selected environments.

How it works:
* no need to enable the given region
* an API call is used to create a short-lived service cluster
* OSD Fleet Manager automatically provisions the corresponding management cluster
* once ready, the service cluster is registered as a provision shard making it possible to deploy hosted clusters
* when no longer needed, the service and management clusters can be deleted using the API

## 1.3 Success Indicators
 
Service and/or Management Cluster(s) available 
 
## 1.4 Stakeholders
 
Internal users
 
## 1.5 Additional Details
 
N/A 
 
# 2 Procedure
 
## 2.1 Plan
 
Make sure you have the permissions
* to create (POST) and list (GET) Management Clusters 
* to list (GET) Service Cluster
 
## 2.2 Prerequisites
 
N/A
 
## 2.3 Execute

Execute:
```
export REGION="ap-northeast-1"
echo '{"region": "ap-northeast-1", "cloud_provider": "aws"}' | ocm post /api/osd_fleet_mgmt/v1/service_clusters
```

Wait until the clusters become ready

```
ocm get /api/osd_fleet_mgmt/v1/service_clusters -p search="region='${REGION}'"
ocm get /api/osd_fleet_mgmt/v1/management_clusters -p search="region='${REGION}'"
```
 
## 2.4 Validate
Run
```
ocm get /api/osd_fleet_mgmt/v1/service_clusters -p search="region='${REGION}'"
ocm get /api/osd_fleet_mgmt/v1/management_clusters -p search="region='${REGION}'"
```
This should return a ready cluster
 
## 2.5 Issue All Clear
 
Once testing is finished, the clusters can be removed. Be extra careful not to accidentally delete a different cluster as that would have an impact on long-running environments!

```ocm delete /api/osd_fleet_mgmt/v1/service_clusters/${SERVICE_CLUSTER_ID}
ocm delete /api/osd_fleet_mgmt/v1/management_clusters/${MANAGEMENT_CLUSTER_ID}
```
 
# 3 Troubleshooting
 
N/A

# 4 References
 
N/A
