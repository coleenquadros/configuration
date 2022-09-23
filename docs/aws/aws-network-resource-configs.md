# AWS Network Resource Configurations

This document will track any specific network configurations that need to be chosen when
creating new AWS resources. These options often include security groups or
service-specific subnet groups. Accounts will only be listed here if there is ambiguity
in which resource
to select. This often occurs if multiple VPCs and network resources exist in a given
account.

## insights-stage account

The insights-stage account was originally created with a /24 CIDR in the VPC, which limits
the available ip addresses to ~250. A new VPC was added to allow sufficient room for growth.

| Resource type                  | Value                 |
|--------------------------------|-----------------------|
| RDS db_subnet_group_name       | insights-subnet-group |
| RDS security_group_ids         | sg-0ed866f3640635a8b  |
| Elasticache subnet_group_name  | insights-subnet-group |
| Elasticache security_group_ids | sg-0500a5b5cc46fc4db  |


## insights-prod account

The insights-prod account was originally created with a /24 CIDR in the VPC, which limits
the available ip addresses to ~250. A new VPC was added to allow sufficient room for growth.

| Resource type                  | Value                 |
|--------------------------------|-----------------------|
| RDS db_subnet_group_name       | insights-subnet-group |
| RDS security_group_ids         | sg-03c8ee3586a6aa74a  |
| Elasticache subnet_group_name  | insights-subnet-group |
| Elasticache security_group_ids | sg-044b578658f6ec3cf  |
