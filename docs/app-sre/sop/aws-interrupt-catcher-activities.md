# AWS Interrupt Catcher activities

## Definitions

AWS `osio` account - The AWS account with ID [386414299200](https://386414299200.signin.aws.amazon.com/console). Used to contain production and development resources.

AWS `osio-dev` account - The AWS account with ID [619539278362](https://619539278362.signin.aws.amazon.com/console). A new account created to contain development resources.

## Background

We have been working on seperating development resources from production resources, in the attempt to remove all development resources in the `osio` account. The aim is to remove stale resources and to move others to the `osio-dev` account when requested.

## Purpose

This document aims to describe processes that has to be done manually from time to time in order to move resources from the `osio` account to the `osio-dev` account.

## Content

* DynamoDB cross account export
* Reset user AWS console password

### DynamoDB cross account export

#### Design

Taken from [the AWS developer guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBPipeline.html):

```
You can use AWS Data Pipeline to export data from a DynamoDB table to a file in an Amazon S3 bucket. You can also use the console to import data from Amazon S3 into a DynamoDB table, in the same AWS region or in a different region.
```

We will export a DynamoDB table from the `osio` account to an S3 bucket in the `osio-dev` account, from which developers can self service importing the data to their DynamoDB tables in the `osio-dev` account.

#### Setup

These documents explain the setup that was be done to allow this design:

1. [Exporting and Importing DynamoDB Data Using AWS Data Pipeline](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBPipeline.html)

2. [How can I create Data Pipeline cross-account access to DynamoDB and Amazon S3?](https://aws.amazon.com/premiumsupport/knowledge-center/data-pipeline-account-access-dynamodb-s3/)

The Terraform implementation can be found in the [housekeeping](https://gitlab.cee.redhat.com/dtsd/housekeeping) repository:

1. [osio account implementation](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/osio/dtsd/cross-account-policy.tf)

2. [osio-dev account implementation](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/osio-dev/dynamodb-backups.tf)

#### Process

In order to export a DynamoDB table from the `osio` account to an S3 bucket in the `osio-dev` account, follow these steps:

1. Login to the `osio` account AWS console. URL: https://386414299200.signin.aws.amazon.com/console.
2. Open the [Data Pipelines console](https://console.aws.amazon.com/datapipeline/).
3. Search for a pipeline with the name of the table you want to export. If a pipeline with that name exists, Activate it:
    * Mark the checkbox
    * Click `Actions` -> `Activate` -> `Activate from now` -> `Activate`

If a pipeline with the name of the table you want to export does not exist, create one:

* Note: for this example we will use `prod_txlog` as the name of the table to backup.

1. Click `Create new pipeline`:
    * `Name` - `prod_txlog`
    * `Source` - Build using a template, choose `Export DynamoDB table to S3`
    * `Source DynamoDB table name` - `prod_txlog`
    * `Output S3 folder` - `s3://dynamodb-migration-backups-osio/backups/prod_txlog`
    * `Run` - select `on pipeline activation`
    * `S3 location for logs` - `s3://dynamodb-migration-backups-osio/logs`
    ** DO NOT ACTIVATE YET ;) **
2. Click `Edit in Architect`.
3. Expand the `Activities` section.
4. From `Select an optional field` select `Post Step Command`.
5. In the `Post Step Command` inbox enter `aws s3 cp s3://dynamodb-migration-backups-osio/backups/prod_txlog/ s3://dynamodb-migration-backups-osio/backups/prod_txlog/ --recursive --acl bucket-owner-full-control --storage-class STANDARD`.
    * This is added because the we need to change ownership of the exported files to allow access to the `osio-dev` account users.
6. Click `Save`.
    * A warning with the text `Pipeline objects were saved, but there are validation warnings. You can still activate the pipeline.` will appear. This warning is because we are exporting the DynamoDB table to an S3 bucket in another account, which can not be validated.
7. Click `Activate`.
8. You can follow the pipeline. The expected result is `FINISHED`.

To see the exported backup files, follow these steps:

1. Login to the `osio-dev` account AWS console. URL: https://619539278362.signin.aws.amazon.com/console.
2. Open the [S3 console](https://console.aws.amazon.com/s3/).
3. Go to the `dynamodb-migration-backups-osio` bucket, to the path `backups/prod_txlog`.
4. A directory should exist with the timestamp of the data pipeline trigger.

#### Follow up

After the backups are exported to the `osio-dev` account, you can send the following instructions to the person who requested the backup:

```
I have created a backup of all the requested tables and used a Data Pipeline to have that backup created in the "osio-dev" account.

In order to restore the data to your tables, follow this manual:

https://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-importexport-ddb-part1.html

The bucket name which holds all the backups is called "dynamodb-migration-backups-osio" (you should have read access to it).

Good luck!
```

### Reset user AWS console password - user has resources in AWS

#### Design

If a user needs a reset of their AWS password, this will be done manually.

#### Process

* Note: in this example we will reset a user password in the `osio-dev` account.

1. Login to the `osio-dev` account AWS console. URL: https://619539278362.signin.aws.amazon.com/console.
2. Open the [IAM console](https://console.aws.amazon.com/iam/).
3. Go to `Users` -> relevant user -> Security Credentials
4. Select `Console Password` -> `Manage`.
5. Select `Set password` -> `Autogenerated password`.
6. Keep the password, encrypt it using the user's GPG key and send over by mail.


### Reset user AWS console password - user has **NO** resources in AWS

#### Design

If a user needs a reset of their AWS password, this will be done using automated processes via App-Interface.

Since a User is an (almost) idempotent entity in AWS, in order to reset a user password, we will remove their role for that AWS account, and restore that role afterwords. This will delete the user (without deleting any additional resources, apart for the users's access keys) and create a new user with the same ID, with a new randomly generated password.

#### Process

* Note: in this example we will reset a user password in the `osio` account.

1. Create a Merge Request in app-interface to remove the relevant role from the user file.
    * Example: https://gitlab.cee.redhat.com/service/app-interface/merge_requests/623
2. After merging the Merge Request (and after the jenkins job finishes), validate that the user no longer exists in the `osio` AWS account (under the [IAM console](https://console.aws.amazon.com/iam/)).
3. Create a Merge Request in app-interface to restore the relevant role to the user file.
    * Example: https://gitlab.cee.redhat.com/service/app-interface/merge_requests/624
4. After merging the Merge Request (and after the jenkins job finishes), validate that the user is present in the `osio` AWS account.

A new mail invitation is automatically sent the the user with the relevant information to login to the AWS console.
