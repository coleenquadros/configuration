# How to upgrade Redis minor versions

## Table of contents

[TOC]

## Versions < 6.0.0 or accounts with AWS TF Provider <= 3.30.0

For this cases, the upgrade of the version of the Redis cluster is done normally updating the `engine_version` value on the parameter group file on app-interface.

[Example MR upgrading redis from 6.0.x to 6.2.x](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/39929/diffs)

## Versions >= 6.0.x and terraform provider 3.75.2

During the past year, AWS changed several times how `engine_version` parameter is specified on the parameter groups for Redis ElastiCache clusters.

On the last version under major 3, engine version for Redis clusters should be specified as `<major>.x` for redis on versions 6 or higher instead of `<major>.<minor>.<bug-fix>`. To fix this error on Terraform the parameter groups for affected Redis cluster should be updated to `<major>.x`

The Redis cluster update from 6.0.x to 6.2.x has to be done using the AWS console and changing the value manually upon the tenant team request.

To do the change you need to follow this steps:

1. Connect to the AWS Console
1. Locate the Redis Cluster
1. Click on the modify button
1. Change the cluster version
1. Select apply inmmediately
1. Apply the changes

The applied changes do not change anything in the terraform state and the integration won't notice any differences in the plan.

For more context about this, you can take a look at this [Jira comment with the investigation of the changes](https://issues.redhat.com/browse/APPSRE-3598?focusedCommentId=20329131&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-20329131)



