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
