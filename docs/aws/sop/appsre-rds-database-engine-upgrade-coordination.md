# AppSRE RDS database engine upgrade coordination

This SOP covers the coordination tasks required by the AppSRE team when RDS database
engine versions need to be upgraded.

## Create a tracking epic

An epic should be created to track the effort of coordinating the upgrades. Tenants
should be able to self-service upgrades, but there is still effort related to
communicating what needs to be done, updating alerts, etc.

* Create the epic in the **SDE** project
* Name the epic: RDS Upgrades - $DEADLINE_MONTH $DEADLINE_YEAR
    * ex: RDS Upgrades - January 2024
* Create the following tickets
    * Update RDS approved versions documentation
    * Notify tenants of required RDS upgrade
    * Update RDS approved version alerts
    * Last reminder for RDS upgrades

This is a starting point for the work that will need to be done. There may be some other
work involved such as:

* Some tenants have historically required some assistance with reviewing the steps to be
  performed and/or want someone from AppSRE available during upgrades. This may change
  in the future, but for now this has been the case for Quay and OCM services.
* There have been cases where the direction from AWS is not very clear. This has
  required communication with AWS TAMs to ensure that we understand exactly what needs
  to be done. This was the case in the past when RDS OS upgrades and engine versions
  were released at the same time and had dependencies (OS upgrades could only be applied
  to certain versions). We may see less of this going forward as AWS improves their
  processes, but it's worth mentioning.

The sections below will cover what needs to be completed in each ticket.

## Tasks

The tasks should be completed in the order seen below.

### Update RDS approved versions documentation

See the [README page](/README.md#approved-rds-versions) for a list of approved RDS
versions. These should be updated to the appropriate versions based on the AWS
communication. **Update the Notes** section to reflect why this is the required
version (we may be able to remove this in the future).

### Notify tenants of required RDS upgrade

A good starting point is to email tenants and put a notification in the #sd-app-sre
channel as soon as we feel that we're confident in the information released by AWS. The
timelines can sometimes be aggressive, so we don't want tenants to be surprised.

Example emails can be seen in [this folder](/data/app-interface/emails/all-rds/). The
content will likely be different each time because sometimes it's only RDS engine
upgrades, while other times OS upgrades might also be required.

### Update RDS approved version alerts

There are Prometheus alerts that will automatically create tickets (with
[jiralert](https://github.com/prometheus-community/jiralert)) when databases are
not using compliant versions.

For this to work, the alerts need to be updated to reflect the changes in approved
versions. The process below has opportunities for improvement, but for now
it's working (we don't change this very often). All of this should be submitted in a
single MR.

1. Update
   the [Prometheus tests](/resources/observability/prometheusrules/rds-approved-versions-test.prometheusrulestests.yaml)
   to reflect what are now approved and unapproved versions (essentially what used to be
   an approved version might now be unapproved)
2. Update
   the [test_data](/test_data/services/aws-resource-tests/namespaces/rds-approved-versions.yml)
   to ensure than the `engine_version` is set to an approved version
3. Update the regex in
   the [test alert expression](/resources/observability/prometheusrules/rds-approved-versions-test.prometheusrules.yaml)
4. Ensure that prometheus rule tests are passing and that the test_data tests are
   passing
5. Update the templated alert expression by copy/pasting the regex from above
   into [this file](/resources/services/app-sre-observability/rds-approved-versions.prometheusrules.yaml.j2)
   . This is the template that is used to create the RDS alerts.

After submitting this MR, new alerts should be created which can be found by querying
Jira with a filter like:

`labels = "alertname=\"RDSCompliantEngineVersionCheck\"" and status not in (Closed, Done, Rejected, Obsolete)`

### Last reminder for RDS upgrades

Somewhere between 2-4 weeks out from the upgrade we should send one final reminder email
and Slack notification in #sd-app-sre. AWS typically forces the upgrades after the
deadline, so if the notifications are ignored. See the current documentation on minor
version upgrades to determine how long of an outage is expected.
