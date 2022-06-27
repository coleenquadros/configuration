# Add a new AWS account to app-interface

This SOP describes adding a new AWS account to App Interface. This workflow applies when the following conditions are met:

1. You are onboarding a new service
1. The AWS account is for stage or production environments only

If your use case does not meet these criteria, please reach out to other App-SRE team members for further discussion.

## Prerequisites

In order to add a new AWS account to app-interface, you need a few things up front:

1. A new AWS account with admin level access created
1. A set of credentials and details to access the account, provided by the party responsible for creating the account. The account details should come as an encrypted message.
1. aws-cli installed locally
1. terraform CLI version matching the version used by Qontract-Reconcile (check `TERRAFORM_VERSION` [here](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/cli.py)). You can download Terraform from https://www.terraform.io/downloads.html.

Accounts can be created by creating a ticket in the [OHSS Jira project](https://issues.redhat.com/projects/OHSS/).
In a ticket specify that level of support need to be upgraded to Enterprise level. Detailed SOP [here](https://github.com/openshift/ops-sop/blob/master/v4/knowledge_base/aws-developer-accounts.md#requesting-an-account---outside-srep)

## Encrypted Account Details

The account details will include the following information:

* Account #, a.k.a. account uid
* Root administrator account, aka user
* password
* access key id
* secret access key

After decrypting the message, you'll see output similar to the following:

```
# staging
account #: 123456789

user: tpate
password: Password123
access key ID: AAAAAAAAAAAAAAAAAAAAA
secret access key: AAAAAAAAAAAAAAAAAAAAAA
```

# Walkthrough

Once you have decrypted the account details, the process is as follows:

1. Bootstrap terraform
1. Capture `terraform` user's access key and secret key via `terraform show`
1. [If user === existing app-sre username] Rename root administrator user
1. Create a vault secret with AWS credential information
1. Add the AWS account information to app-interface
1. Delete the original user account

## Bootstrap terraform

Follow the [Terraform init via terraform](docs/aws/terraform) instructions to set up the terraform AWS user and S3 bucket.

## Capture `terraform` user's credentials

In the same directory as the terraform bootstrap process, run

```
terraform show
```

and capture the access key ID and secret access key for the `terraform` user. If terraform apply ran properly, then a new AWS user, `terraform` will exist in the new account with Administrator privileges. We will use these secrets to populate Vault in a forthcoming step. After you have saved the secrets in vault, you should delete `terraform.tfstate` from your local directory.

## Rename root administrator user (if necessary)

In the case that the root username for the new AWS account is exactly the same as an existing App-SRE team member's username in app-interface, reconciliation will fail due to a naming collision. In this case, automated emails will NOT be sent to team members as expected. However, all of the encrypted passwords will still be available to access in app-interface-output after the merge.

In order to fix this potential issue, we can rename the original admin account after the `terraform` AWS user is created.

Using the aws-cli profile setup in the bootstrap terraform step, run the following:

```
AWS_PROFILE=<profile_name_here> aws iam update-user --user-name tpate --new-user-name temp-tpate
```

This will retain the root administrator account until no longer needed, and avoid naming collisions that will disrupt reconciliation.

## Create a vault secret with AWS credential information

The authentication information for AWS used by our integrations is located in [vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/terraform).  Each AWS account is a separate secret under this path.

* Before creating your new secret, view an existing terraform secret for another account. Click the "JSON" toggle, and copy the contents to your clipboard.
* Now, create a new secret with the following path: `app-sre/creds/terraform/<account_name>/config`.
* Toggle "JSON", and paste the copied contents to a new secret.
* Modify the copied contents, updating fields as necessary. See more detail below.
* Save the new secret.

### Updating secret fields

You can copy all the fields from another secret, updating the values of all keys to reference your new account name and new credentials.

Example:

```
{
  "aws_access_key_id": "<>",
  "aws_secret_access_key": "<>",
  "bucket": "terraform-image-builder-stage",
  "key": "image-builder-stage.tfstate",
  "region": "us-east-1",
  "terraform_aws_route53_key": "image-builder-stage-aws-route53.tfstate",
  "terraform_resources_key": "image-builder-stage.tfstate",
  "terraform_users_key": "image-builder-stage-users.tfstate",
  "terraform_vpc_peerings_key": "image-builder-stage-vpc-peerings.tfstate"
}
```

Set the `aws_access_key_id` key to `AccessKey` and the `aws_secret_access_key` to `SecretAccessKey` to the output recorded from `terraform show`, referencing the new `terraform` AWS administrator user.

The `bucket` key generally follows the convention of `terraform-<account_name>`, but can be any valid S3 bucket name. Usually, terraform state buckets are in the `us-east-1` region so it's okay to copy that value as is from another config. However, if the state bucket is to be in any other region then make sure to update the `region` key in the secret to the appropriate region and provide that region below when creating/updating the bucket.

## Add the AWS account information to app-interface

Now that the vault secret has been created and the S3 bucket created for terraform's state, we can add the aws account information into app-interface.

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
providerVersion: '3.75.2'

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

Create the group under `aws/<cluster>/groups/App-SRE-admin.yml`:

```yaml
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

Create the policy under `aws/<account>/policies/ManageOwnMFA.yml`:

```yaml
---
$schema: /aws/policy-1.yml

labels: {}

account:
  $ref: /aws/<aws_account>/account.yml

name: manage-own-mfa
description: |
  Allows a user to manage their own access MFA devices.
  ${aws:username} will be replaced with the actual user name

mandatory: true

policy:
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowViewAccountInfo",
        "Effect": "Allow",
        "Action": "iam:ListVirtualMFADevices",
        "Resource": "*"
      },
      {
        "Sid": "AllowManageOwnVirtualMFADevice",
        "Effect": "Allow",
        "Action": [
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice"
        ],
        "Resource": "arn:aws:iam::*:mfa/${aws:username}"
      },
      {
        "Sid": "AllowManageOwnUserMFA",
        "Effect": "Allow",
        "Action": [
          "iam:DeactivateMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ResyncMFADevice"
        ],
        "Resource": "arn:aws:iam::*:user/${aws:username}"
      },
      {
        "Sid": "DenyAllExceptListedIfNoMFA",
        "Effect": "Deny",
        "NotAction": [
          "iam:CreateVirtualMFADevice",
          "iam:ChangePassword",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ],
        "Resource": "*",
        "Condition": {
          "BoolIfExists": {"aws:MultiFactorAuthPresent": "false"}
        }
      }
    ]
  }

