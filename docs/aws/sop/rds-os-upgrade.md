# RDS Operating System Upgrades

RDS OS upgrades are typically required when there is a security update available. Sometimes these are "general improvements to security posture", but other times are they are associated with a critical security fix (CVE). Note that we may not always know the details of the CVE if it is embargoed. There are some important things to know about OS upgrades:

1. There may be a minimum required database engine minor version to apply the OS upgrade. This is typically covered in the documentation that AWS sends along with the notification.
2. As stated in the AWS docs, the OS upgrade will be applied to the standby instance first in the case of a Multi-AZ configuration. This means that any downtime should be minimized to the amount of time it takes to fail over from the primary to the standby.
3. A Multi-AZ fail over **will change the ip address that is resolved by the RDS DNS record**. It is worth being aware of this in case any services are not recovering in a timely fashion. The service might be trying to connect to the ip address of the original primary, or the DNS record could be cached.

## Manual Process

This is the manual process for applying a pending OS update maintenance action in RDS. Note that this is **NOT currently self-serviceable by AppSRE tenants**. The `apply_immediately` option in app-interface (and Terraform) only applies to pending modifications and not pending maintenance.

---

**This process will result in a brief period of downtime for Multi-AZ instances while the primary fails over. For databases not using Multi-AZ, this downtime can exceed 10 minutes.**

---

1. Check whether an OS upgrade is available for your database. If the `system-update` maintenance is not available, then you may need to perform a database minor version engine upgrade before upgrading the OS. Check the RDS documentation for more information.
   ```
   aws --profile <AWS_PROFILE_NAME> rds describe-pending-maintenance-actions --resource-identifier <DATABASE_ARN>
   ```
   Example output:
   ```
   {
    "PendingMaintenanceActions": [
        {
            "ResourceIdentifier": "arn:aws:rds:us-east-1:950916221866:db:dev-steahan",
            "PendingMaintenanceActionDetails": [
                {
                    "Action": "system-update",
                    "AutoAppliedAfterDate": "2022-01-10T00:00:00Z",
                    "ForcedApplyDate": "2022-03-30T00:00:00Z",
                    "CurrentApplyDate": "2022-01-10T00:00:00Z",
                    "Description": "New Operating System update is available"
                }
            ]
        }
    ]
   }
   ```

2. **Skip to the next step if an OS update is already available**. If it is not, and you have confirmed that a newer database engine minor version upgrade is required, then follow the steps for the [RDS database engine minor version upgrade SOP](/docs/aws/sop/postgresql-rds-instance-minor-version-upgrade.md). Once that is complete, you can repeat step 1 to verify that an OS update is available.
3. Schedule the OS upgrade by running the command below. This process can take up to 25 minutes to complete fully. Note that the actual downtime of the service should only be the time it takes to fail over from the primary to the standby if the RDS instance is configured to use Multi-AZ.
   ```
   # Run the upgrade during the next maintenance window:
   aws --profile <AWS_PROFILE_NAME> rds apply-pending-maintenance-action --resource-identifier <DATABASE_ARN> --apply-action system-update --opt-in-type next-maintenance
   
   # Start the upgrade immediately:
   aws --profile <AWS_PROFILE_NAME> rds apply-pending-maintenance-action --resource-identifier <DATABASE_ARN> --apply-action system-update --opt-in-type immediate
   ```
4. Check the status of the database using the command available. The upgrade will be complete when the status reads `available`.
   ```
   # Wait for this to be 'available', it will be 'upgrading' while the OS upgrade is occurring
   aws --profile <AWS_PROFILE_NAME> rds describe-db-instances --db-instance-identifier <RDS_INSTANCE_NAME> --query 'DBInstances[*].DBInstanceStatus' --output text
   ```
5. Confirm that the pending maintenance action is no longer available:
   ```
   aws --profile <AWS_PROFILE_NAME> rds describe-pending-maintenance-actions --resource-identifier <DATABASE_ARN>
   ```
