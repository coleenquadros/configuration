# SOP : OSD Fleet Manager - Delete management cluster

 
[toc]
 
# 1 Introduction
 
This document defines the steps to follow in order to delete a management cluster
 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
When a management cluster is no longer needed, this procedure should be followed.

## 1.3 Success Indicators
 
The management cluster is no longer listed
 
## 1.4 Stakeholders
 
Internal users
 
## 1.5 Additional Details
 
Deleting a management cluster via the OSDFM API is a 2 step process:
1. Send a DELETE request to simply moves the MC to `Deprovisioning` status
2. Send another DELETE request to ack the deletion. 
Asynchronous reconcilers will initiate the deletion of the management cluster fully, including quickly moving the management cluster to “maintenance” mode in the ACM placement decision so no new hostedClusters are added to it during the deprovisioning process.
 
# 2 Procedure
 
## 2.1 Plan
 
Make sure you have the permissions
* to delete (DELETE) and list (GET) Management Clusters 
* to list (GET) Service Cluster
 
## 2.2 Prerequisites
 
N/A
 
## 2.3 Execute
 
List management clusters:
```$ ocm get /api/osd_fleet_mgmt/v1/management_clusters```

Use the id of the management cluster from the above output:
```$ ocm delete /api/osd_fleet_mgmt/v1/management_clusters/${ID}```

Check the status of the management cluster:
```$ ocm get /api/osd_fleet_mgmt/v1/management_clusters/${ID}```

Once the status is `cleanup_ack_pending`, perform any checks needed (ie: making sure the MC has no more HC on it) and then you can send the following request to ack the deletion, this will unblock the OCM deletion:
```$ ocm delete /api/osd_fleet_mgmt/v1/management_clusters/${ID}/ack```

 
## 2.4 Validate
 
The Management Cluster status shall be `Cleanup` or shall a return a 404:
```$ ocm get /api/osd_fleet_mgmt/v1/management_clusters/${ID}```
 
## 2.5 Issue All Clear
 
N/A
# 3 Troubleshooting
 
N/A 
# 4 References
 
N/A
