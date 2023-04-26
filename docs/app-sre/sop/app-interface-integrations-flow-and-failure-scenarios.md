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
    * `jenkins-job-builder` in no-compare mode
        * Collect JJB data to compare with the desired state in the MR
        * pending https://issues.redhat.com/browse/APPSRE-1854
1. Integration execution phase: Run all integrations against the local GraphQL endpoint.
    * The integrations from the baseline collection phase will run again in a compare mode
        * These integrations will fail in the baseline collection phase was not completed succesfully

## Failure scenarions

This section describes common failure scenarios for different integrations.

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
    * Pin the [ref](https://gitlab.cee.redhat.com/service/app-interface/-/blob/fc003a3f6f2eda2abdbe170ddcdc2f5ffc3a7618/data/services/image-builder/namespaces/workers-stage.yml#L220) to the commit sha of [last success build](https://ci.ext.devshift.net/job/osbuild-osbuild-composer-gh-build-main-packer/lastSuccessfulBuild/) after validating that `aws-ami-share` has done its job(See below). Ask the tenant to revert the change when they resolve the failure.
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
This could be caused by various reasons, for example gql client http call timeout default to forever ([fixed](https://github.com/app-sre/qontract-reconcile/pull/2337/files)) used to be one of them.

The temporary workaround is to restart pods of stuck integrations. But before killing the pod, following these steps to get a thread dump:

1. Stream the logs for my-pod in terminal 1, run
```
oc logs -c int -f my-pod
```
2. Send miscellaneous signal SIGUSR1 in terminal 2:
```
oc rsh -c int my-pod 
# kill -USR1 1
```
You should be getting the logs stream in terminal 1 that helps with further troubleshooting.

Related ticket [APPSRE-4905](https://issues.redhat.com/browse/APPSRE-4905).

### MR Queue Saturated

[AWS Simple Queue Service (SQS)](https://aws.amazon.com/sqs/) is used by Qontract Reconcile to track merge requests, [technical details here](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/utils/mr/README.md).
If the queue becomes saturated, that typically means an issue with GitLab.cee processing the MRs.
In a past incident [APPSRE-5772](https://issues.redhat.com/browse/APPSRE-5772), 
this was due to a code change causing QR to create a ton of MRs, overloading GitLab.cee.
1. Check the [AppSRE Bot](https://gitlab.cee.redhat.com/devtools-bot) for an abnormal increase in MRs which may indicate a code error.
2. Reach out to the IT ALM team as described in the [Gitlab.cee Escalation Runbook](/docs/app-sre/runbook/gitlab-cee-redhat-com.md) to determine if there are issues with Gitlab itself.

### Cloudflare integrations

All documentation related to Cloudflare integrations can be found in the [Cloudflare runbook](/docs/app-sre/runbook/cloudflare.md#troubleshooting).
