# OSDv4 cluster Transit Gateway attachments with existing AWS account

This SOP described how to provision TGW attachments (along with resource sharing, routes, etc) to be used as part of the PrivateLink work tracked in [SDE-896](https://issues.redhat.com/browse/SDE-896).

To add a TGW attachment between an OSDv4 Hive cluster and an AWS account managed in app-interface, perform the following operations:

1. Add a `peering` section to a cluster file. [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/85fe99cb3c2837ae03df2fe82ee64f3e2c954862/data/openshift/hive-stage-01/cluster.yml#L105-112).

    * Note: the cluster has to be managed by `ocm` (an `ocm` section must exist).
    * Make sure cluster has `awsGroup` that allow management of AWS cluster in `awsInfrastructureAccess` section. 

A TGW attachment will be created and accepted automatically.
The requester is the app-interface managed AWS account and the accepter is the cluster's AWS account.

Spec:

- `provider` - needs to be `account-tgw`
- `name` - name to use when creating attachments (usually the name of the cluster)
- `account` - a reference to the AWS account containing the Transit Gateway
- `tags` - Key-value pairs of tags to filter Transit Gateways by
- `manageRoutes` - should Transit Gateway routes be managed or not (should be `true` if the TGW setup is cross-region)
- `manageSecurityGroups` - should Security Groups (that belong to VPCs which are attached to the TGW) rules be managed or not
- `cidrBlock` - CIDR block to add to the cluster's VPC route table
