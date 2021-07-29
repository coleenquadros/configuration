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

## Special Merge Request titles

Some of our integrations shouldn't run in every merge request. The current mechanism to determine if such an integration should run is done by using the MR title:
- if the title contains "saas-deploy-full" - the openshift-saas-deploy integration is executed for all saas files

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

### Unfucking terraform

When a manual intervention has forced us to change an AWS resource,
terraform may find a discrepancy between its stored state and
reality. In such an event, `terraform-resources-wrapper` may show
strange errors about mismatching or missing resources. When that
happens:

1. Diagnose the account for which the problem is happening.
1. Generate the terraform configuration for this account, on your
   local machine, spawn a qontract server
``` bash
    # From app-interface's top-level:
    make server
qontract-reconcile --config config.debug.toml --dry-run terraform-resources --print-only --account-name $account_name > config.tf.json
```
    (please remember, you can find the config.debug.toml file in vault)
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
1. Ask for help! Ask for a team member to re-check what you're
   doing! Our next steps are **very** dangerous!!
1. Check why the state doesn't match, and run the appropriate
   `terraform state` subcommand. For instance, if you deleted a
   parameter group, you may want to do:
``` bash
terraform state rm $parameter_group
```

   