```

### Add AppSRE users

Lastly add the created admin group and policy to the [app-sre.yml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/app-sre/roles/app-sre.yml) role.

### Wait for the e-mails for access to the AWS account

Once the MR is merged with all the above changes, AppSRE members should receive e-mails with credentials to log into the AWS account.  The integration to watch for users to be added is the `terraform-users` integration.

### Deploy aws-resource-exporter, cloudwatch-exporter, and others

There are some metric exporters and alerts that need to be enabled on a per-account basis. Please see the notes below.

* [aws-resource-exporter](/data/services/observability/cicd/saas/saas-aws-resource-exporter.yaml) - if there will be AWS resources that we care about in the account, particularly RDS instances, then add the account to this file
  * To enable alerts associated with `aws-resource-exporter`, search app-interface for `accounts_with_aws_resource_exporter` and add the account to the list as appropriate 
* [cloudwatch-exporter](/data/services/observability/cicd/saas/saas-cloudwatch-exporter.yaml) - if there will be AWS resources that we care about having metrics available for alerting, again RDS instances in particular, then add the account to this file
  * To enable alerts associated with `cloudwatch-exporter`, search app-interface for `accounts_with_cloudwatch_exporter` and add the account to the list as appropriate

## Delete the original user account

After you have received your automated email, decrypted the contents, logged into the AWS console, and updated your password, you are almost done! (In case you did not receive an invitation email, read [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/aws/aws-management-console.md#how-do-i-sign-into-the-aws-management-console-for-the-first-time)).

Finally, we need to delete the original account used to bootstrap the AWS account.

* Log into the console
* Navigate to IAM > Users
* Look for the original account name, either as provided to you or the temp-<account> renamed version
* Delete the user (confirm by typing in the user name)
