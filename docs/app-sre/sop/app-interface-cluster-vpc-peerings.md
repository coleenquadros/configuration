# OSD Peering

## OSDv4 cluster VPC peerings with existing AWS account

To add a VPC peering between an OSDv4 cluster and an AWS account managed in app-interface, perform the following operations:

1. Add a VPC file, representing of the VPC in your AWS account, to which you want to peer. [Example](/data/aws/app-sre/vpcs/app-sre-vpc-01.yml).

    * Note: the data can be extracted from the AWS console.

2. Add a `peering` section to a cluster file. [Example](/data/openshift/app-sre-stage-01/cluster.yml#L45-49).

    * Note: the cluster has to be managed by `ocm` (an `ocm` section must exist).
    * The peering name should follow this convention: `<cluster-name>_<aws-account-name>_<vpc-name>`.
    * `managedRoutes` set to `true` will make the integration create the VPC routes in the cluster side.  Routes in the existing AWS account will be created outside app-interface (see below note about additional resources).
    * Make sure to define `awsInfrastructureManagementAccounts` in your cluster.yml. This is required for the `terraform` user to obtain `network-mgmt` permissions in the OSD cluster. Those permissions are required for terraform to do the peering.

      ```yaml
      awsInfrastructureManagementAccounts:
      - account:
          $ref: /aws/cluster/account.yml
        accessLevel: network-mgmt
        default: true
      ```

    * If you use a `tags` block, make sure your VPC has the matching tags. They are used as a filter:

      ```yaml
      peering:
        connections:
        - provider: account-vpc-mesh
          name: appint-ex-01_app-int-example-01_mesh
          account:
            $ref: /aws/app-int-example-01/account.yml
          tags:
            # Make sure your VPC has this tag -> this is used as a filter!
            Name: app-interface-development
          manageRoutes: true
      ```

3. Make sure your clusters `network` block matches with your OCM clusters network CIDRs!
Go to the [console](https://console.redhat.com/openshift). In the Network section of your cluster you will find the CIDRs.

A peering connection will be created and accepted automatically by the `terraform-vpc-peerings` integration.
The requester is the cluster's AWS account and the accepter is the app-interface managed AWS account.

Note: in case a VPC peering connection already exists, it will be taken over by the integration.

Additional resources may still be required at this point. We have automated the creation of networking resources in some of our managed account in the [`infra`](https://gitlab.cee.redhat.com/app-sre/infra) repository, e.g. [`rds peerings in `app-sre` account](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/app-sre/rds-vpc-subnets.tf)

More info on [OSD peering doc](https://docs.openshift.com/dedicated/4/cloud_infrastructure_access/dedicated-aws-peering.html)

## OSDv4 Cluster to Cluster VPN peering

To add a VPC peering between two OSDv4 clusters managed in app-interface, perform the following operations:

1. Add a peering connection entry of provider `cluster-vpc-requester` entry to one cluster
  
    ```yaml
    peering:
      connections:
      ...
      - provider: cluster-vpc-requester
        name: <this-cluster_<other-cluster>
        cluster:
          $ref: /openshift/<other cluster>/cluster.yml
        manageRoutes: true
    ```

2. Add a peering connection entry of provider `cluster-vpc-accepter` entry to the cluster
   
    ```yaml
    peering:
      connections:
      ...
      - provider: cluster-vpc-accepter
        name: <this-cluster_<other-cluster>
        cluster:
          $ref: /openshift/<other cluster>/cluster.yml
        manageRoutes: true
    ```

    * Make sure the cluster on the accepter side has an account with `default: true` and `accessLevel: network-mgmt` listed in the `awsInfrastructureManagementAccounts` section. This account will be used for terraform activities in both cluster AWS accounts. The default account choice can be overwritten on the `accepter` side by providing an extra `awsInfrastructureManagementAccount` section on the peering connection.
  
      ```yaml
      peering:
        connections:
        ...
        - provider: cluster-vpc-accepter
          name: <this-cluster_<other-cluster>
          cluster:
            $ref: /openshift/<other cluster>/cluster.yml
          awsInfrastructureManagementAccount:
            $ref: /aws/<aws account name>/account.yml
          manageRoutes: true
      ```

    In this case make sure, that this overwrite account it also listed in the `awsInfrastructureManagementAccounts` section of the accepter cluster with `accessLevel: network-mgmt`.

    * Right now, the account used for terraform activies, must also be mentioned via an `awsGroup` with `accessLevel: network-mgmt` in `awsInfrastructureAccess` - this will change with APPSRE-4397, when the source of truth for terraform user permissions will become `awsInfrastructureManagementAccounts`

## Troubleshooting

During reconciliation loop you might see error:

```
Error: Error finding route after creating it
```

This might relate to an [older bug](https://github.com/hashicorp/terraform-provider-aws/issues/12073) in the terraform aws provider (We are using 3.22).
When you see this error, simply delete the affected routes manually from the routing table and wait for reconcile to re-provision the route.
