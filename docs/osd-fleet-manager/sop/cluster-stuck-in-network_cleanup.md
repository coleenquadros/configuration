# SOP : OSD Fleet Manager - Cleanup of a Service/Management cluster stuck in cleanup_network phase

[toc]

# 1 Introduction

This document defines steps deal with service/management clusters managed by OSD Fleet Manager that are stuck in the `cleanup_network` phase

## 1.1 Reference Articles

[OSD Fleet Manager Cluster lifecycle documentation](https://gitlab.cee.redhat.com/service/osd-fleet-manager/-/blob/main/docs/hypershift/cluster-lifecycle.md)

## 1.2 Use Cases

A service or management cluster that is being deprovisioned may get stuck in the `cleanup_network` phase.
This happens when OSD Fleet Manager is unable to remove the cloud resources (e.g. subnets, VPC, etc.) due to existing dependencies.

## 1.3 Success Indicators

The service/management cluster moves beyond the `cleanup_network` phase and is removed.

## 1.4 Stakeholders
Internal users

## 1.5 Additional Details

Under normal circumstances, service/management clusters should not get stuck during cleanup.

OSD Fleet Manager uses Terraform to create cloud resources for (VPC, subnets, NAT gateways, etc.) for each service/management cluster it provisions and it is also responsible for removing these (in the `cleanup_network` phase) during service/management cluster cleanup.
However, it may happen that during the lifetime of the corresponding cluster, another component running on the cluster (e.g. HyperShift operator, aws-vpce-operator, etc.) leaks a cloud resource (e.g. a VPC Endpoint Service, load balancer, etc.) that remains attached to the cluster subnet.
As a result, OSD FM may not be able to complete the cleanup of cloud resources it manages because some of these resources (e.g. a subnet) may remain to be attached to these leaked cloud resources.
This SOP addresses this limitation by manually removing the leaked dependencies.

# 2 Procedure

## 2.1 Plan

N/A

## 2.2 Prerequisites

See prerequisites in [Accessing the AWS account of a cluster SOP](./accessing-the-aws-account-of-a-cluster.md)

## 2.3 Execute

1. Follow [Accessing the AWS account of a cluster SOP](./accessing-the-aws-account-of-a-cluster.md) to log in into the AWS account used by the cluster

1. Determine the region where the service/management cluster was running

    ```sh
    ocm get /api/osd_fleet_mgmt/v1/service_clusters/$CLUSTER_ID | jq -r .region
    ```

    or

    ```sh
    ocm get /api/osd_fleet_mgmt/v1/management_clusters/$CLUSTER_ID | jq -r .region
    ```

1. Locate the VPC used by the given cluster

    ```sh
    aws ec2 describe-vpcs --query "Vpcs[?Tags != null && contains(Tags, {Key: 'Name', Value: 'vpc-${CLUSTER_ID}'})]" --region=$REGION
    ```

1. List and remove all VPC Endpoint Services

    ```sh
    aws ec2 describe-vpc-endpoint-services --query "ServiceDetails[?Owner != 'amazon']" --region=$REGION
    ```

    If a VPC Endpoint Service is tagged with `hive.openshift.io/private-link-access-for` it was likely leaked by the [AVO operator](https://github.com/openshift/aws-vpce-operator).
    Alternatively, if the VPC Endpoint Service is tagged with `red-hat-clustertype` it was likely leaked by the [HyperShift operator](https://github.com/openshift/hypershift/).

    If any VPC Endpoint Services were found, remove them by running

    ```sh
    aws ec2 delete-vpc-endpoint-service-configurations --service-ids=$SERVICE_ID --region $REGION
    ```

    This may fail with `Service has existing active VPC Endpoint connections!` error.
    In such case, it is needed to first list all existing VPC Endpoint connections

    ```sh
    aws ec2 describe-vpc-endpoint-connections --query "VpcEndpointConnections[?ServiceId=='$SERVICE_ID']" --region $REGION
    ```

    and then reject each of these connections.

    Afterwards, VPC Endpoint Service removal can be retried.

    Repeat this process for all leaked VPC Endpoint Services.

1. List and remove all load balancers

    ```sh
    aws elbv2 describe-load-balancers --query "LoadBalancers[?VpcId=='$VPC_ID']" --region $REGION
    ```

    For each of the load balancers, run the following command to remove it:

    ```sh
    aws elbv2 delete-load-balancer --load-balancer-arn=$LB_ID --region $REGION
    ```

1. With all leaked VPC Endpoint Services and Load Balancers removed, OSD Fleet Manager should now be able to automatically proceed with removing the remaining cloud resources.
   Within ~10 minutes the VPC should no longer be present in the AWS account.

   If the VPC is still present after 10 minutes, there may be additional dependencies preventing its removal.
   In that case, follow [AWS documentation](https://repost.aws/knowledge-center/troubleshoot-dependency-error-delete-vpc) to identify these resources.
   Consider updating this SOP with additional steps based on afterwards.

## 2.4 Validate

The service/management cluster is completely removed, i.e. both these commands return 404

```sh
ocm get /api/osd_fleet_mgmt/v1/service_clusters/$CLUSTER_ID
ocm get /api/osd_fleet_mgmt/v1/management_clusters/$CLUSTER_ID
```

## 2.5 Issue All Clear

N/A

# 3 Troubleshooting

N/A

# 4 References

N/A
