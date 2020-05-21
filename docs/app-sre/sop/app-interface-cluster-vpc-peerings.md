# OSDv4 cluster VPC peerings with existing AWS account

To add a VPC peering between an OSDv4 cluster and an AWS account managed in app-interface, perform the following operations:

1. Add a VPC file, representing of the VPC in your AWS account, to which you want to peer. [Example](/data/aws/app-sre/vpcs/app-sre-vpc-01.yml).

    * Note: the data can be extracted from the AWS console.

2. Add a `peering` section to a cluster file. [Example](/data/openshift/app-sre-stage-01/cluster.yml#L42-45).

    * In order to obtain the source vpc-id, open the cluster console in OCM, open the Access Control tab and log in to the `readonly` ARN under AWS Infrastructure Access section. Once you switch to that account (you must be logged in first to your AppSRE AWS account), then you can switch to VPC and see what is the id of the vpc-id. You want to select the one that matches the IPv4 CIDR that was specified under the `.network.vpc` section in the cluster.yml file.
    * Note: the cluster has to be managed by `ocm` (an `ocm` section must exist).

A peering connection will be created and accepted automatically.
The requester is the cluster's AWS account and the accepter is the app-interface managed AWS account.

Note: in case a VPC peering connection already exists, it will be taken over by the integration.

Additional resources may still be required at this point.
Reference: [Housekeeping](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/app-sre/rds-vpc-subnets.tf)
