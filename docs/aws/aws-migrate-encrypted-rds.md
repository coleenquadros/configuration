# Migrate Encrypted RDS Instance Across Accounts

Few things to note:

1. This process will require downtime.
2. It takes about 3 hours total for the migration progress. This time can be longer depending on database size.

## Migration Use Cases

Most migration will be done when a new service or tenant is be onboard onto app-interface. Few reasons why existing resources will need to be migrated:

1. **Security** - Production resources need to be in an account where user access and resources are managed using app-interface and reconciled periodically.
1. **Reliability** - SRE team needs to ensure that resources are not modified outside of app-interface or accidentally deleted.
1. **CAPEX -> OPEX** - By keeping production resources in a separate account from development resources, we can accurately categorize the expenses as cost of goods sold (COGS) which helps Red Hat bottom line. As not all business units can have COGS expenses, Service Delivery can help with this.

## Step By Step Instructions

### Add the target account to a customer managed key

1. Log in to the source account, and then open the [AWS KMS console](https://console.aws.amazon.com/kms) in the same AWS Region as the DB snapshot.
1. Choose **Customer managed keys** from the navigation pane.
1. Choose the name of your customer managed key, or choose **Create key**, if you don't yet have one. For more information, see [Creating Keys](https://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html).
1. From the **Key administrators** section, **Add** the AWS Identity and Access Management (IAM) users and roles who can administer the AWS KMS key.
1. From the **Key users** section, **Add** the IAM users and roles who can use the customer master key (CMK) to encrypt and decrypt data.
1. In the **Other AWS accounts** section, choose **Add another AWS account**, and then enter the AWS account number of the target account. For more information, see [Allowing Users in Other Accounts to Use a CMK](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-modifying-external-accounts.html).


### Copy and share the snapshot

1. Open the [Amazon RDS console](https://console.aws.amazon.com/rds), and then choose **Snapshots** from the navigation pane.
1. Choose the name of the snapshot that you created, choose **Actions**, and then choose **Copy Snapshot**.
1. Choose the same AWS Region that your KMS key is in, and then enter a **New DB Snapshot Identifier**.
1. In the **Encryption** section, choose the KMS key that you created.
1. Choose **Copy Snapshot**.
1. [Share the copied snapshot](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ShareSnapshot.html#USER_ShareSnapshot.Sharing) with the target account.

### Copy the shared DB snapshot

1. Log in to the target account, and then open the [Amazon RDS console](https://console.aws.amazon.com/rds).
1. Choose **Snapshots** from the navigation pane.
1. From the **Snapshots** pane, choose the **Shared with Me** tab.
1. Select the DB snapshot that was shared.
1. Choose **Actions**, and then choose **Copy Snapshot** to copy the snapshot into the same AWS Region and with a KMS key from the target account.

### Create the Database Instance

1. After the DB snapshot is copied, you can use the copy to launch the instance. [Example MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/4846/diffs) that launches RDS instance from database snapshot.
