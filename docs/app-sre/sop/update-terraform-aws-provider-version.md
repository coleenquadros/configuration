# Update Terraform AWS provider

## Table of Contents

[TOC]

This SOP describes the steps that needs to be done to upgrade the version of the Terraform AWS Provider on the accounts managed on app-interface.

## Add new provider version to qontract-reconicle images

To use a new Terraform AWS provider on the accounts, a new version has to be made available on the qontract-reconcile images that are used for the PR check and the deploy pipelines.

The repository is [container-images](https://github.com/app-sre/container-images)

### Add provider to the base image

To add the new version of the Terraform AWS provider update the list of versions located on [Base Image Dockerfile](https://github.com/app-sre/container-images/blob/master/qontract-reconcile-base/Dockerfile#L8) and add the required version to the list.

Update the version of the image on [version file](https://github.com/app-sre/container-images/blob/master/qontract-reconcile-base/VERSION#L1) following the conventions.

Example MR [Add 3.75.2 Provider to base images](https://github.com/app-sre/container-images/pull/43)

### Update Builder Image version

Once the base image is updated, bump the version on the qontract-reconcile-builder image. [Qontract Reconcile Builder](https://github.com/app-sre/container-images/blob/master/qontract-reconcile-builder/Dockerfile#L1)

And also bump the [version of the builder image](https://github.com/app-sre/container-images/blob/master/qontract-reconcile-builder/VERSION).

### Use new image on qontract-reconcile

After both images are updated with the new contents update the version of the image on [qontract-reconcile](https://github.com/app-sre/qontract-reconcile/blob/master/dockerfiles/Dockerfile) and the provider version will be available to be used.

## Update provider on the accounts

To safely update the provider that the accounts are using we need to make sure that the update won't make any changes to the resources that are present on AWS.

### Get desired state from app-interface

To do so, first we will get the desired state using terraform-resources integration with the following command:

`qontract-reconcile --config config.toml --dry-run terraform-resources --account-name {AccountName} --print-to-file {PathLocation}`

This will generate a Terraform JSON file with the desired state comming from `app-interface` on the location specified in `PathLocation`.

### Run plan with current and new provider

With this local Terraform file, we should run a `terraform init` and `terraform plan` to make sure that we don't have any pending changes waiting to apply. Once this is verified, we can manually modify the AWS provider version on the local Terraform file and run the `terraform init` and `terraform plan` again.

### Check for changes in plan output and update

If the output of the plan does not show any changes:

```
No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your configuration and real physical resources that exist. As a result, no actions need to be performed.
```

The provider upgrade is safe, and we can proceed updating the provider version of the account by updating the account file in app-interface. For example, [app-sre-stage account file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre-stage/account.yml#L15) and change the version.

If there are any changes we need to make sure that this changes are not harmful, in case of doubt, do not hesitate to ask in #sd-app-sre channel in slack to get the input from other team members.

### Errors and changes that we found so far

**engine_version: Redis versions must match <major>.x when using version 6 or higher**

****

During the past year, AWS changed several times how `engine_version` parameter is specified on the parameter groups for Redis ElastiCache clusters.

On the last version under major 3, engine version for Redis clusters should be specified as `<major>.x` for redis on versions 6 or higher instead of `<major>.<minor>.<bug-fix>`. To fix this error on Terraform the parameter groups for affected Redis cluster should be updated to `<major>.x`

This change does not affect the underlying resources that will mantain the same version that they had, and can be updated manually using the AWS console, this is covered in [Redis minor version update SOP](#TODO)

Details of the investigation about the issue can be found on [AWS Provider Update Ticket](https://issues.redhat.com/browse/APPSRE-3598?focusedCommentId=20241853&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-20241853)

[Example MR of TF AWS Provider promotion](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/40981) with engine version errors fixed.

**Terraform integration stuck in loop due to RDS parameter updates**

****

From version `3.55.0` of the TF AWS provider there is an error with parameter groups that have defined the same values as the default for RDS.

Terraform thinks that there are changes pending to apply and it's trying to apply it, but from AWS all is in sync.

Couple of issues comenting it: [Issue 1](https://github.com/hashicorp/terraform-provider-aws/issues/18035) and [Issue 2](https://github.com/hashicorp/terraform-provider-aws/issues/593#issuecomment-330948535)

The way that we fixed it for `insights-stage` account was to remove the parameters from the parameter groups of the affected databases with a comment, this won't change anything since the values on AWS stay as the default and Terraform don't try to update it as it's no longer defined.

[Example MR for insights-stage](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/40620)

More context about the problem can be found in this [Slack thread](https://coreos.slack.com/archives/GGC2A0MS8/p1654201187564619?thread_ts=1654083991.496599&cid=GGC2A0MS8)
