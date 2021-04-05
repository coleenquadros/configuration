# Add a new AWS account to app-interface

In order to add an AWS account to app-interace, you need a few things up front:

1. An AWS account created
1. The `Account ID` for the AWS account
1. `AccessKey` and `SecretAccessKey` information for an admin user in that AWS account

The `Account ID` and the `AccessKey` and `SecretAccessKey` information should be provided by whomever creates the AWS account for us.  Usually SREP creates the AWS accounts for us.  Contact James Harrington (@jharrington on slack) for help if needed.

Once this information is obtained the process is basically a few steps:

1. Create a vault secret with AWS credential information
1. Create the terraform user for our integrations
1. Create an S3 bucket for terraform state
1. Add the AWS account information to app-interface
1. Update the credentials in vault to use those from the terraform user

## Create Vault secret

The authentication information for AWS used by our integrations is located in [vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/terraform).  Each AWS account is a separate secret under this path.  Create a new secret here named like:

```shell
app-sre/creds/terraform/<account_name>/config
```

You can copy all the fields from another secret except for the 3 fields that are unique: aws_access_key_id, aws_secret_access_key, bucket.  Those three keys must be specific to this AWS account. Set the `aws_access_key_id` key to the `AccessKey` and the `aws_secret_access_key` to the `SecretAccessKey` from the admin account provided by whomever setup the AWS account.  The `bucket` key generally follows the convention of `<account_name>-tf-state`, but can valid S3 bucket name.  Usually terraform state buckets are in the `us-east-1` region so it's okay to copy that value as is from another config.  However, if the state bucket is to be in any other region then make sure to update the `region` key in the secret to the appropriate region and provide that region below when creating/updating the bucket.

## Create the S3 terraform bucket

Use the aws cli to create the S3 terraform state bucket with versioning enabled:

```shell
aws --profile ocm-quay s3api create-bucket --bucket <bucket> --region <region>
aws --profile ocm-quay s3api put-bucket-versioning --bucket <bucket> --region <region> --versioning-configuration Status=Enabled
```

The `<bucket>` name and the `<region>` are the same as what was created in the vault secret in the previous step.

## Add the AWS account information to app-interface

Now that the vault secret has been created and the S3 bucket created for terraform's state we can add the aws account information into app-interface.  This combined with the role defintions will give users access to the AWS account.

### Create the AWS account yaml

All the AWS account information yamls are located [here](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/aws) in a separate directory for each aws account.  Create a new directory after the name of the AWS account.

Create an account.yml in the directory just created.

```yaml
aws/<cluster>/account.yml
---
$schema: /aws/account-1.yml

labels: {}

name: ocm-quay
description: App SRE AWS account for terraform integration development
consoleUrl: https://719609279530.signin.aws.amazon.com/console
uid: '719609279530'
resourcesDefaultRegion: us-east-1
supportedDeploymentRegions:
- us-east-1
- us-east-2
- us-west-1
providerVersion: '3.22.0'

terraformUsername: terraform

accountOwners:
- name: App-SRE Team
  email: sd-app-sre+ocm-quay@redhat.com

automationToken:
  path: app-sre/creds/terraform/ocm-quay/config
  field: all

premiumSupport: true
```

Update the `automationToken` field to point to the vault secret created earlier for this AWS account.  Also update the `uid` and `consoleUrl` fields with the AWS `Account ID` obtained from whomever created the AWS account.  Lastly, update the `name` in the yaml to be the name of the AWS account.

### Create AWS policies and groups

Access in the AWS account is controlled by the groups and policies definitions held in the `groups` and `policies` directories for that AWS account.

Create the group:

```yaml
aws/<cluster>/groups/APP-SRE-admin.yml

---
$schema: /aws/group-1.yml

labels: {}

account:
  $ref: /aws/<aws_account>/account.yml

name: App-SRE-admin
description: Admin group for App SRE team

policies:
- AdministratorAccess
```

Create the policy:
```yaml
aws/<cluster>/policies/BillingViewAccess.yml

---
$schema: /aws/policy-1.yml

labels: {}

account:
  $ref: /aws/<aws_account>/account.yml

name: BillingViewAccess
description: |
    Allows a user to view AWS billing related data

policy:
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                    "aws-portal:ViewAccount",
                    "aws-portal:ViewBilling",
                    "aws-portal:ViewPaymentMethods",
                    "aws-portal:ViewUsage"
            ],
            "Effect": "Allow",
            "Resource": "*"
            }
        ]
    }
```

### Add AppSRE users

Lastly add the created admin group and policy to the [app-sre.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/app-sre/roles/app-sre.yml) role.

NOTE: If the admin account provided by the AWS account creator is the same as your AppSRE account then you will need to follow a separate procedure to add all AppSRE users.  This is because the integration will fail when it tries to add your account and it already exists, which results in none of the accounts being added to the AWS account.  Follow [this](#special-case-for-user-as-admin) with an additional AppSRE team member to get things going.

```yaml
data/teams/app-sre/roles/app-sre.yml

---
$schema: /access/role-1.yml

labels: {}
name: app-sre

...
aws_groups:
- $ref: /aws/<aws_account>/groups/App-SRE-admin.yml

user_policies:
- $ref: /aws/<aws_account>/policies/BillingViewAccess.yml
```

### Wait for the e-mails for access to the AWS account

Once the MR is merged with all the above changes, AppSRE members should receive e-mails with credentials to log into the AWS account.  The integration to watch for users to be added is the `terraform-users` integration.

### Special case for user as admin

In this instance the admin account provided by the AWS account creator is one of the AppSRE members, so we need to add only 1 AppSRE user to the AWS account and do some slightly different steps.

Create a new role file in data/teams/app-sre/roles with only:

```yaml
---
$schema: /access/role-1.yml
labels: {}
name: app-sre

permissions: []

aws_groups:
- $ref: /aws/ocm-quay/groups/App-SRE-admin.yml

user_policies:
- $ref: /aws/ocm-quay/policies/BillingViewAccess.yml
```

Add this role to the compansion AppSRE user's file.  The AppSRE user will then be added to the AWS account as an admin and receive an e-mail for access, just like other aws account access.

Once this AppSRE team member has access to the AWS account, follow the steps to create the [terraform user](#create-terraform-user-account) and cycle credentials in vault.  Once the `terraform` user account has been created and the credentials updated in vault, delete the user account causing problems.

Now follow the steps to [add all AppSRE users](#add-appsre-users) to the aws account and remove the temporary role file created in step.

## Create terraform user account

At this point you should be able to log into the AWS account with your own credentials as an Admin user.  Create a user with the name `terraform` with AWS access type: `Programmatic access`.  On the set permissions screen select `Attach existing policies directly` and choose `AdministratorAccess`.  When this user is created an `AccessKey` and `SecretAccessKey` will the provided on screen.  Copy these values and replace them with the ones set in vault.
