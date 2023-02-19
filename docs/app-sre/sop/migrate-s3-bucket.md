# Migrate S3 bucket across AWS Accounts

This SOP documents steps to migrate an S3 bucket from source AWS account to a destination AWS account.

## Considerations
The data transfer from bucket to bucket is a repeatable process. Considering the amount of data to be transfered, it will be meaningful to do an initial sync while the service using the bucket is still running. A differential resync after the service shutdown will be a lot faster.

Also consider data transfer costs. Keeping data transfer within a region reduces cost.
Using a Pod on a cluster, an EC2 instance (e.g. ssh bastion.ci.int.devshift.net) or AWS CloudShell is a valid way to achieve that.

If you are migrating a bucket from one account to another and decide to keep the same bucket name, there is a AWS deletion queue that happens in the background once you remove a bucket. That name is part of this queue and it can take anywhere from a few minutes to a couple of hours for that name to be out of the queue and ready to be reused again.

## Prerequisites
In order to copy data from one bucket to the other, the AWS CLI can be used. Since we enforce MFA for account access, make sure to have an MFA device attached to your user.
Note Yubikey is not supported directly in cli, so another virtual device (Authenticator app) is needed.
Also make sure your AWS cli setup allows you to get STS session tokens.

* [How to setup MFA for your AWS user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html#enable-virt-mfa-for-iam-user)
* [How to get a session token](https://docs.aws.amazon.com/cli/latest/reference/sts/get-session-token.html) and [how to setup the ENV vars or a credentials file profile](https://docs.aws.amazon.com/cli/latest/topic/config-vars.html?highlight=aws_session_token#credentials)

For easy login AWS, can use some handy tools like [AWSume](https://awsu.me/).

Or use [AWS CloudShell](https://aws.amazon.com/cloudshell/), it has AWS cli ready to use without any further config.

## Create New Bucket

If you want to keep the old bucket alive while migrating data, apply the following changes

1. Introduce the new s3 bucket in `externalResources` by copying the existing resource entry, but under a different provisioner (`account`) item.
1. Make sure the new s3 bucket gets a different `identifier` and `output_resource_name`, e.g. by adding an `-new` or version (`-v1`) suffix to it.

```yaml
managedExternalResources: true

externalResources:
- provider: aws
  provisioner:
    $ref: /aws/<old-aws-account>/account.yml
  resources:
  - provider: s3
    identifier: <old-bucket-identifier>
    defaults: <s3-defaults-file>
    output_resource_name: <bucket-secret-name>
- provider: aws
  provisioner:
    $ref: /aws/<new-aws-account>/account.yml
  resources:
  - provider: s3
    identifier: <new-bucket-identifier>
    defaults: <s3-defaults-file>
    output_resource_name: <bucket-secret-name>-new
```

## Source Bucket

Log into the source AWS account, and attach a bucket policy to the source S3 bucket to grant your $USER in the destination account **read only permissions** on it.

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DelegateS3Access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::$DESTINATION_ACCOUNT_ID:user/$USER"
            },
            "Action": [
                "s3:GetObject",
                "s3:GetObjectTagging",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::$SOURCE_BUCKET_NAME/*",
                "arn:aws:s3:::$SOURCE_BUCKET_NAME"
            ]
        }
    ]
}
```

If there is already a bucket policy defined via app-interface, this needs to be added to the `bucket_policy` section of the bucket defintion in `externalResources`. Otherwise terraform will remove it during the next integration run.

## Copy process
Make sure you have valid credentials (session token) for the destination AWS account in your shells ENV or as a profile in your AWS credentials file.

```bash
aws [--profile $your-profile] s3 sync s3://$SOURCE_BUCKET_NAME s3://$DESTINATION_BUCKET_NAME
```

## Switch

1. Stop services writing to old bucket
2. Rerun copy process again to ensure all data migrated
3. Switch `output_resource_name` by updating `output_resource_name` of new bucket to the old one, and adding a `-old` suffix to the old bucket
4. Start services again (revert step 1)

```yaml
managedExternalResources: true

externalResources:
- provider: aws
  provisioner:
  $ref: /aws/<old-aws-account>/account.yml
  resources:
    - provider: s3
      identifier: <old-bucket-identifier>
      defaults: <s3-defaults-file>
      output_resource_name: <bucket-secret-name>-old
- provider: aws
  provisioner:
  $ref: /aws/<new-aws-account>/account.yml
  resources:
    - provider: s3
      identifier: <new-bucket-identifier>
      defaults: <s3-defaults-file>
      output_resource_name: <bucket-secret-name>
```

## Cleanup

Before the source bucket can be cleaned up, make sure that:
* all objects are deleted from it
* all versioned objects are deleted from it (they are only shown when the respective flag in the object list is set)
* it has no bucket policy attached

To delete the bucket (and all correlated IAM resources), follow these steps:

1. Remove the old S3 bucket from `externalResources`
1. If the account has deletion enabled in `/aws/account-1.yml#enableDeletion`, the removal from `externalResources` is sufficient to dispose the S3 bucket
1. ... if not, add a `deletionApprovals` entry to the source AWS account file. Pick an expirationDate that is just a bit in the future (e.g. 2 days)

```yaml
- type: aws_s3_bucket
  name: $SOURCE_BUCKET_NAME
  expiration: 'yyyy-mm-dd'
- type: aws_iam_user_policy
  name: $SOURCE_BUCKET_NAME
  expiration: 'yyyy-mm-dd'
- type: aws_iam_user
  name: $SOURCE_BUCKET_NAME
  expiration: 'yyyy-mm-dd'
- type: aws_iam_access_key
  name: $SOURCE_BUCKET_NAME
  expiration: 'yyyy-mm-dd'
```
