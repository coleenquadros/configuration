- [Deploying a New OCM-Quay Cluster](#deploying-a-new-ocm-quay-cluster)
  - [Deploying a New Read-Write Cluster](#deploying-a-new-read-write-cluster)
  - [Deploying a New Read-Only Cluster](#deploying-a-new-read-only-cluster)
    - [Create a New Cluster](#create-a-new-cluster)
    - [Configure AWS for the Cluster](#configure-aws-for-the-cluster)
      - [Configure VPC Peering](#configure-vpc-peering)
        - [Create a VPC](#create-a-vpc)
        - [Creating the VPC Subnets](#creating-the-vpc-subnets)
        - [Modify the VPC Security Group](#modify-the-vpc-security-group)
        - [Create VPC Peering Connections](#create-vpc-peering-connections)
        - [Update the Routing Table](#update-the-routing-table)
      - [Create an RDS Subnet Group](#create-an-rds-subnet-group)
    - [Create a New Namespace File](#create-a-new-namespace-file)
      - [Update the Namespace File with AWS Resources](#update-the-namespace-file-with-aws-resources)
      - [Create the Openshift Resources](#create-the-openshift-resources)
    - [Deploy via Saasfile](#deploy-via-saasfile)
    - [Update DNS](#update-dns)
      - [Find the Quay ELB Endpoint](#find-the-quay-elb-endpoint)
      - [Create the DNS Record](#create-the-dns-record)
    - [Add Observability](#add-observability)
      - [Add Cloudwatch Exporter](#add-cloudwatch-exporter)
      - [Add Quay App Monitoring](#add-quay-app-monitoring)
      - [Add Quay Namespace to Monitored Namespaces](#add-quay-namespace-to-monitored-namespaces)

# Deploying a New OCM-Quay Cluster

OCM-Quay is a group of small quay clusters configured so that there is 1 read-write cluster for image pushes, and multiple read-only clusters to handle load and redundancy.  The read-write and read-only clusters are accessed via different DNS records.

## Deploying a New Read-Write Cluster

There should only be 1 write-only cluster in service at a time.  If more capacity is needed, scale up the number of nodes in the read-write cluster and deploy more quay pods.  This could cause connection/cpu/memory pressure on the RDS instance.  Look at the [CPU/Connection metrics](https://console.aws.amazon.com/rds/home?region=us-east-1#database:id=ocm-quay-production;is-cluster=false;tab=monitoring) for the RDS instance and determine if it can handle more load before scaling up the cluster and adding more quay pods.

## Deploying a New Read-Only Cluster

Each read-only cluster uses a local read-replica database so adding more clusters shouldn't negatively impact and other cluster while improving read operation capacity.

### Create a New Cluster

Follow the [cluster onboarding SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/app-interface-onboard-cluster.md) to create a new OSD cluster.  Make sure to choose the region appropriate for task this cluster will provide.  Ideally it should be in a region that does not contain another cluster to improve geographical resiliency.

Use <REPLACE WITH NODE SIZE> for the node size and create a cluster with <NUMBER> of nodes.

### Configure AWS for the Cluster

The cluster will require some setup before being ready to deploy resources into it.  VPC Peering will need to be configured no matter what, but if the new cluster is in a different region than the current [read-write cluster](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm-quay/namespaces/ocmquayrwp01ue1.yml#L11) then additional manual configuration is also required.

If the cluster is in a different region than the read-write cluster, these additional items need to be configured:

- A new VPC will need to be created
- New subnets within the VPC will need to be created
- A new RDS subnet group will need to be created
- A KMS key will need to be created (this should be done via app-interface)

#### Configure VPC Peering

The new OSD cluster must be peered with the ocm-quay AWS account in order to access redis, RDS, and other AWS resources.

If this cluster will be in a region other than where the master RDS resides then a new VPC and RDS subnet group will need to be created.  The VPC and subnet group need to exist in the ocm-quay AWS account and be in the same region as the OSD cluster.  The CIDR defined for the VPC must be unique and not used by any other VPC in the ocm-quay account nor in use by any VPC CIDR in any of the other OSD clusters.  The OSD VPC information can be determined by looking at the app-interface-output repo for the OSD cluster networks and looking at the [Network.VPC](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/clusters-network.md) column as well as by looking at other [VPC definitions](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/ocm-quay/vpcs) in use by other VPCs defined in the ocm-quay AWS account.

2 peering connections will need to be made with the ocm-quay AWS account.  One peering connection is to access the RDS instance.  This connection is between the OSD account and the ocm-quay account in the same region where the cluster resides.  The other peering connection is between the OSD account and ocm-quay account in the region where the redis instance resides.

##### Create a VPC

App-Interface does not support creating a VPC, so this must be done through the AWS Console.  Log into the [ocm-quay AWS account](https://719609279530.signin.aws.amazon.com/console), navigate to the [VPC](https://console.aws.amazon.com/vpc) section, and in the upper right hand portion of the screen will be text indicating which region you are currently working in.  Make sure this region is the same as the region where the OSD cluster was created.

Click on the `Create VPC` in the upper right portion of the screen.  Give the new VPC a name in the following format:

```shell
ocm-quay-<region>
```

So if the VPC is in the us-east-2 region, the VPC would be named `ocm-quay-us-east-2`.

Give the VPC a unique IPv4 CIDR with a /16 subnet.  You can find the existing VPC CIDRs in use by all OSD clusters by looking at the app-interface-output repo for the OSD cluster networks and looking at the [Network.VPC](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/clusters-network.md) column as well as by looking at other [VPC definitions](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/ocm-quay/vpcs/eu-west-1.yml) in use by other VPCs defined in the ocm-quay AWS account.

Under `IPv6 CIDR block` select `No IPv6 CIDR block` and the Tenancy should remain `Default`.

Once the VPC is created, create a new yaml in app-interface with the other VPCs used by ocm-quay.

##### Creating the VPC Subnets

App-Interface does not support creating subnets within a VPC, so this must be done manually through the AWS Console.  Log in to the [ocm-quay AWS account](https://719609279530.signin.aws.amazon.com/console) and navigate to the [VPC](https://console.aws.amazon.com/vpc) section, and in the upper right hand portion of the screen will be text indicating which region you are currently working in.  Make sure this region is the same as the region where the OSD cluster was created.

Click on the `Subnets` link on the left.  A new subnet will need to be created for each availability zone in the region.  Use the default subnets as a template for the number of subnets and for the CIDR for each subnet.  For example, if the region has 3 availability zones names region-1a, region-1b, and region-1c, then the default subnets will be something like this:

region-1a - 172.31.0.0/20
region-1b - 172.31.16.0/20
region-1c - 172.31.32.0/20

The last 2 octets and the subnet mask can be the same when creating the subnets for the new VPC.  The only difference would be the first 2 octest of the CIDR.

To create the subnets, click on the `Create subnet` link in the upper right.  From the `VPC ID` dropdown select the VPC created in the previous step.  Under the `Subnet settings` section give the subnet a name using the following format:

```shell
ocm-quay-<availability_zone>
```

So if the subnet is for the availablity zone us-east-2a, then the name would be `ocm-quay-us-east-2a`.

Under `Availability Zone` choose one of the options listed and then assign it a CIDR in the `IPv4 CIDR block` field.

Click the `Add new subnet` at the bottom and repeat the process for each availability zone in the region.  When finished, press the `Create subnet` button at the bottom right.

##### Modify the VPC Security Group

The default security group associated with the VPC that was just created will need to be modified to allow MySQL traffic from the OSD cluster.  This is a manual process done through the AWS Console.

Log in to the [ocm-quay AWS account](https://719609279530.signin.aws.amazon.com/console) and navigate to the [VPC](https://console.aws.amazon.com/vpc) section, and in the upper right hand portion of the screen will be text indicating which region you are currently working in.  Make sure this region is the same as the region where the OSD cluster was created.

On the left under `Security` is a link named `Security Groups`.  Click that to list the available security groups.  Find the security group that matches the VPC created above.  This can be done by looking at the `VPC ID` for the security group and verifying it matches the `VPC ID` for the VPC created above.  Once found, select the security group by clicking on the box to the left and then chose `Edit inbound rules` from the `Actions` drop down at the top right of the screen.

Click `Add rule` to add a rule and select Type `MYSQL/Aurora` with the `Source` field being `Custom` and the CIDR range for the pod network from the OSD cluster.  Finally add a `description` with the name of the cluster this rule is fori followed by the `-rds` extension.  Once done, click `Save rules` at the bottom right of the screen.

This process will need to be repeated for the security group in the same reqion as the elasticache instance.  Find the security group associated with the elasticache instance.  Edit the `Inbound rules` and add a new rule with Type `Custom TCP`, `Port Range` of 6379, and with the `Source` field being `Custom` and the CIDR range for the pod network from the OSD cluster.  Finally add a `description` with the name of the cluster this rule is fori followed by the `-redis` extension.

##### Create VPC Peering Connections

Once the VPC is created, create a VPC peer with us-east-1 (for a shared redis instance) and with the region with the OSD cluster.  This is an [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/openshift/ocmquayrop01ew1/cluster.yml#L59-70).

##### Update the Routing Table

AWS provides [docs](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-routing.html) on how to do this.  The manage_routes option in the VPC peering connection definition will create the routes in the routing table on the OSD side of the peering connection, so all that needs to be done is to manually create the route table entries in the ocm-quay AWS account route table for the region.

App-Interface does not support modifying the routing tables for the non-OSD account, so this must be done manually through the AWS Console.  From the [VPC](https://console.aws.amazon.com/vpc) sectione, click on the `Route Tables` link on the left.  Find the route table associated with the created VPC and select the box next to it.  Choose `Edit routes` from the `Actions` dropdown at the top of the screen.  Click the `Add route` button and in the `Destination` field enter the CIDR used by the vpc network in the OSD cluster.  The vpc network can be found in the [openshift cluster definition](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/openshift/ocmquayrop01ew1/cluster.yml#L53) in app-interface.  In the `Target` field, select the peering connection identifier from the dropdown list.  Peering connections start with the `pcx` prefix.  When finished, press the `Save routes` button at the bottom.

This same process will need to be done to allow access to the common AWS elasticache instance.  Find the route table associated with the elasticache instance.  Edit the routes and add the CIDR used by the vpc network in the OSD cluster in the `Destination` field and in the `Target` field add the peering connection from the dropdown list for the connection to the OSD cluster.

#### Create an RDS Subnet Group

App-Interface does not support creating a subnet group, so this must be done through the AWS Console.  AWS provides [docs](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html#USER_VPC.Subnets) on how to do this and what is occuring.

Log into the [ocm-quay AWS account](https://719609279530.signin.aws.amazon.com/console), navigate to the [RDS](https://console.aws.amazon.com/rds) section, and in the upper right hand portion of the screen will be text indicating which region you are currently working in.  Make sure this region is the same as the region where the OSD cluster was created.

Click the `Subnet groups` link on the left portion of the screen, and then the `Create DB Subnet Group` in the upper right portion of the screen.  Name this subnet group in the following format:

```shell
ocm-quay-<3 letter region>-rds-subnet-group
```

So if the cluster was in the us-east-2 region, the subnet group would be named `ocm-quay-ue2-rds-subnet-group`.  Under `VPC` choose the VPC created above, and in the `Add subnets` section, choose all the availability zones from the `Availability Zones` drop down, and then all available subnets from the `Subnets` dropdown.

Finally, hit the `Create` button to create the subnet group.

### Create a New Namespace File

Before deploying quay a new namespace with dependent resources will need to be created first.  This will need to be done in 2 steps, first create the terraform resources and then the openshift resources.

#### Update the Namespace File with AWS Resources

Create a new namespace file similar to [existing](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm-quay/namespaces/ocmquayrop01ew1.yml) namespace files, but only containing the terraform resouces.  There should be no openshift resources defined yet.  Make sure to name the RDS instance after the name of the cluster.  This is crucial in order to get the configuration correct.  Any read-replica created in a region other than where the master RDS resides will need to create a KMS key as well.

The RDS definition will need to point to a unique defaults file which uses the vpc and subnet group created above like [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/terraform/resources/ocm-quay/rds-read-replica-eu-west-1.yml#L14-15).  If the read-replica will be in a region other than the master instance, then the KMS key will need to be set in the namespace file like [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm-quay/namespaces/ocmquayrop01ew1.yml#L43-44).

Once this is merged and the AWS resources are created and the information updated in [vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/integrations-output/terraform-resources) it is safe to proceed to creating the openshift resources.

#### Create the Openshift Resources

Update the namespace file with the common [shared resources](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm-quay/namespaces/ocmquayrop01ew1.yml#L30-32).  This should be the last of the resources needed before deploying quay.

### Deploy via Saasfile

Once then terraform and openshift resources are created in the cluster, quay can be deployed via the [saasfile](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm-quay/cicd/saas/ocm-quay.yaml).  Add a new [target](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/ocm-quay/cicd/saas/ocm-quay.yaml#L88) for the new cluster and use the same ref and parameters as the other targets.

### Update DNS

Once all the pods in the new quay deployment are running, the DNS record for pulls will need to be updated to include the new cluster.  The DNS records for OCM-Quay are in app-interface [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/dns/q1w2.quay.rhcloud.com.yaml).

#### Find the Quay ELB Endpoint

The endpoint for the ELB servicing quay is needed in order to create a new DNS entry.  This can be found by logging into the OSD cluster that has quay deployed.  Click on `Networking` on the left to expand the section and then select `Services`.  Click on the `quay-load-balancer-proxy-protocol-service` entry and on the right in the `External load balancer Ingress points of load balancer` section is the endpoint for the ELB.  Use this value when creating the DNS record.

#### Create the DNS Record

Add a new record in this [section](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/dns/q1w2.quay.rhcloud.com.yaml) with a unique name that points to the ELB for the new cluster.

Then add a policy for that route below similar to the other read-only [policies](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/dns/q1w2.quay.rhcloud.com.yaml#L49-56)

### Add Observability

Each cluster needs to have observability configured.  OCM-Quay uses the same observability setup as quay.io.

#### Add Cloudwatch Exporter

Create a new [cloudwatch exporter](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/app-sre-observability-production.yml#L290) and [service monitor](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/openshift-customer-monitoring.app-sre-prod-01.yml#L198-203)for the new cluster.

#### Add Quay App Monitoring

Update the [openshift-customer-monitoring](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/openshift-customer-monitoring.ocmquayrop01ew1.yml) configuration file that was created for the cluster with the [quay app](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/namespaces/openshift-customer-monitoring.ocmquayrop01ew1.yml#L92-133) monitoring bits.

#### Add Quay Namespace to Monitored Namespaces

Add the new cluster to the list of [monitored-namespaces](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/roles/app-sre-osdv4-monitored-namespaces-view.yml#L68).
