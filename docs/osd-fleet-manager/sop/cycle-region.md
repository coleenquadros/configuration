# SOP : OSD Fleet Manager - Cycle region

 
[toc]
 
# 1 Introduction
 
This document defines steps to re-create the fleet in a given region or in all regions of a specific environment without any downtime for new Hosted Clusters
 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
During development it has been necessary to completely re-create the fleet in a given region or in all regions of a specific environment. 

## 1.3 Success Indicators
 
New Service and Management Clusters created for a given region and old ones delete without any downtime
 
## 1.4 Stakeholders
 
Internal users
 
## 1.5 Additional Details
 
This document the process that can be followed (as of 1/31/22) to cycle a region without interrupting the creation of new hosted clusters in the region/environment.
 
# 2 Procedure
 
## 2.1 Plan
 
Make sure you have the permissions
* to create (POST), list (GET) and delete (DELETE) Management Clusters 
* to create (POST), list (GET) and delete (DELETE) Service Cluster
 
## 2.2 Prerequisites
 
N/A
 
## 2.3 Execute
 
1. Do NOT disable the region in app-interface configuration.
2. Create a new service cluster in the region. Ex:

```
$ REGION=”us-east-1”
$ echo ‘{“cloud_provider”:”aws”,”region”:”$REGION”}’ | ocm post /api/osd_fleet_mgmt/v1/service_clusters
```
3. The service cluster creation will automatically start a new management cluster creation as well. Check on both with the APIs:
```
$ ocm get /api/osd_fleet_mgmt/v1/service_clusters
$ ocm get /api/osd_fleet_mgmt/v1/management_clusters
```
4. Once the new service and management cluster are completely up, verify a new provision shard exists for the new service cluster:
```
$ ocm get /api/clusters_mgmt/v1/provision_shards -p search=”management_cluster !=''
```
5. The clusters-service component will ensure new hosted cluster creations will land on the provision shard mapping to the service cluster with the least number of hosted clusters on it. 
 This results in the new service cluster likely receiving the majority of new hosted cluster requests automatically. 

At this point, it should be safe to remove the old service/mgmt clusters as new hosted clusters can still be created on the new.

6. Set the existing service and management clusters in maintenance mode, removing them both from the hosted cluster placement decisions:
```
$ echo ‘{“status”:”maintenance”} | ocm patch /api/osd_fleet_mgmt/v1/service_clusters/$service_cluster_id

$ echo ‘{“status”:”maintenance”} | ocm patch /api/osd_fleet_mgmt/v1/management_clusters/$mgmt_cluster_id
```
7. Clean up / delete all hosted clusters on the management and service cluster. To identity which clusters need to be deleted, you can either:
* On each management cluster, run:
 ```oc get hostedCluster –all-namespaces```
* Run the following OCM command, searching by a list of management cluster names:
```
$ ocm get /api/clusters_mgmt/v1/clusters -p search="hypershift.enabled='true' and hypershift.management_cluster in ('hs-mc-7op0pe2og')"
```
* Ensure that clusters are deleted using `ocm delete …` if possible, as this is the cleanest way to delete clusters.


8. Once hosted clusters have been removed, delete the service and management cluster(s):
```
$ ocm delete /api/osd_fleet_mgmt/v1/service_clusters/$service_cluster_id
$ ocm delete /api/osd_fleet_mgmt/v1/management_cluster/$mgmt_cluster_id
```

*NOTE* Deleting a service cluster will not automatically delete all of the management clusters that are children of that service cluster. They must also be deleted.

*NOTE* It is possible to perform step 8 instead of step 6. The management and service clusters will not be fully deleted until after all hosted clusters have been deleted.

 
## 2.4 Validate
 
What steps are required to verify that the procedure has been followed correctly and the required changes have been implemented correctly, with the desired outcome.
 
> e.g., have alerts resolved?, are dashboards as expected?, have services resumed?, etc.
 
## 2.5 Issue All Clear
 
This section is usually more high-level and details the formal close-out of work.
 
> e.g., committing changes to any modified (housekeeping) files, updating status articles or support tickets, formally notifying the relevant teams & customers, etc.
 
# 3 Troubleshooting
 
Provide any helpful troubleshooting information and/or links.
 
# 4 References
 
Provide any sources of information (if applicable).
