# OSDv4 cluster VPC peerings with existing AWS account

To add a VPC peering between an OSDv4 cluster and an AWS account managed in app-interface, perform the following operations:

1. Add a VPC file, representing of the VPC in your AWS account, to which you want to peer. [Example](/data/aws/app-sre/vpcs/app-sre-vpc-01.yml).

    * Note: the data can be extracted from the AWS console.

2. Add a `peering` section to a cluster file. [Example](/data/openshift/app-sre-stage-01/cluster.yml#L45-49).

    * Note: the cluster has to be managed by `ocm` (an `ocm` section must exist).
    * The peering name should follow this convention: `<cluster-name>_<aws-account-name>`.
    * `managedRoutes` set to `true` will make the integration create the VPC routes in the cluster side.  Routes in the existing AWS account will be created outside app-interface (see below note about additional resources).
    * Make sure cluster has `awsGroup` that allow management of AWS cluster in `awsInfrastructureAccess` section, e.g. this will make possible for users in the `App-SRE-admin` group from `app-sre` account to assume `read-only` or `network-mgmt` roles in the cluster where this is added:
    ```
    - awsGroup:
        $ref: /aws/app-sre/groups/App-SRE-admin.yml
      accessLevel: read-only
    - awsGroup:
        $ref: /aws/app-sre/groups/App-SRE-admin.yml
      accessLevel: network-mgmt
     ```

A peering connection will be created and accepted automatically.
The requester is the cluster's AWS account and the accepter is the app-interface managed AWS account.

Note: in case a VPC peering connection already exists, it will be taken over by the integration.

Additional resources may still be required at this point. We have automated the creation of networking resources in some of our managed account in the [`infra`](https://gitlab.cee.redhat.com/app-sre/infra) repository, e.g. [`rds peerings in `app-sre` account](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/app-sre/rds-vpc-subnets.tf)

More info on [OSD peering doc](https://docs.openshift.com/dedicated/4/cloud_infrastructure_access/dedicated-aws-peering.html)
