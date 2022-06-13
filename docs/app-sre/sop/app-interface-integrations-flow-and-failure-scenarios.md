# App-interface integrations flow and failure scenarios

## Background

Each MR in app-interface is running a set of integrations to compare and validate a desired state before it is merged in to app-interface and reconciled.

The list of integrations being run can be found in [manual_reconcile.sh](/hack/manual_reconcile.sh)

## Flow description

There are 3 stages when running our integrations:
1. Compliance phase: Verify that the MR can be rebased by the App SRE team.
    * Run the `gitlab-fork-compliance` integration
        * Verifies that the App SRE gitlab bot is a Maintainer on the fork
        * Adds the App SRE team members as Maintainers on the fork (acting as the bot)
        * Verifies that the MR is not using `master` as the source branch (disables rebasing)
1. Baseline collection phase: Run a small set of integrations against the production GraphQL endpoint.
    * `saas-file-owners` in no-compare mode
        * Collect information about saas file owners to prevent privilege escalation.
    * `jenkins-job-builder` in no-compare mode
        * Collect JJB data to compare with the desired state in the MR
        * pending https://issues.redhat.com/browse/APPSRE-1854
1. Integration execution phase: Run all integrations against the local GraphQL endpoint.
    * The integrations from the baseline collection phase will run again in a compare mode
        * These integrations will fail in the baseline collection phase was not completed succesfully

## Failure scenarions

This section describes common failure scenrios for different integrations.

### saas-file-owners

Mostly fails if baseline collection phase was not succesfull.
This is usually due to a data reload in the Graphql production endpoint.

Solution: `/retest`

### jenkins-job-builder

Mostly fails if baseline collection phase was not succesfull.
This is usually due to a data reload in the Graphql production endpoint.

Solution: `/retest`

### Fixing invalid terraform state

When a manual intervention has forced us to change an AWS resource,
terraform may find a discrepancy between its stored state and
reality. In such an event, `terraform-resources` may show
strange errors about mismatching or missing resources. When that
happens:

1. Diagnose the account for which the problem is happening.
1. Generate the terraform configuration for this account.  On your
   local machine, spawn a qontract server and run the integration in
   dry-run mode:
   ``` bash
    # From app-interface's top-level:
    make server
    qontract-reconcile --config config.debug.toml --dry-run terraform-resources --print-only --account-name $account_name |sed 1d > config.tf.json
    ```
    (please remember, you can find the config.debug.toml file in
   vault, path `app-sre/ci-int/qontract-reconcile-toml` - field
   local_data)
1. Initialize terraform and see its plan
   ``` bash
   terraform init
   terraform plan
   ```
    You'll see it lists a lot of resources, even if it eventually
    fails:
    ``` bash
    aws_elasticache_parameter_group.quay-orchestrator-parameters: Refreshing state... [id=quay-orchestrator-parameters]
    aws_cloudfront_origin_access_identity.quayio-stage-s3: Refreshing state... [id=E3BFM0BD46CWH4]
    aws_iam_role.quayio-stage-s3_quayio-stage-backup: Refreshing state... [id=quayio-stage-backup_iam_role]
    aws_iam_user.aws-cloudwatch-exporter-quay-stage-01: Refreshing state... [id=aws-cloudwatch-exporter-quay-stage-01]
    [...]
    ```
    Identify the one that matches what was modified manually.
1. Ask for help! Ask for a team member with experience on terraform
   and these integrations to re-check what you're doing! Our next
   steps are **very** dangerous!!
1. Check why the state doesn't match, and run the appropriate
   `terraform state` subcommand. For instance, if you deleted a
   parameter group, you may want to do:
   ``` bash
   terraform state rm $parameter_group
   ```

### AMI Not Found 

When `terraform-resources` raise the error of `could not find ami for commit {commit_sha} in account {account}` for provision [ASG](https://gitlab.cee.redhat.com/service/app-interface#manage-aws-autoscaling-group-via-app-interface-openshiftnamespace-1yml), There are several places that need to check to locate the issue.
1. The upstream packer build job may fail. Check the last build result of the Jenkins job defined in ASG(e.g image-builder [upstrem job](https://gitlab.cee.redhat.com/service/app-interface/-/blob/fc003a3f6f2eda2abdbe170ddcdc2f5ffc3a7618/data/services/image-builder/namespaces/workers-stage.yml#L221-224) [jenkins url](https://ci.ext.devshift.net/job/osbuild-osbuild-composer-gh-build-main-packer/)). The tenant should already get the [alert](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/observability/prometheusrules/ci-ext.prometheusrules.yaml#L153-163) of its failure. In this case: 
    * Notify tenant by following its [escalation policy](https://gitlab.cee.redhat.com/service/app-interface/-/blob/e3a39afcc054ce7dd6df41aa314996ab3ab8c428/data/services/image-builder/app.yml#L22) 
    * Pin the [ref](https://gitlab.cee.redhat.com/service/app-interface/-/blob/fc003a3f6f2eda2abdbe170ddcdc2f5ffc3a7618/data/services/image-builder/namespaces/workers-stage.yml#L220) to the commit sha of [last success build](https://ci.ext.devshift.net/job/osbuild-osbuild-composer-gh-build-main-packer/lastSuccessfulBuild/). Ask the tenant to revert the change when they resolve the failure.
1. The `aws-ami-share` integration may fail. Check integration [status](https://prometheus.app-sre-prod-01.devshift.net/graph?g0.range_input=1h&g0.expr=qontract_reconcile_last_run_status%7Bintegration%3D%22aws-ami-share%22%7D&g0.tab=1) and log of aws-ami-share. Check amis in `app-sre-ic` account and ASG target account. In this case: 
    * Pin the [ref](https://gitlab.cee.redhat.com/service/app-interface/-/blob/fc003a3f6f2eda2abdbe170ddcdc2f5ffc3a7618/data/services/image-builder/namespaces/workers-stage.yml#L220) to the commit sha of last success shared ami in ASG target account. 
    * Try to resolve the aws-ami-share issue.

### Delete terraform resources

Terraform managed resources are not deleted during normal reconcile runs. If resources need to be deleted, the
`terraform-resources` integration will complain about `deletion action not enabled`.

Follow the [How to safely delete terraform managed resources](delete-terraform-resources.md) guide to resolve
this situation.

### Integrations are stuck

In some cases, integrations will get "stuck" and will cease to execute.

This is being investigated in [APPSRE-4905](https://issues.redhat.com/browse/APPSRE-4905).

The temporary workaround is to restart pods of stuck integrations.
