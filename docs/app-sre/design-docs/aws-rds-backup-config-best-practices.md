# Design doc: AWS RDS backup configuration best practices

## Author/date

steahan / March 2023

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-6574

## Problem Statement

The data stored in relational databases is often some of the most critical and privileged data that a company possesses. The loss of this data can range from an inconvenience to being catastrophic for a business.

AppSRE provides the ability for tenants to create RDS instances that support automated backups. While this is a great starting point, there are several problems that RDS does not solve. For instance, RDS does not:

1. enforce backup policies that align with how critical the data is to the business
2. prevent the deletion of backups along with the database itself

## Goals

* Add enforcement of best practices related to AWS RDS backups to app-interface

## Non-goals

* Other future enhancements in this space including, but not limited to:
  * Testing RDS backups
  * Multi-region or multi-account backups
  * Backup methods not managed by RDS

## Proposal

### RDS backup best practices enforcement

A combination of bad default settings in the AWS Terraform provider and copying other tenants' configurations could lead to unexpected behavior related to backups. For instance, consider the following:

* `delete_automated_backups` is `true` in the AWS provider by default, meaning that if a RDS instance is deleted, so are all automated backups
* `skip_final_snapshot` is often set to `true` by tenants so that if a database is deleted, a snapshot is not taken

The combination of the two settings above makes it easy for someone to accidentally remove a RDS instance and delete all the data with it includes all backups. Additionally, the default for `backup_retention_period` is 0, which disables backups altogether.

The proposal would be to use a new `data_classification` schema field, with a `loss_impact` child field, to prevent settings that don't meet the **minimum requirements for that classification**. An example of the new schema can be seen below:

```yaml
  - provider: rds
    identifier: some-database
    defaults: /terraform/resources/gabi/rds-stage-1.yml
    # New optional field
    data_classification:
      loss_impact: high
```

This `loss_impact` field would describe at a high-level how impactful it would be to lose this data. This can help to enforce the settings in the table below. Note that another opportunity to use `data_classification` could be a `security` field that contains the security data classification, which could provide data about minimum security requirements (encryption at rest, in transit). This is outside the scope of this document, but worth mentioning why `loss_impact` is a child of `data_classification`.

| loss_impact | allow delete_automated_backups | allow skip_final_snapshot | minimum backup_retention_period | description                                                                                   |
|-------------|--------------------------------|---------------------------|---------------------------------|-----------------------------------------------------------------------------------------------|
| high        | no                             | no                        | 7                               | Loss of data would have severe consequences to Red Hat                                        |
| medium      | yes                            | no                        | 7                               | Loss of data would have some consequences to Red Hat and/or customers, but could be tolerated |
| low         | yes                            | yes                       | 3                               | Loss of data would be an inconvenience                                                        |
| none        | yes                            | yes                       | 0                               | Loss of data would have no consequences                                                       |

Any configurations for a RDS instance would need to meet these minimum requirements. The settings could still exceed the requirements. For instance, a RDS instance configured with `loss_impact` of `high` could set `backup_retention_period` to `14`, but if it was set to `6`, the **change would fail validation**.

#### What do these settings protect against?

1. Setting `backup_retention_period` to >0 prevents teams from accidentally disabling backups
2. Disabling `skip_final_snapshot` ensures that a user cannot delete a database in app-interface without taking a final snapshot, but they could still skip the final snapshot if deleting the database directly (AWS console/API)
3. Disabling `delete_automated_backups` ensures that deleting a database in app-interface, or through the AWS Console/API, would still retain backups, unless this setting was also **changed manually before deleting the database**

So, with all the settings above, we can guarantee that we have backups, and that an accidental deletion in either app-interface or directly (AWS Console/API) would never result in backups being deleted, unless **the deletion was done by malicious actors with knowledge of AWS**. In such cases, additional protections would require storing backups in different accounts, [covered in later sections](#other-good-ideas-for-the-future).

#### Implementation

The `terraform-resources` integration will validate RDS backup configurations against the `loss_impact` schema field. The integration will throw an error and fail the integration for any cases where the minimum settings associated with `loss_impact` haven't been satisified. The integration failure will allow for enforcing the desired values for changes in merge requests.

**Pros**
* Simple and low level of effort to implement
* The feature can be introduced and more data can be collected to feed into other long-term solutions (see [OPA](#open-policy-agent-opa))

**Cons**
* Best practice configuration policies cannot easily be changed, or disabled, on a per-environment setting
* If implemented for many resource types, the code could grow quickly

#### Rolling out schema changes and enforcement

The `loss_impact` field would be optional to start. We'd target tenant services that are most critical to the business to start and then eventually roll it out for all other teams, finally making this a required field.

### Alternatives considered

#### Open Policy Agent (OPA)

There have been discussions about using [Open Policy Agent](https://www.openpolicyagent.org/) (OPA) in app-interface to enforce policies (see [APPSRE-6660](https://issues.redhat.com/browse/APPSRE-6660)). This would be a more general solution that wouldn't be limited only to RDS backup configuration best practices. With that being said, it isn't clear that it makes sense to slow down work on addressing the more immediate issues around best practices for RDS backups to push for the long-term solution. In theory, we can later switch to OPA enforcing the best practices without any schema changes.

**Pros**
* Allows for different rules for different app-interface environments (commercial vs. FedRAMP)
* Allows enforcement of best practices well beyond RDS backup configurations

**Cons**
* Level of effort is seemingly much higher, would slow down the more immediate benefits of RDS backup configuration safety

#### Best practice default files

`defaults` files could be used in a more meaningful way to share best practice configurations. Today, most teams simply create their own defaults files and don't benefit from any shared best practices.

For example, we could a defaults files like:

* `/terraform/resources/sre-best-practices/rds-prod-1.yml`
* `/terraform/resources/sre-best-practices/rds-prod-read-replica-1.yml`
* `/terraform/resources/sre-best-practices/rds-stage-1.yml`

These could contain all the best practices that we suggest teams use.

**Pros**
* Teams don't need to think about the best practices as they're mostly done for them
* Must simpler to implement than enforcement of policies

**Cons**
* These best practices can be overridden with `overrides` which could result in harmful values being re-introduced (especially if copied from other teams without understanding)
* The number of permutations of best practice settings could grow a lot between stage and production, primary vs. replica, and other distinctions

#### Set values based on `loss_impact`

Rather than validate configurations based on the `loss_impact` field, we could use this field to automatically configure the best practices. For instance, if `loss_impact` is set to `high`, then `backup_retention_period` would be set to `7`, `delete_automated_backups` would be disabled, etc.

**Pros**
* Teams don't need to think as much about backup best practices because they'll be set for them

**Cons**
* Too many features like this can result in it being difficult to figure out where a setting originates from
  * `defaults` and `overrides` already provide two different sources for a configuration, now `data_classification` would be yet another
* Some flexibility in these configurations, particularly `backup_retention_period` is not a bad thing because there isn't a one size fits all approach

## Milestones

The features described here would be targeted for Q2 2023. Other enhancements beyond the scope of this document can be planned based on a broader initiative related to cloud resource best practices.
