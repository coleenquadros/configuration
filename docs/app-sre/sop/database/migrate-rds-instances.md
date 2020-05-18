# Migrate RDS Instances Across AWS Accounts

This SOP documents steps to migrate RDS instance from source AWS account to target AWS account.

## Add the target account to a customer managed key

1. Log in to the source account, and then open the AWS KMS console in the same AWS Region as the DB snapshot.
1. Choose Customer managed keys from the navigation pane.
Choose the name of your customer managed key, or choose Create key, if you don't yet have one. For more information, see Creating Keys.
1. From the Key administrators section, Add the AWS Identity and Access Management (IAM) users and roles who can administer the AWS KMS key.
1. From the Key users section, Add the IAM users and roles who can use the customer master key (CMK) to encrypt and decrypt data.
1. In the Other AWS accounts section, choose Add another AWS account, and then enter the AWS account number of the target account. For more information, see Allowing Users in Other Accounts to Use a CMK.


## Copy and share the snapshot

1. Open the Amazon RDS console, and then choose Snapshots from the navigation pane.
1. Choose the name of the snapshot that you created, choose Actions, and then choose Copy Snapshot.
1. Choose the same AWS Region that your KMS key is in, and then enter a New DB Snapshot Identifier.
1. In the Encryption section, choose the KMS key that you created.
1. Choose Copy Snapshot.
1. Share the copied snapshot with the target account.

## Copy the shared DB snapshot

1. Log in to the target account, and then open the Amazon RDS console.
1. Choose Snapshots from the navigation pane.
1. From the Snapshots pane, choose the Shared with Me tab.
1. Select the DB snapshot that was shared.
1. Choose Actions, and then choose Copy Snapshot to copy the snapshot into the same AWS Region and with a KMS key from the target account.
1. After the DB snapshot is copied, you can use the copy to launch the instance.

## Create RDS Instance from Snapshot

```yaml
managedTerraformResources: true

terraformResources:
- provider: rds
  account: <aws-account>
  identifier: <rds-indentifier>
  defaults: <rds-defaults-file>
  overrides:
    snapshot_identifier: <snapshot-identifier-to-create-rds-instance-from>
  enhanced_monitoring: true
  output_resource_name: <OpenShift-Secret-Name>
  parameter_group: <rds-parameter-group>
```
