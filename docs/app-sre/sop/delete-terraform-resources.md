# How to safely delete terraform managed resources

This SOP describes how to safely delete managed terraform resources.

> Note: This SOP should no longer be used as a result of work done in APPSRE-4186.
> Instead, follow these instructions: https://gitlab.cee.redhat.com/service/app-interface#enable-deletion-of-aws-resources-in-deletion-protected-accounts

<details>
  <summary>Previous content</summary>

## Prerequisites

* A MR exists that removes externalResources from a namespace in app-interface.
* Make sure your local terraform binary matches the version we are using and configure AWS credentials following
  [this guide](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/terraform-quickstart.md)
* Make sure you have a qontract-reconcile development environment as described
  in [this guide](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/app-sre/sop/app-interface-development-environment-setup.md).

## Disable integrations in Unleash

Disable `terraform-resources` and `gitlab-housekeeping` integrations
in [unleash](https://app-interface.unleash.devshift.net/) to prevent integration runs that might interfere with the
resource deletion.


> ***NOTE***
> 
> While the `terraform-resources` integration is disabled, problematic app-interface
> changes handled by those integrations are not detected during PR checks and therefore would not prevent a merge.
> Disabling the `gitlab-housekeeping` integration prevents automatic merges for the time being. Try to finish your
> changes in a timely manner.

Wait a couple of minutes until all running terraform-resources integrations are finished
(observe the [#sd-app-sre-reconcile](https://coreos.slack.com/archives/CS0E65QCV) channel).

## Check CI results and merge

Rebase the MR and check the test results of the CI pipeline. Look for issues in `app-interface JSON validation` in
Jenkins. The `reconcile-terraform-resources.txt` section should show messages about `delete action is not enabled`.

If you detect other issues you are uncertain about, ask the team.

Merge the MR.

## Delete resources

Look up the account(s) from the `externalResources` affected by the MR. Each account will be used as `<account>`
within the commands used in this guide.

> ***NOTE***
>
> If the config.toml points to a local `qontract-server` make sure to pull latest `app-interface`
> changes to your local repo.

Run the following command and look for common errors.

```bash
qontract-reconcile --config <config toml> --dry-run --log-level DEBUG terraform-resources --account-name <account>
```

Potentially run without `--log-level DEBUG` for a more concise output and check again for the complaints about the
delete action not being enabled.

The exit code of the `qontract-reconcile` command should be `1`, indicating the issue about not being able to delete
resources.

> ***NOTE***
> 
> Since the local `qontract-reconcile` run does not specify any environment variables to configure
> [unleash](https://app-interface.unleash.devshift.net/), the `terraform-resources` integration can be executed 
> locally without being affected by the disabled feature flag.

When you are confident, that only the "right" terraform managed resources are going to be deleted, execute the following
command to delete the resources:

```bash
qontract-reconcile --config <config toml> terraform-resources --account-name <account> --enable-deletion
```

In certain situations, this command might end with errors (e.g. sshtunnel.py requesting password for
ssh-key). If you are not able to resolve them, proceed with the fallback procedure WHILE BEING SUPER CAREFUL!

## Delete resources fallback procedure

When the regular `qontract-reconcile` execution with `--enable-deletion` does not complete without errors, you might
proceed with the following fallback procedure. This procedure is not without risk, so use it with care and involve
another team member.

First use `qontract-reconcile` with the `--print-only` option to generate the terraform file into a freshly 
created directory.

```bash
mkdir <a-tmp-dir>
qontract-reconcile --dry-run --config <config toml> terraform-resources --print-only --account-name <account> | \
   grep -v '##### app-sre #####' > <a-tmp-dir>/config.tf.json
```

Switch to this directory, initialize terraform and execute the plan command

```bash
cd <a-tmp-dir>
terraform init
terraform plan -out output-plan-file
```

Check for hints about what resources are going to be destroyed and then continue with the actual resource deletion
with terraform apply:

```bash
terraform apply output-plan-file
```

## Re-enable integrations

Once the deletion step (or the fallback deletion step) have been completed, re-enable the `terraform-resources` and `github-housekeeping` integrations in 
[unleash](https://app-interface.unleash.devshift.net/).

</details>
