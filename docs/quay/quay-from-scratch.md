# Deploy Quay from scratch

## Pre-requisites

In order to create a configuration file for quay, RDS, Elasticache, ACM and Cloudfront/S3 must be configured and accesible in cluster.

## Create a configuration file

## Create a Policy

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

## Create a Cloudwatch IAM User

In AWS IAM console, go to the `Users` section and press the `Add user` button at the top to create a new IAM user.  `User name` should be `syslog-cloudwatch-bridge` and select `Programmatic access` for the `Access type`.  Select `Attach existing policies directly` and select the `syslog-cloudwatch-bridge` policy created above.  Click through the remaining screens to create the user.

Copy the `Access key ID` and `Secret access key` to [vault](https://vault.devshift.net) in a secret named `quay-cloudwatch-iam-user` with the following keys:

  AWS_ACCESS_KEY_ID: `<Access key ID from AWS>`
  AWS_REGION: `us-east-1`
  AWS_SECRET_ACCESS_KEY: `<Secret access key ID from AWS>` 
  LOG_GROUP_NAME: `<log group to use in cloudwatch>`

This secret is usually stored in a cluster specific path like `app-interface/quayio-prod-us-east-1/quay/quay-cloudwatch-iam-user`.  Here's an [example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/quay-cloudwatch-iam-user).

This secret will then need to be applied to the namespace where the quay pods will reside.  Like [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/quayio/namespaces/quayp05ue1.yml#L63).

And lastly the name of the secret needs to be set in the saasfile like [this](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/quayio/saas/quayio.yaml#L64).

## Deploy via saasfile
