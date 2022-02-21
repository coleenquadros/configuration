# AWS resource account migration to app-sre-stage

This SOP documents the high level process for AWS resource migration tothe app-sre-stage AWS account.
As such, this SOP is only applicable to non-production resources.

Detailed AWS resource specific migration procedures are covered in linked SOPs, so this one can focus on the overall process.

WIP - just skeleton notes for now that need to be refined

## Overall procedure
- find out if a resource is actively used
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


## Find out if a resource is actively used
- is the `output_resource_name` used in a SAAS template or referenced in a SAAS target parameter?
- is the resource secret in Vault referenced somewhere in an openshift-resource or shared-resource?

## Declare downtime
- identify the service owner in the services app file
- inform the service owner about the migration plans and the required downtime
- inform the AppSRE team #sd-app-sre-teamchat because the service downtime might trigger alerts

## Migrate RDS databases
- follow the procedure at https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/database/migrate-rds-instances.md
- ...
