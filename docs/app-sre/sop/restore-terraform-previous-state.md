# How to restore terraform to a previous state

If things go really bad with a terraform change and the [state](https://www.terraform.io/docs/language/state/index.html) gets corrupted we have the possibility to go back to a previous state because our AWS buckets containing terraform data are versioned.

## Note

This procedure is safe if the terraform binary and providers version haven't changed between the different state versions. If they have changed, this may not work at all, depending on the nature of the change:

* binary: Do not expect this to work between minor versions of the binary.
* providers: Do not expect this to work between major versions of the providers.

## Stop related integrations

If the state affected is related to our integrations, use [unleash](https://app-interface.unleash.devshift.net/) to stop the terraform integrations that may be writing to that state.

If the state affected is one of our [infra](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/terraform) one, you can safely skip this step.

## Install the proper terraform version

Look for the version we're using in [`qontract-reconcile-base`](https://github.com/app-sre/container-images/blob/master/qontract-reconcile-base/Dockerfile) image, in the variable `TF_VERSION`.

Once there, make sure that your terraform version matches:

```
terraform -version
```

If not, install the proper version. [tfenv](https://github.com/tfutils/tfenv) a very useful tool to manage multiple terraform versions.

## Save current state

Before making any changes it is always good to have a copy of the current state, even if we know it is not good and the bucket should be versioned.

### app-sre/infra Repo

If you're in the `app-sre/infra` repo, you can use directly `terraform` command from the appropriate directory

```
terraform state pull > state.json
```

### Integration

If you're restoring a state from one of our integrations, you will need first to generate the config files that terrascript uses. Run the integration with `--print-only` to get the config files and use `--account-name` to just get the results of the account you're interested in, e.g. for the `app-sre` account you would do something like:

```
mkdir app-sre
qontract-reconcile --dry-run --config <config toml> terraform-resources --print-only --account-name app-sre | \
grep -v '##### app-sre #####' > app-sre/config.tf.json
```

At the time of this writing, this isn't still valid proper terraform config as it has a duplicate in the `provider` and `terraform` sections. You can just delete the small first json document (up to line ~37) as you can see it contains duplicate information. This is being tracked in https://issues.redhat.com/browse/APPSRE-2940.  Once we are there, we can save our state:

```
cd app-sre
terraform init
terraform state pull > current-state.json
```

## Get the previous state file from the terraform bucket

Get the bucket name containing the terraform state file and the credentials to access have access to itfrom Vault. Your personal app-sre accounts don't have permissions to access the terraform buckets. You can get the location of the secret in app-interface, e.g for the `app-sre` account it is in [/data/aws/app-sre/account.yml](account.yml) in the `automationToken` key.  Then find the exact name of the state file you need using the information from the secret:

```
export AWS_ACCESS_KEY_ID=XXXXXX
export AWS_SECRET_ACCESS_KEY=YYyyYyyYyYY
aws s3 ls s3://<bucket name>
```

Then you can get the versions of the state file you need:

```
aws s3api list-object-versions --bucket <bucket name> \
                               --prefix <state file name> \
                               --max-items <number of versions>
```

`--max-items` is provided as the command output can be very large. Use a small number to begin with.

You then can download a previous state file version using `get-object` from `aws s3api`

```
aws s3api get-object --bucket <bucket name> \
                     --key <state file name> \
                     --version-id <version id> \
                     <previous state file name>
```

where `version id` is one of the `VersionId` from the `list-object-versions`

You can compare the serial number from the current state and previous states to compare how many changes back you need to go.

## Push new state to s3 bucket

Once decided which state file you want to recover, copy it into the directory where we have the terraform config files that we have used to get the current state and run:

```
terraform state push -force <previous state file name>
```

then run

```
terraform plan
```

to make sure things are going to work as you expect next time terraform plan is applied.
