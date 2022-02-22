# Design doc: Self-service RDS upgrades and maintenance

## Author/date

Steve Teahan / 2021-12-08

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4169

## Problem Statement

There are currently 180 RDS instances managed in app-interface. Historically, when maintenance is required, such as OS upgrades or database engine version upgrades, the AppSRE team has managed the maintenance including sending emails to each team, making the changes in app-interface, and deciding when to perform the maintenance.

There are a number of problems with the current state of RDS maintenance:

1. The number of RDS instances could grow to 300-400 instances in the next 1-2 years. A single team managing the maintenance and upgrades of all of these databases does not scale well.
2. It is a "one size fits all" approach. Each service might have different maintenance windows based on when their peak load is, so it isn't ideal to upgrade them all at the same time. Likewise, some services might choose to perform optional upgrades more or less frequently (depending on the nature of the fixes).
3. Developers not being directly involved leads to less understanding of the changes that are happening to the database. Particularly with database engine version upgrades, there can be changes that can impact a service in non-obvious ways.
4. Related to #3, the AppSRE team cannot know how each database is used and whether a change in the release notes would impact a database or not
5. The approach is inconsistent with the self-service nature of AppSRE tooling:
   > Service owners agree to take ownership of the service instance through a self-service methodology via App-Interface. This includes service configuration, life-cycle management and provisioning and configuring service dependencies. - [source](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/service/self_service.md)

## Goals

1. Allow tenants to take control of when database minor version upgrades, OS upgrades, and other database modifications occur
2. Improve the security posture of AppSRE managed services by improving tenant awareness of available upgrades and maintenance
3. Improve the ability of the AppSRE team to scale, as the number of tenants increases, by continuing to promote a self-service model

## Non-objectives

1. Self-service major version upgrades might be best handled as a follow-up project. These upgrades are more involved and happen less frequently than database minor version upgrades, OS upgrades, and other maintenance tasks.
   * A team upgrading from Postgres 9.6 -> 12 would not need to upgrade again until the end of 2024, so we can assume major version upgrades are required every ~3 years on average

## Proposal

At a high-level, the proposal is to:

1. Clarify the responsibilities of the AppSRE team and tenants in an updated version of the AppSRE contract
2. Develop the tools, documentation, and processes required to enable the AppSRE team and tenants to be successful in meeting their responsibilities
3. Use existing functionality in RDS, wherever it makes sense to do so, instead of recreating a database management service

### RDS Responsibilities - AppSRE vs. Tenant

The following sections describe a proposal for the responsibilities of the AppSRE team and our tenants:

**AppSRE is responsible for...**
* developing tooling that will notify tenants of required and/or available RDS database upgrades, as well as enabling tenants to manage database minor version upgrades and OS upgrades in app-interface
* providing documentation that assists tenants in performing the previously mentioned RDS maintenance activities
* supporting tenants if issues arise during a RDS upgrade or maintenance activity
* tracking RDS database version compliance across the SD organization

**Tenants are responsible for...**
* completing RDS database upgrades and maintenance by the deadlines communicated by AppSRE
* testing their services to ensure that RDS database upgrades will not negatively affect service reliability
* ensuring that RDS database upgrades and maintenance are scheduled during appropriate times and notifying customers of the service

### Tenant Experience

The sections below attempt to describe how tenants would perform the different maintenance operations covered in this document. This is the most important part of the document because tenants will be responsible for managing these operations.

Most of the details of new integrations, or other open questions will be answered later in the document. This section provides just enough detail to understand the general process.

#### Minor version upgrade

