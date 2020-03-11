# Quay OSD Cluster VPC Peering Setup

## Staging

### OSD Cluster Networking

- Machine CIDR: `10.100.0.0/16`
- Service CIDR: `172.30.0.0/16`
- Pod CIDR: `10.128.0.0/14`

### Quay AWS VPC

- VPC ID: `vpc-459ecf3f`
- Default VPC: `Yes`
- IPv4 CIDR: `172.31.0.0/16`
- Route table: `rtb-91cb17ef`
- Owner: `019044362261`

### Peering Connection (Quay AWS Account)

![](images/pcx-02e2e71bc0c849e57.png)

### Route Table (Quay AWS Account)

![](images/route-table.png)

### Peering Connection (OSD AWS Account)

![](images/pcx-02e2e71bc0c849e57-osd.png)

### Route Table (OSD AWS Account)

![](images/rtb-05b1b511167898254.png)

### Steps to setup VPC Peering

Ref: [AWS Documentation](https://docs.aws.amazon.com/vpc/latest/peering/working-with-vpc-peering.html)

1. From the AWS account that hosts the OpenShift Dedicated cluster, initiate a VPC Peering request to the Quay AWS account.
2. From the Quay AWS account, accept the peering request.
3. Update the route table in both accounts to send traffic for appropriate CIDR over the peering connection.

## Production

