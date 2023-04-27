# Design doc: AWS AMI Cleanup

## Author/date

Rafa Porres Molina (rporresm) / 2023-04-27

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-7272

## Problem Statement

As a result of the work in [AWS autoscaling group as managed terraform resource](https://issues.redhat.com/browse/APPSRE-3925) and [Jenkins dynamic workers](https://issues.redhat.com/browse/SDE-1924) we have a growing number of AMIs in app-sre-ci account that are unused and are costing storage money.


## Goals

Delete old AMIs that belong to us from the selected accounts making sure that we don't delete any AMI that is in use from an app-interface Auto Scaling Group (configuration).

## Non-objectives

## Proposal

Enhance the AWS account file schema with a new section called `cleanup`. This section will be placed in the AWS account where we want to do the cleanup.

```yaml
cleanup:
- provider: ami
  regex: '^osbuild-composer-worker.*'
  age: 3m
- provider: ami
  regex: '^ci-int-jenkins-worker.*'
  age: 6m
```

This schema change will be picked up by a new integration responsible for removing AMIs older that `age` that meet the regex expression provided that they're not in use. The new integration will run as cronjob.

We will use the [Provider Pattern](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-interface/qontract-reconcile-patterns.md#the-provider-pattern) to support any future cleanup related needs.

## Alternatives considered

None.

## Milestones

Make it work.