This covers the case where a tenant is required to upgrade their database minor version (likely due to a security vulnerability). A tenant choosing to proactively upgrade their database would follow most of the same steps, although it would vary slightly (MRs wouldn't be created automatically).

1. Tenant receives an email from AWS RDS events indicating that a new minor version upgrade is available for their database(s). This happens for every minor version release whether AppSRE is requiring the upgrade or not.
2. AppSRE is made aware that the latest minor version release fixes a security vulnerability
3. AppSRE updates the supported AWS RDS versions list to indicate that anything older than version X.Y is no longer supported
4. The `rds-db-minor-version-upgrades` integration looks for any RDS instances not using an AppSRE approved version. A Jira ticket is created and assigned to the tenant indicating which databases need to be upgraded and what the minimum version requirement is.
5. Tenant reviews the Jira ticket and uses AppSRE documentation to create a MR to upgrade their database version
6. AppSRE approves the staging MR.
7. The staging database is upgraded, immediately if `apply_immediately` is set to `true`, otherwise during the next maintenance window.
8. Tenant receives an email from AWS RDS indicating that their database was upgraded and restarted. They can also confirm that the version is correct in the AWS console.
9. Tenant tests in the staging environment to confirm that there aren't any issues related to the database upgrade
10. Tenant uses AppSRE documentation to create a MR to upgrade their production database and confirms the version is the same as staging
11. AppSRE approves the production MR
12. The production databases are upgraded during the next maintenance window because `apply_immediately` should be set to `false`. TBD: do we also need to email the tenants so that they know exactly when the change is scheduled for?
13. Tenant receives emails from AWS RDS indicating that their database was upgraded, failed over, and restarted. TBD: if this fails, should an alarm trigger to AppSRE? Should the tenant team be notified via email? Should the tenant be monitoring this in the console?

#### OS upgrade

This covers the case where there is a mandatory OS upgrade, likely in response to a security vulnerability.

1. AppSRE sends an email to all tenants indicating that an OS upgrade is required (RDS doesn't appear to have an event for this, will confirm). This is meant to be an early notification and provide some background information.
2. Staging databases have OS upgrades scheduled immediately via the `rds-scheduled-os-upgrades` integration. Some jitter will be added so that all databases aren't upgraded at exactly the same time.
3. The `rds-scheduled-os-upgrades-mr` integration creates a MR for production databases that approves OS upgrades with the matching `CurrentApplyDate` and `ForcedApplyDate` (this is the closest that we can get to a unique identifier)
4. Tenant receives an emails from AWS RDS indicating that their database was restarted and patching is complete
5. Tenant tests in the staging environment to confirm that there aren't any issues related to the OS upgrade
6. Tenant reviews and approve the MR for their production RDS instance OS upgrades
7. AppSRE approves the production MR
8. The `rds-scheduled-os-upgrades` integration schedules the maintenance for the next maintenance window. TBD: should the integration also email the tenants so that there isn't any guessing about when it is scheduled?
9. The production database is upgraded during the next maintenance window
10. Tenant receives emails from AWS RDS indicating that their database failed over and that patching is complete

### RDS Maintenance Windows

Before discussing individual maintenance tasks, it is worth quickly covering maintenance windows. Each RDS database instance has a weekly maintenance window, of at least 30 minutes, during which maintenance operations. These operations can include database modifications such as engine versions or instance resizing, OS upgrades, or even replacing hardware. See [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Maintenance.html#Concepts.DBMaintenance) for more information about maintenance windows.

By ensuring that tenants have proper maintenance windows configured, AppSRE can let RDS do the work of scheduling maintenance operations. This has several advantages:

1. A manual step is removed from the process
2. Tenants can choose maintenance windows that align with when their applications are at the lowest utilization. There may be some caveats here, such as AppSRE deciding which maintenance windows are appropriate (only when IC is on duty?)
3. Avoids the pattern of performing maintenance on all, or many, of our services at the same time. This pattern will be increasingly difficult to support as the number of tenants increases.

#### Tracking RDS maintenance

One new problem introduced by the proposal above is tracking RDS maintenance. The AppSRE interrupt catcher may wish to view all RDS maintenance happening during their shift. This can be useful information so that we can be ready in case something were to go wrong during the maintenance.

There are a few different options here, they are listed below in order from simplest to most complex:

1. CLI tool - a simple CLI tool could leverage the AWS SDK to get a list of all pending maintenance over the next N hours. This would be very simple to implement.
2. Slack notifications - an integration could be added to send notifications to the IC for all RDS maintenance scheduled during their shift. Optionally, this could also send a message to a channel when database maintenance has started. This would take more time to implement because it would introduce a new integration.
3. Maintenance console - a page could be added to [visual app-interface](https://visual-app-interface.devshift.net/) that would show the maintenance across all accounts. This would involve adding new APIs and views to visual app-interface, so it would arguably take the longest time to implement.

In general, the problem of tracking RDS maintenance probably isn't the biggest issue. Historically, the team has not seen major issues with RDS maintenance operations, so it is unlikely that anyone would behave differently whether a maintenance operation was scheduled or not. It may be considered more of a nice-to-have.

I'd suggest that option #1 would be sufficient initially. Option #2 would add a lot of value because it can notify the team of maintenance that has started, as well as upcoming maintenance. That work could be considered as a follow-up task. Option #3 would probably only be worthwhile if it was a request by a tenant. Otherwise, AppSRE team members could use the CLI tool and save a significant effort in building a new UI view.

### Minor version upgrades

Minor version upgrades can be achieved by tenants today with a MR to the AppSRE team. With that being said, most (or all) tenants don't actually do the upgrades today because AppSRE has performed them in the past. There is an [existing process](docs/aws/sop/postgresql-rds-instance-minor-version-upgrade.md) for enabling minor version upgrades with app-interface. We would need better user-facing documentation, but essentially the process is the same. Teams would have a few choices:

1. Applying the minor version upgrade at the next maintenance window - this leaves the scheduling of minor version upgrades up to RDS and avoids the need to merge the app-interface MR exactly when the tenant wants the change to happen. This would result in fewer time-sensitive MRs because upgrades can be scheduled days ahead of time.
2. Applying the minor version upgrade immediately - using `apply_immediately`, a MR to app-interface can upgrade the database engine once the MR is merged and the chance has been reconciled. This can result in more time-sensitive MRs, so this might be best kept to staging databases only, where the change would not be time-sensitive.
3. Enable [automatic minor version upgrades](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_UpgradeDBInstance.Upgrading.html#USER_UpgradeDBInstance.Upgrading.AutoMinorVersionUpgrades) - this would be most appropriate for databases that are not mission critical and don't require testing a staging environment prior to deploying to production (probably not many, reporting databases?)

All the considerations above would be included in the user-facing documentation. Option #1 would be the best for production databases, #2 for staging databases, and #3 for reporting database (or others that aren't mission critical).

There are some gaps in the current minor version upgrade process that will need to be addressed:

1. There isn't a good way to communicate that minor version upgrades are available, or that databases have been upgraded successfully
2. AppSRE doesn't have a way to enforce that tenants use supported minor versions

The first gap is covered more generally in [Database maintenance notification section](#database-maintenance-notifications). The second gap is covered in the [Enforcing supported database versions](#enforcing-supported-database-versions) section below.

#### Enforcing supported database versions

There are two problems to solve related to supported database versions:

1. Tenants must be notified when a minor version of the database that they're using has security fixes that need to be applied
2. Tenants should be notified when a major version of their database will be deprecated. This provides the team with enough time to make their application compatible with a newer version. We might start with notifications every 90 days starting when the team is within 1 year of the EOL of the major version.

There are also several ways to approach this problem:

1. Add an integration that will automatically create a MR and assign it to the tenants for review and testing. GitLab is a tool that all of our tenants are expected to have access to. Creating 100+ MRs for each set of database upgrades may be a little "spammy", but this can be handled with appropriate filtering. This was suggested in [APPSRE-3280](https://issues.redhat.com/browse/APPSRE-3280).
2. Add an integration that will automatically create a ticket for the team to track resolving the issue. This may be easier said than done because it isn't clear that we have a single place where we can create a ticket for every team. This could be Jira, but not every team has a Jira project defined in app-interface.
3. Implement a "blocker" integration that will prevent a team from making other changes in app-interface if they're using an unsupported database version. This could technically be an addon to either option #1 or #2.

After a few discussions with the team, there is a preference for starting with the creation of Jira tickets (option #2). We can then decide whether it makes sense to add an opt-in enhancement that would automatically create MRs for teams to ease the burden of upgrades (option #1).

### OS Upgrades

OS upgrades are not as straight-forward as minor version upgrades because they aren't supported directly via Terraform. There are a few options here:

1. Allow RDS to perform the OS upgrades automatically, during a maintenance window, once the deadline for the upgrade has been reached. This is the simplest path from a development standpoint, but doesn't provide much control for development teams.
2. Add an app-interface schema option that will automatically schedule OS upgrades, as they become available, during the next maintenance window. This provides teams with more flexibility in scheduling, for instance the OS upgrade could be performed prior to the deadline defined by AWS. There isn't, however, a way to guarantee that a stage database would be upgraded before a production database. While OS upgrades should have minimal effect on RDS databases in most cases, it still isn't a bad practice to always perform the upgrades first in a stage environment.
3. An extension to the option above would have an `expirationDate` on the automatic scheduling of OS upgrades during maintenance windows. One way to do this would be to set automatic scheduling of OS upgrades without an expiration date on staging databases, but set an expiration date on production databases to significantly decrease the chances that more than one upgrade is applied. Upgrades don't have unique identifiers, so it'd be non-trivial to add an approval for a specific OS upgrade.

To err on the side of caution, it makes sense to avoid option #1. Even for something simple like an OS upgrade, it would be preferable to apply the change to staging environments first. Options #2 and #3 combined would likely be best, so that tenants can maintain more control over their production environments.

The automation associated with the selected options above could be introduced with a `rds-scheduled-os-upgrades` integration in qontract-reconcile.

### Database maintenance notifications

RDS supports [sending notifications via SNS topics](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.overview.html). Using this feature, we could allow tenants to get updates to their emails set in `serviceNotifications`.

Some notifications that would be helpful to send might include:

* The DB instance has a DB engine minor version upgrade available.
* Patching of the DB instance has completed. (OS upgrade complete)
* A Multi-AZ fail over has completed.
* The DB instance restarted.

A full list of notification types can be found [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.Messages.html).

These event subscriptions can be managed in Terraform with the [aws_db_event_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_event_subscription) resource. A default list of the most common useful notifications should be included for all RDS databases by default. This could be overridden with `event_categories` or `source_ids` parameters for teams that want additional notifications.

## Risks

The risks below will need to be accounted for during the next phase where we describe the implementation.

1. Tenants could ignore communications indicating that upgrades or maintenance are required.
2. Tenants could perform maintenance activities during AppSRE off-hours, which will need to be considered to ensure that we don't see more pages in the middle of the night.

## Open questions

1. How do we get Terraform to stop detecting changes if the database minor version has been scheduled to be changed during the next maintenance window?
2. Do we need to worry about enforcing minor version upgrades, or will AWS force minor version upgrades related to security fixes?
3. Does RDS have an event for OS upgrades so that tenants would be notified automatically?
4. Can multiple changes be scheduled in a single maintenance window? Do we need to worry about this?

## Schedule

AWS released a forced OS upgrade in November 2021. The original deadline was for January 2022, but they've since changed this deadline to June 2022. This provides AppSRE with a couple of months to work on the new process and then introduce it to teams in order to meet the deadline at the end of June. It is possible that future upgrades might have a shorter timeline, so this might be one of the best opportunities to introduce this process.

The phases below attempt to group features for certain milestones. This project would be fairly involved. Trying to release all the features at once would probably cause more disruption and delays in development.

**Phase One**

The first phase will focus on removing any blockers for tenants to start performing RDS minor version upgrades. The major deliverables are:

1. Improved user-facing documentation related to RDS minor version upgrades
2. Communication to teams that the June 2022 deadline for upgrading their databases is coming, they can get started now
3. Ensure that proper maintenance windows are configured as MR requests come in

**Phase Two**

The second phase will focus on improving the automation and tooling related to RDS minor version upgrades.

1. Update the contract to clarify AppSRE vs. tenant responsibilities for RDS (this might move to phase one)
2. Add the ability to create Jira tickets for databases that aren't compliant via the `rds-db-minor-version-upgrades` integration in qontract-reconcile
3. Configure default email notifications from RDS for all databases
4. Create CLI tool to show RDS scheduled maintenance across all accounts

**Phase Three and Beyond**

Plans are likely to change, so rather than make a plan that is likely to be wrong, these are some things that we can work on beyond the first two phases:

1. Support RDS OS upgrades via the `rds-scheduled-os-upgrades` integration in qontract-reconcile
2. Create user-facing documentation for RDS OS upgrades
3. Improving RDS maintenance visibility (Slack or visual a-i)
4. Improve tools used to enforce minor version upgrades (escalate to manager, InfoSec?)
5. Adding reporting tools related to the compliance of databases
6. Add the automatic creation of minor version upgrade MRs to the `rds-db-minor-version-upgrades` integration in qontract-reconcile

