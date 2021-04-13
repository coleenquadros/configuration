# Deploy Quay from scratch

## Pre-requisites

In order to create a configuration file for quay, RDS, Elasticache, ACM and CloudFront/S3 must be configured and accesible in cluster.

## Create SSL certs

## Prepare Quay Database

### Create the Database

### Create Users

Need to create read-write and read-only users and read-only keypair

## Create IAM user for quay

## Create CloudFront Signing Keys

The cloudwatch signing keys are needed to sign URLs. Follow the [Create a key pair for a trusted key group](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html) section to create a key pair to use with CloudFront.  In the AWS Console, go to the `CloudFront` area and under `Key Management` select `Public Keys`.  Click the `Add public key` button at the top and create a new public key to use with CloudFront.  Give it a name and in the `Key value` field paste the contents of the public key file you just created.

Store the `ID` for the public key in vault in the `quay-additional-config` secret with the key `cloudfront_key_id`.  Here is an [example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/quay-additional-config).

Store the public_key in vault in the `quay-additional-config` secret with the key `cloudfront_public_key_pem`.

Store the private key in vault in the `quay-config-secret` secret with the key `cloudfront-signing-key.pem1.  Here is an [example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/quay-config-secret).

### Attach Signing Key to Cloudwatch Distribution

In order for cloudfront to use the public key created above we need to associate the key with the cloudfront distribution.  This currently must be done in the AWS console until terraform supports it.  See: https://github.com/hashicorp/terraform-provider-aws/pull/18644

In the AWS console go to the `CloudFront` area and click on the `Distributions` section on the left.  Choose the CloudFront Distribution to be modified by clicking on the `ID` field.  Go to the `Behaviors` tab and select the listed behavior and `Edit` it.  Look for the `Restrict Viewer Access (Use Signed URLs or Signed Cookies)` section and select `Yes`.  This will create a new section called `Trusted Key Groups or Trusted Signer`.  Select `Trusted Key Groups` and choose the created key group from above in the drop down list then press `Add` next to the field.  The key group should then appear just below in the `Trusted Key Group Name` area.  When done, press the `Yes, Edit` button at the bottom of the screen.

## Create a configuration file

## Create syslog-cloudwatch-bridge IAM user

The `syslog-cloudwatch-bridge` is used to push logs from the quay pods into cloudwatch.

### Create an IAM Policy

In the AWS IAM console, go to the `Policies` section and press the `Create policy` button.  Select the `JSON` tab and enter this:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
```

In the reveiw section, give the policy the name `syslog-cloudwatch-bridge`.

### Create IAM User

In AWS IAM console, go to the `Users` section and press the `Add user` button at the top to create a new IAM user.  `User name` should be `syslog-cloudwatch-bridge` and select `Programmatic access` for the `Access type`.  Select `Attach existing policies directly` and select the `syslog-cloudwatch-bridge` policy created above.  Click through the remaining screens to create the user.

Copy the `Access key ID` and `Secret access key` to [vault](https://vault.devshift.net) in a secret named `quay-cloudwatch-iam-user` with the following keys:

  ```shell
  AWS_ACCESS_KEY_ID: `<Access key ID from AWS>`
  AWS_REGION: `us-east-1`
  AWS_SECRET_ACCESS_KEY: `<Secret access key ID from AWS>` 
  LOG_GROUP_NAME: `<log group to use in cloudwatch>`
  ```

This secret is usually stored in a cluster specific path like `app-interface/quayio-prod-us-east-1/quay/quay-cloudwatch-iam-user`.  Here's an [example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/quay-cloudwatch-iam-user).

This secret will then need to be applied to the namespace where the quay pods will reside.  Like [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/quayio/namespaces/quayp05ue1.yml#L63).

And lastly the name of the secret needs to be set in the saasfile like [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/quayio/saas/quayio.yaml#L64).

## Deploy via saasfile
