# Migrate RDS Instances Across AWS Accounts

This SOP documents steps to migrate RDS instance from source AWS account to target AWS account.

## Create Snapshot

1. Make sure the service using the RDS is not running
1. Create a Snapshot via the AWS console

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

If you want to keep the old RDS instance alive while ramping the replacement in the new account, apply the following changes

1. Introduce the new RDS instance in `externalResources` by copying the existing resource entry, but under a different provisioner (`account`) item and introduce the override to restore from a snapshot.
1. Make sure the old RDS instance gets a different `output_resource_name`, e.g. by adding an `-old` suffix to it
1. Make sure to use a RDS `defaults` file that fits the target AWS account. If you need to create one, make sure `db_subnet_group_name` and `vpc_security_group_ids` are set correctly. Have a look at other default files from the same account or find the subnet group name in https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/terraform and the security group ID in the AWS console.


```yaml
managedExternalResources: true

externalResources:
- provider: aws
  provisioner:
    $ref: /aws/<old-aws-account>/account.yml
  resources:
  - provider: rds
    identifier: <rds-indentifier>
    defaults: <rds-defaults-file>
    enhanced_monitoring: true
    output_resource_name: <OpenShift-Secret-Name>-old
    parameter_group: <rds-parameter-group>
- provider: aws
  provisioner:
    $ref: /aws/<new-aws-account>/account.yml
  resources:
  - provider: rds
    identifier: <rds-indentifier>
    defaults: <rds-defaults-file-for-new-account>
    overrides:
      snapshot_identifier: <snapshot-identifier-to-create-rds-instance-from>
    enhanced_monitoring: true
    output_resource_name: <OpenShift-Secret-Name>
    parameter_group: <rds-parameter-group>
```

This way the old RDS is still available and the access credentials can be found in `<OpenShift-Secret-Name>-old`.
This ensures a way back by getting rid the new RDS entry (don't forget about cleanup) and reverting the old
DBs `output_resource_name`.

## Cleanup

Once you verified that the migrated RDS instance works as expected, you can delete the old one.

1. Remove the old entry from `externalResources`
1. If the account has deletion enabled in `/aws/account-1.yml#enableDeletion`, the removal from `externalResources` is sufficient to dispose the RDS instance
1. ... if not, add a `deletionApprovals` entry to the source AWS account file. Pick an expirationDate that is just a bit in the future (e.g. 2 days)

```yaml
- type: aws_db_instance
  name: <rds-indentifier>
  expiration: 'yyyy-mm-dd'
```
