# Deprecation notice for RDS databases using `auto_minor_version_upgrade` defaults parameter

AppSRE will be removing support for `auto_minor_version_upgrade` which allows for RDS databases to upgrade minor 
version automatically. This parameter will be removed to abide by AppSRE best practices with following reasonings.
1. If this parameter is used for production database in addition to stage database, AppSRE cannot guarantee that
stage database will be upgraded before production. This behavior is controlled by Amazon RDS which does not distinguish
between stage and production.
2. The parameter doesn't guarantee that the DB will be up to date with regards to the latest minor version. It only upgrades if the current 
version is being deprecated or if the new version contains very important bugfixes. More info [here](https://repost.aws/questions/QUT0JuX6IhSAyXaSdQK5SW3A)

# How do I know if my RDS DB is impacted by this?

If you have RDS DB defined within app-interface, you can follow these steps to identify if your DB is affected.

- Identify RDS databases used by your team
- Go to the defaults file referenced by the RDS provider configuration. More info [here](../../../README.md#manage-rds-databases-via-app-interface-openshiftnamespace-1yml)
- Check if `auto_minor_version_upgrade` is defined
    - If `auto_minor_version_upgrade: true`, then your DB will be affected by this change.
    - If `auto_minor_version_upgrade: false`, then your DB **is not** affected by this change.


## Current list of affected databases (As of 09/06/2022)
```
remediations-stage
automation-hub-stage
policies-ui-backend-stage
quickstarts-stage
content-sources-stage
rbac-stage
approval-stage
historical-system-profiles-stage
approval-pam-stage
provisioning-stage
host-inventory-stage
host-inventory-stage-readonly
notifications-backend-stage
ccx-data-pipeline-stage
ccx-notification-db-stage
catalog-stage
payload-tracker-stage-db
catalog-inventory-stage
sources-stage
sources-stage-readonly
tower-analytics-stage
system-baseline-stage
edge-perf
subscriptions-stage
insights-operator-controller-stage
ocp-vulnerability-stage
ocp-vulnerability-stage-readonly
advisor-stage
ros-stage
cloudigrade-stage
malware-detection-stage
module-update-router-stage
edge-stage
edge-stage-readonly
```

# Do I need to take any action?

Tenants **do not** have to take any action to address this. AppSRE will be responsible for handling any changes on tenants' behalf.

# Will this deprecation involve any downtime with the DB?

This deprecation **will not** cause any downtime and is considered a safe operation.

# When will this change take place?

AppSRE will be moving forward with the removal of the `auto_minor_version_upgrade` parameter on 10/03/2022.