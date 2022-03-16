# Design doc: AWS resource sharing

## Author/date

Maor Friedman / 2021-03-03

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4621

## Problem Statement

This work is a part of [AWS autoscaling group as managed terraform resource](https://issues.redhat.com/browse/APPSRE-3925).

As with container images, we only want to built an AMI once, and "promote" it across environments. For that purpose, we are building the AMI in a central AWS account (app-sre-ci).

The built AMIs should be shared with AWS accounts which will consume them as part of an AutoScaling Group definition.

## Goals

Add an ability to share AMIs between AWS accounts. Since shared AMIs do not contain tags from the source AMI, this functionality should include copying tags from the source AMI to the shared AMI.

## Non-objectives

## Proposal

Enhance the AWS account file schema with a new section called `sharing`. This section will be placed in the source AWS account and will contain declarations for AWS accounts to share AMIs with:
```yaml
sharing:
- provider: ami
  account:
    $ref: /path/to/stage/account.yml
  regex: '^.*$'
  region: <region> # optional
- provider: ami
  account:
    $ref: /path/to/prod/account.yml
  regex: '^.*$'
```

This schema change will be picked up by an integration responsible for sharing the AMIs that meet the regex expression and copy their tags as well.

We will use the [Provider Pattern](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-interface/qontract-reconcile-patterns.md#the-provider-pattern) to support any future sharing related needs. Some examples that come to mind are RDS snapshots, ECR images, CMK keys.

We will use a regex expression for AMI image names to enable a multi-tenant usage of a single AWS source account. For example, this will prevent sharing service A AMIs with service B AWS account.

Since AMIs are a regional resource, we will support sharing AMIs in different regions.

## Alternatives considered

Share AMIs as part of the build process. This approach forces the build process to be aware of all accounts where the AMI is planned to be used. In case a new account comes into play, it will only be shared with new AMIs.

## Milestones

Make it work.
