# Design doc: AWS AMI Continuous Delivery

## Author/date

Maor Friedman / 2021-03-03

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-3925

## Background

The Image Builder service uses EC2 instances as "workers" to perform builds of AMIs.
> Note: These EC2 instances are not considered a data plane, and are treated as regular cloud native assets.

The high-level process of delivering AMIs is:
1. Create job definition to build the AMI
1. Share the AMI with accounts where it will be used
1. Update AutoScaling Groups to use the new AMI

### Build AMI

The process to build an AMI is to launch an EC2 instance and make an AMI out of it.
> Note: Initially, the EC2 instance launched as part of the build process was created in the `image-builder-stage` account and shared with the `image-builder-prod` account. To remove the dependency of production on stage, we created a [dedicated AppSRE AWS account](https://issues.redhat.com/browse/APPSRE-4405) called `app-sre-ci` to be used to perform the AMI build.

As part of this work, we have already created a [job definition](https://gitlab.cee.redhat.com/service/app-interface/-/blob/e006b480c002ed869eb66df04d62ed8ef1218f7e/resources/jenkins/image-builder/jobs-templates.yml) to build these AMIs using packer.

### Share AMI

The process to consume an AMI built on a different account is to share the AMI from the "source" account (app-sre-ci) with the "destination" accounts (image-builder-stage, image-builder-prod).
> Note: The build job described in the previous section currently builds the AMI and shares it with the image-builder stage and production accounts.

### Provision and update AutoScaling Groups

We have added support to provision AutoScaling Groups. Here is an [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/e006b480c002ed869eb66df04d62ed8ef1218f7e/data/services/image-builder/namespaces/workers-stage.yml#L173-186).

### Disclaimer

The entire process was not brought up as a design document since each individual step (custom jenkins job, new provider for terraform-resources) was not deemed as one that requires it.

This design document will focus on enabling the AMI delivery pipeline to be continuous.

## Problem Statement

After the first iteration of this effort, teams are required to "promote" new AMIs to use in all environments where the AutoScaling Group is used.

## Goals

Provide a continuous experience for the stage environment. This means that every time new code is pushed, a new AMI will be built and automatically deployed to stage.

## Non-objectives

## Proposal

Embed the source code repository information within the AutoScaling Group definition in the stage environment.

With this information, the integration can follow the main branch of the repository (much like saas files) and automatically promote new changes. This can happen under the following conditions:
1. A new commit has been pushed to the main branch
1. A new AMI has been built
1. The new AMI is shared with the account containing the AutoScaling Groups.

Additional information to add to the schema will be similar to saas files:
```yaml
terraformResources
- provider: asg
  ...
  image:
    ...
    repo:
      url: <url of source code repository>
      ref: <commit or branch name>
      tag_name: <name of tag to use to correlate AMI ID to commit>
```

The terraform-resources integration will be enhanced with logic to determine if a new commit has been pushed and if it should use an AMI that corresponds to this commit. In case a new commit has been pushed and the AMI is not yet available, the integration should result to using the previous known commit (indicates usage of a state) to avoid intermittent disruptions to the integration.

The way to correlate an AMI from the source account with one in the destination account is using the image ID. This field is unique. The AMI in the source account will contain tags linking it back to a specific commit. These tags are not available in the destination account.

This creates a dependency between the two accounts, which should be detached. terraform-resources should not require access to the source account, only to determine the correct image ID to use.

To improve traceability between the commit and the image in the destination account, we will create an integration to copy AMI tags to the AMIs in the destination account. To further decouple the entire process, instead of sharing the AMIs as part of the AMI build process, this same integration will be solely responsible for sharing and tagging AMIs from source accounts to destination accounts.
> Note: This part was generalized and extracted to a seperate design document: [AWS resource sharing](https://issues.redhat.com/browse/APPSRE-4621).

This approach will help us simplify the terraform-resources integration. The added logic should mostly be:
> New commit and AMI exists? use it. Otherwise, use the last known commit.

## Alternatives considered

## Milestones

Make it work
Make it work right
Make it beautiful <-- we are here
