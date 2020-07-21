# Diagnostics queries in Quay MySQL Database

In order to get insights of what's happening in Quay's database when we have an event, we run every minute a set of queries to the Quay master database and we upload the results to an S3 bucket.  It is implemented through a k8s CronJob.

The Cronjob definition and the script that queries and uploads live in https://github.com/app-sre/quay-mysql-diag. A couple of important details:

* The job runs by default every minute
* The job's concurrency policy is set to `Forbid`. This means that if the job hasn't ended when a new one has to be scheduled, k8s won't schedule a new one until it has ended or the `activeDeadlineSeconds` or the `backoffLimit` has been reached

## Deployments

The job runs via the [`quay-mysql-diag.yaml`](/data/services/quayio/saas/quay-mysql-diag.yaml) file in its own namespace in the quay stage and prod clusters. A few details about it:

* The s3 buckets where files are stored are:
  * `quay-mysql-diag-production` for production
  * `quay-mysql-diag-stage` for stage
* bucket retention period is set to 30 days
* The address of the db is get from the `quay-config-secret` secret copied to the namespace and mounted in the pod. This means that if the host changes in the secret, the version should be updated.

## Copying files from the bucket

### Prerequisites

You need to have the `aws` client installed and configured. Take a look into the [official documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) to get that process. Make sure that you read the chapter about named profiles in the configuration section.

### Process

The diag files in the bucket have the following name:

```
diag-YYYYmmddTHHMMSS.tar.gz
```

e.g.

```
diag-20200707T220010.tar.gz
```

The dates are in UTC.

If you want to copy files the easiest way is to use the `aws` command. The following example command assumes that you have configured a profile called `app-sre` for the `app-sre` AWS account. It will copy all the files generated at the from the 22h to 23h on 2020-07-07 from the production bucket

```
aws s3 --profile app-sre cp s3://quay-mysql-diag-production . \
   --recursive --exclude "*" --include "diag-20200707T22*.tar.gz"
```

Pay attention to the order of the `--exclude` and `--include` options in the above command as it matters and it must be honored.
