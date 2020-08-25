# Dynamodb Cross Account Export

## Design

Taken from [the AWS developer guide](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBPipeline.html):

```
You can use AWS Data Pipeline to export data from a DynamoDB table to a file in an Amazon S3 bucket. You can also use the console to import data from Amazon S3 into a DynamoDB table, in the same AWS region or in a different region.
```

We will export a DynamoDB table from the `osio` account to an S3 bucket in the `osio-dev` account, from which developers can self service importing the data to their DynamoDB tables in the `osio-dev` account.

## Setup

These documents explain the setup that was be done to allow this design:

1. [Exporting and Importing DynamoDB Data Using AWS Data Pipeline](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBPipeline.html)

2. [How can I create Data Pipeline cross-account access to DynamoDB and Amazon S3?](https://aws.amazon.com/premiumsupport/knowledge-center/data-pipeline-account-access-dynamodb-s3/)

The Terraform implementation can be found in the [housekeeping](https://gitlab.cee.redhat.com/dtsd/housekeeping) repository:

1. [osio account implementation](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/osio/dtsd/cross-account-policy.tf)

2. [osio-dev account implementation](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/osio-dev/dynamodb-backups.tf)

## Process

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

## Follow up

After the backups are exported to the `osio-dev` account, you can send the following instructions to the person who requested the backup:

```
I have created a backup of all the requested tables and used a Data Pipeline to have that backup created in the "osio-dev" account.

In order to restore the data to your tables, follow this manual:

https://docs.aws.amazon.com/datapipeline/latest/DeveloperGuide/dp-importexport-ddb-part1.html

The bucket name which holds all the backups is called "dynamodb-migration-backups-osio" (you should have read access to it).

Good luck!
```
