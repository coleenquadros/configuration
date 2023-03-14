# SOP : OSD Fleet Manager - Cleanup Management cluster's AWS resources

 
[toc]
 
# 1 Introduction
 
This document defines steps to delete all the leftover AWS resources related to a deleted Management Cluster
 
## 1.1 Reference Articles
 
N/A
 
## 1.2 Use Cases
 
When a Management Cluster is deleted by CS or Hive while HostedClusters are still present, the Hypershift Operator should have finalizers in place to ensure that all of the resources used by the HostedClusters are deleted before the cluster is deleted. A bug exists where this does not happen: https://issues.redhat.com/browse/HOSTEDCP-616

This results in orphaned AWS resources that must be manually cleaned up. Another bug exists in the hypershift operator where it is not properly tagging these resources, making determining which resources to delete fairly complex: https://issues.redhat.com/browse/HOSTEDCP-617

The primary resource that will remain that needs to be reaped is the VPC for the Management Cluster. AWS limits to 5 VPCs per account, so additional VPCs remaining around can quickly restrict new Management clusters from being created. 
## 1.3 Success Indicators
 
All AWS resources for the related Management Cluster are deleted 
## 1.4 Stakeholders
Internal users
 
## 1.5 Additional Details
N/A
 
 
# 2 Procedure
 
## 2.1 Plan
 
Make sure you have access to AWS console
 
## 2.2 Prerequisites
 
N/A
 
## 2.3 Execute
 
1. Log into the AWS Account through the AWS Console
2. Review the existing VPCs. The VPC naming should include the name of the Management Cluster. Identify the VPC to be deleted and attempt to delete it. Likely, you will hit an error deleting the VPC stating that interfaces still exist.
3. Navigate to the “Endpoint Services” in the VPC console. For each endpoint service, navigate to the “Load Balancers” tab and click on any one of the load balancers. Review the load balancer’s tags, there will be a tag with the key `kubernetes.io/cluster/{CLUSTER_NAME}`. If the cluster name in the key matches the name of the MC you are cleaning up resources for, then this Endpoint Service needs to be deleted first
4. To delete the Endpoint Service, first all Endpoint Connections that are active against the Endpoint Service need to be rejected. These Endpoint Connections are/were connections made from the AWS account where the nodes belonging to a HostedCluster on the MC existed. Since the MC is gone, they can be safely rejected. Once all active Endpoit Connections are removed, the Endpoint Service can be deleted.
5. Once the Endpoint Service is deleted, it is then necessary to delete the load balancer(s) associated with the VPC. These load balancers could not be deleted until all Endpoint Services attached were first deleted. You can navigate to “Load Balancers” in the EC2 console and search with the VPC ID to review all associated load balancers.
6. Allow some time for the network interfaces and subnets associated with the load balancers you just deleted to be automatically reaped. Attempt to delete the VPC again. If you still see the same issue, wait another few minutes and try again. You should be able to delete the VPC now.

 
## 2.4 Validate
 
No leftover resources and VPC deleted from AWS for the related Management Cluster
 
## 2.5 Issue All Clear

N/A
 
# 3 Troubleshooting
 
N/A 
# 4 References
 
N/A
