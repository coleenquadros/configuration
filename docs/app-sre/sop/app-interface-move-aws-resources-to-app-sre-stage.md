# AWS resource account migration to app-sre-stage

This SOP documents the high level process for AWS resource migration to the app-sre-stage AWS account.
As such, this SOP is only applicable to non-production resources.

Detailed AWS resource specific migration procedures are covered in linked SOPs, so this one can focus on the overall process.

## Overall procedure

The overall procedure is layed out like this. Have a look at the details section for more insights.

- if the resource is actively use
  - declare downtime
  - take down the service
  - apply the resource specific migration procedure
  - update the service to use the new resources
  - bring the service up
  - validate the service functionality
  - end of downtime
  - cleanup resources in the source account
- if the resource is NOT actively used
  - apply the resource specific migration procedure

Keep in mind that data transfer can take a long time if a lot of data is involved. If supported by the resource type, consider conducting a first data sync from source to destination before you shut down the service. This helps to reduce downtime.

## Details

### Find out if a resource is actively used
- is the `output_resource_name` used in a SAAS template or referenced in a SAAS target parameter?
- is the resource secret in Vault referenced somewhere in an openshift-resource or shared-resource?
  - watch out for `vault()` references in templates
- for RDS additionally look for active connection in the AWS console
- for S3 look at bucket activity in Cloudtrail

### Declare downtime
- identify the service owner in the services app file
- inform the service owner about the migration plans and the required downtime
- inform the AppSRE team #sd-app-sre-teamchat because the service downtime might trigger alerts

### Scale down service
- scale down the part of the service that accesses the AWS resource, e.g. setting REPLICAS in SAAS file to 0
- in doubt talk to the service owners

### Resource specific migration procedures
- for RDS follow [this SOP](database/migrate-rds-instances.md)
- for S3 follow [this SOP](migrate-s3-bucket.md)
