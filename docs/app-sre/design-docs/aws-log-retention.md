# Design doc: AWS Log Rentention Implementation

## Author/date

Suzana Nesic (snesic) / 2023-05-15

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-7249

## Problem Statement

Currently, log groups are created with infinite log retention period. AppSRE would like to develop a solution that will enable all log groups to have a retention period of three months in order to keep storage costs low.

## Goals

Delete logs after three months to make sure AppSRE can keep storage costs low.

## Non-objectives

## Proposal

With the new `cleanup` section within the AWS account file, a provider called `cloudwatch` can be added with the following properties where we want to add a retention period and also follow up with a log group cleanup.

```yaml
cleanup:
- provider: cloudwatch
  regex: '/aws/rds/instance*'
  retention_in_days: 90d
- provider: cloudwatch
  regex: 'hivei01ue1-c4552.*'
  retention_in_days: 90d
```

This schema change will be picked up by a new integration responsible for configuring log groups different than `retention_in_days` that meet the name provided in the schema. It will make use of the AWS API to list the log groups that belong to the account. The new integration will run as a cronjob. 

The idea for this new integration is to first build a candidate list from AWS, then see if the retention period is set to not as desired. Logic will then be implemented to set the retention period and AWS will automatically delete logs after the retention period is reached. The main use of the `regex`, to be able to select exactly the recipient of the cleanup job.

## Alternatives considered

Alternatively, we could create a new section called `log_retention` rather than add onto the `cleanup` section that will also include AMI cleanup. It would look as follows:
```yaml
log_retentions:
- provider: cloudwatch
  regex: '/aws/rds/instance*'
  retention_in_days: 90d
- provider: cloudwatch
  regex: 'hivei01ue1-c4552.*'
  retention_in_days: 90d
```


Also, it was discussed how to handle loggroups managed by CLO (ex - `hivei01ue1-c4552.*`). We will handle these log groups in a different way and leave this design doc method for the log groups that do not follow the namespace specific log group names.

## Milestones

N/A
