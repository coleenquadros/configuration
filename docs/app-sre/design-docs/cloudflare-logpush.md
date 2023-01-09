# Design doc: Cloudflare Logpush
## Author/date


Bhushan Thakur / January 2023


## Tracking JIRA
https://issues.redhat.com/browse/APPSRE-6626


## Problem Statement



Cloudflare products generate logs which are stored within the Cloudflare ecosystem. Tenants using Cloudflare products exposed through the app-interface will want these logs shipped to destinations such as R2, S3 or Splunk for long term retention and other analytical purposes.


Today, Quay has a requirement for pushing worker logs to S3 and tying them into their analytics tooling. In addition, we also have audit logs for accounts that we want to push to S3 (similar to Vault audit logs being shipped to S3).


## Goals
* Support Cloudflare Logpush capability in app-interface and qontract-reconcile


## Non-objectives
* Send Quay's worker logs to S3. This work will be delegated to the Quay team through self-service once the feature is implemented.
* Send Cloudflare account audit logs to S3. This will be implemented in a different story.


## Proposal


Cloudflare offers [Logpush](https://developers.cloudflare.com/logs/about/) mechanism as a way to export logs to a different location.


### Terraform resources
* `cloudflare_logpush_job` to configure logpush job
* `cloudflare_logpush_ownership_challenge` required for destination such as S3 etc.
* `cloudflare_notification_policy` to configure monitoring for Logpush jobs.


### Logpush destinations
Cloudflare supports multiple [destinations](https://developers.cloudflare.com/logs/get-started/enable-destinations/) for sending logs. We initially expose R2 and S3 destinations to start with and enable other destinations as needed in future.



### Ownership challenge
Some of the Logpush destinations such as Amazon S3, Google Cloud Storage, Microsoft Azure or Sumo Logic require ownership challenge, while others do not.


The ownership challenge can be validated either manually through inspection or through automation using Terraform. The automation through Terraform requires a data source lookup (for e.g `aws_s3_bucket_object`) for a given provider and then plugging it in `ownership_challenge` field of `cloudflare_logpush_job`. (See a detailed example at https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/logpush_job#example-usage). This pattern involves the use of two different providers, aws and cloudflare.


Currently, app-interface does not have a good way to specify resources with dependencies across different providers. Also, our pattern follows integration per Terraform provider, so solving for this is outside of this design doc. **Hence, ownership challenge validation will be done manually.** We will provide detailed doc on how validation works for Logpush destination requiring ownership later.


### Logpush job monitoring
A configured Cloudflare Logpush job may fail to push logs due to variety of reasons. We need some alerting in place to notify us in this scenario.
Cloudflare offers two different solutions for monitoring job status.
1. Cloudflare notification system: We can utilize this option through terraform using `cloudflare_notification_policy` resource. This option supports email, custom webhook and pagerduty integration.
2. Cloudflare GraphQL API: In order to utilize this, we will need to make an upstream contribution to [Cloudflare lablabs exporter](https://github.com/lablabs/cloudflare-exporter) to expose `failing_logpush_job_disabled_alert` metric.


For now, we will move forward with the Cloudflare notification system since the Lablabs exporter lacks metrics for Logpush. Contributing to the Lablabs exporter is currently out of scope.


The alert delivery mechanism (pagerduty vs. email) through Cloudflare notification will be decided later. Ideally, we prefer PagerDuty integration, but initial research shows Cloudflare does not support any PagerDuty API keys but relies on user level authentication, which is not ideal. More research is needed in this area for a further decision and will be done once initial support for Logpush is implemented.


Long term we would utilize Cloudflare GraphQL API through the exporter and relying on prometheus alerts to page us via pagerduty once the support is there. We can revisit the monitoring aspect and improve on it in the future.


## Milestones
* Implement Logpush job
* Implement Logpush job monitoring
