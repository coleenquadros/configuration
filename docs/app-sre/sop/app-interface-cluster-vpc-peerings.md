# OSDv4 cluster VPC peerings with existing AWS account

To add a VPC peering between an OSDv4 cluster and an AWS account managed in app-interface, perform the following operations:

1. Add a VPC file, representing of the VPC in your AWS account, to which you want to peer. [Example](/data/aws/app-sre/vpcs/app-sre-vpc-01.yml).
    * Note: the data can be extracted from the AWS console.

2. Add a `peering` section to a cluster file. [Example](/data/openshift/app-sre-stage-01/cluster.yml#L42-45).
    * Note: the cluster has to be managed by `ocm` (an `ocm` section must exist).

That's it!

A peering connection will be created and accepted automatically.
The requester is the cluster's AWS account and the accepter is the app-interface managed AWS account.

Note: in case a VPC peering connection already exists, it will be taken over by the integration.

Additional resources may still be required at this point.
Reference: [Housekeeping](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/app-sre/rds-vpc-subnets.tf)
