# RDS Instance already exists error for newly created instance

## Description

Creating a new Multizone (MZ) RDS instance can take a long time (like 40 minutes).
`terraform apply` has a timeout.
When terraform hits t/o on creation, the newly created instance won't be inside the tfstate.
Thus, any subsequent reconcile attempt will try to create the DB again, which will result in an
`DBInstanceAlreadyExists` error. 

## Recovery

We must import the new database into the terraform state

1. Disable terraform-resources integration in [unleash](https://app-interface.unleash.devshift.net)
1. Get a working config.tf via qr: `--dry-run terraform-resources --account-name <rds-aws-account> --print-to-file=/tmp/rdsfix/state.json`.
1. `terraform init`
1. `terraform plan` -> verify the plan is indeed trying to create the already existing db
1. `terraform import aws_db_instance.<rds-instance-name> <rds-instance-name>`
1. `terraform plan` -> verify the instance is now part of the state. Some attributes such as password might be added still by the plan, which is fine.
1. Enable terraform-resources again in unleash

