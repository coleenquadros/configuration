# AWS Management Console FAQs

## How do I access the AWS Management Console?

There are several independent AWS accounts used across Red Hat and App-SRE tennants.

App-SRE managed AWS accounts/resources are represented [here](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/aws). More directions on setting this up are [here](https://gitlab.cee.redhat.com/service/app-interface#manage-aws-access-via-app-interface-awsgroup-1yml-using-terraform).

Within an AWS account file ([example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/account.yml)) you will find a `consoleUrl` (as well as account number as `uid`). Go to the appropriate `consoleUrl` in your web-browser to manage that account's AWS resources.

App-SRE managed AWS accounts are logged into using IAM (AWS Identity and Access Management) credentials. These accounts currently do not support Red Hat SSO.

Onboarding emails are automatically sent to team members when they are given IAM access to a particular AWS account for the first time via an App-Interface merge-request. These emails contain a 1-time-use password and directions for signing into an account for the first time. These emails contain the subject `Invitation to join the <service-name> AWS account`.

Be sure to check your inbox/archive/spam/filters/trash for these emails. These automated emails have been known to occasionally fail to be recieved via SMTP as is used today. There are plans to use SendGrid for these emails in the future.

If you lose or fail to receieve one of these AWS onboarding emails, you can fortunetly still sign into the Management Console for your AWS account all the same by following [these directions](#how-do-I-sign-into-the-aws-management-console-for-the-first-time).

## How do I sign into the AWS Management Console for the first time?

Ideally you would have receieved an automated onboarding email with directions for your AWS account as described [here](#how-do-i-access-the-aws-management-console).

If you do not have one of these emails for whatever reason, perform the following steps:
* Look at [this file](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/terraform-users-credentials.md)
* Identify the table row containing your `ACCOUNT` and `USER_NAME`
* Identify that table row's `CONSOLE_URL` (this is AWS Management Console URL that you will sign into once your have your decrypted 1-time-use password)
* Identify that table row's `ENCRYPTED_PASSWORD` (this is your AWS IAM account's 1-time-use password, but in an encrypted format that cannot be directly used as is)
* Base-64 decode your `ENCRYPTED_PASSWORD` (example: `echo $PASSWORD | base64 -d > /tmp/aws-encrypted-key`)
* Decrypt your base-64-decoded password using your GPG key (example: `gpg --decrypt /tmp/aws-encrypted-key`) (the output is your 1-time-use AWS IAM password)
* Use your Red Hat username and 1-time-use IAM password to sign into the appropriate AWS Management Console
* **Important**: Immediately setup MFA for your IAM account ([more info](https://source.redhat.com/departments/it/digitalsolutionsdelivery/it-infrastructure/ithci/cloud/docs/internal/how_to_setup_2_factor__multi_factor_authentication_mfa_in_aws))
