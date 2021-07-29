# Adding resources in a different AWS region to a cluster

Access to resources in AWS, such as AWS, S3, etc, is facilitated through VPC peering connections and Route Table entries in AWS.  In order to access to a new region, both the new region and the region running the openshift cluster will need to have a peering connection created and Route Table modificationa.

An example of what these peering and route table entries looks like is the quay [doc](docs/quay/cluster-vpc-peering.md) on their peering setup.

## Region Subnets and Route Tables

The route tables route traffic to appropriate places based upon network CIDR.  By default it appears that each availability zone in a region and each region's default VPC are given the same network CIDR, thus the default VPCs in each region will all have the same IP space.  This is less than ideal for creating a peering connection.  While it is possible to setup the route tables to route to a subset of a CIDR where apps run, it is not advisable to do this with control over how resources will be assigned IPs.  Otherwise, if a resource dies and needs to be re-created there would be no guarantee the new resource will get an IP in the subset of the CIDR that will be routed to via the peering connection.  The safest path is to create new subnets and a new VPC if peering to a VPC that already has a peering connection setup.

## Creating a new VPC

Creating a new VPC for use in a VPC peering connection consists of 2 parts:

- Creating a new VPC
- Creating subnets within that VPC

First create a new VPC with a unique network CIDR.  Taking an existing VPC CIDR and incrementing the 2nd octet is a means to do this easily.  Make sure the new CIDR is unique.

Next you need to create new subnets in the new VPC for each availability zone.  Easiest thing to do is copy the ranges from the default VPC and increment the second octet to match your VPC.  Make sure to associate the subnet with the new VPC and the respective availability zone.

## Creating a VPC Peering Connection

NOTE: Peering connections are initiated by one side of the connection and accepted by the other.  To support future automation, all peering requests should be initiated from the `CLUSTER` VPC to the AWS region's VPC.

Creating the peering connection and route table entries requires a few steps:

- Assume the Network Management Role for the cluster you wish to configure
- Initiate the VPC Peering Connection from the cluster AWS account
- Modify the Route Table Entries in the cluster AWS account
- Accept the VPC Peering Request in the new AWS region
- Modify the Route Table Entries in the new AWS region

### Assuming the Network Management Role

In order to intiate the VPC peering connection and modify the route tables used by the openshift cluster you have to assume a role in AWS.  To do this, log into [OCM](https://console.redhat.com/openshift) and select the cluster you wish to modify.  In the cluster details there should be a tab called `Access Control`.  Select it and scroll down to the `AWS infrastructure access` section.  Look for the ARN that corresponds to your user account and find the role called `Network management`.  Click on `Copy URL to clipboard` and then go to the AWS console and log into the account where the new resources will be created.

Once logged into the AWS account, paste the `Network management` role link from OCM.  Click the `Switch Role` button and now you have access to modify the network configuration for the cluster AWS account.

### Initiating the VPC Peering Connection

In order to create a peering connection you will need to know 2 things:

- VPC ID you want to peer with
- Account ID where that VPC exists

Once you have assumed the `Network Management Role` in the AWS console, go to VPC->Peering Connections.  Select `Create Peering Connection`, give the connection a name, and select the VPC that will request the connection in the `Select a local VPC to peer with` section.  In the `Select another VPC to peer with` section, choose `Another Account` and enter the account ID that contains the VPC you created earlier.  If the VPC is in another region, then select `Another Region` and provide the region with the VPC created earlier.  Finally enter the ID of the VPC you created in the `VPC (Accepter)` field.  Finish by selecting `Create Peering Connection`.

### Creating Route Table Entries in the cluster AWS account

Once you have initiated the VPC Peering Connection you can setup route tables to route traffic to that connection.  To do this, go to VPC->Route Tables and you should see a list of existing route tables.  Find the one you want to modify that is associated with the VPC you peered with, and select it and go to the `Routes` tab.  Select `Edit Routes` and add a route for the network CIDR for the VPC and select the appropriate peering connection as the `Target`.  Peering connections start with the `pcx` identifier.

NOTE: Make a note of network CIDR for the `local` route entry.  This will be needed later when you create the route tables in the other VPC.

### Dropping the Network Management Role

Switch back to the AWS account with new resources by selecting the dropdown at the top of the page that highlights your account.  It should say something like `network-mgmt-xxxxx`.  In the drop down there should be an option similar to `back to xxxx` where xxxx is your user account.  Select that to return to your normal user account.

### Accept the VPC Peering Connection

Once you have dropped back to your normal user account, ensure you are working in the region you want to make available to the cluster and go to VPC->Peering Connections.  You should see the request for the peering connection you just made.  Select it and then choose `Accept Request` under the `Actions` dropdown.

### Creating Route Table Entries in the new AWS Region

As your normal AWS user, ensure you are working in the region you want to add to the cluster and go to VPC->Route Table.  Select the route table you want to modify and got to the `Routes` tab.  Select `Edit Routes` and add a route for the network CIDR for the VPC you are peering with and select the appropriate peering connection as the `Target`.  Peering connection start with the `pcx` identifier.  The network CIDR for the cluster nodes is usually something like `10.100.0.0/16`.
