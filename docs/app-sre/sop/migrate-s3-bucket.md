# Migrate S3 bucket across AWS Accounts

This SOP documents steps to migrate an S3 bucket from source AWS account to a destination AWS account.

## Considerations
The data transfer from bucket to bucket is a repeatable process. Considering the amount of data to be transfered, it will be meaningful to do an initial sync while the service using the bucket is still running. A differential resync after the service shutdown will be a lot faster.

Also consider data transfer costs. Keeping data transfer within a region reduces cost. Using a Pod on a cluster or an EC2 instance (e.g. ssh bastion.ci.ext.devshift.net) is a valid way to achieve that.

## Prerequisites
In order to copy data from one bucket to the other, the AWS CLI can be used. Since we enforce MFA for account access, make sure to have an MFA device attached to your user.
Also make sure your AWS cli setup allows you to get STS session tokens.

* [How to setup MFA for your AWS user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html#enable-virt-mfa-for-iam-user)
* [How to get a session token](https://docs.aws.amazon.com/cli/latest/reference/sts/get-session-token.html) and [how to setup the ENV vars or a credentials file profile](https://docs.aws.amazon.com/cli/latest/topic/config-vars.html?highlight=aws_session_token#credentials)

## Source Bucket

Log into the source AWS account, and attach a bucket policy to the source S3 bucket to grant your $USER in the destination account read permissions on it.

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DelegateS3Access",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::$DESTINATION_ACCOUNT_ID:/user/$USER"
            },
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
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
