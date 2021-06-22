
# Kafka Service Fleet Manager Rollback Policy

## Rollback
### Check if rollback is supported
Before attempting to rollback a deployment, ensure that rollback is supported from the current version to the previous working version. This can be checked by following the steps below:
- Go to the [app-interface](https://gitlab.cee.redhat.com/service/app-interface/) repository
- Find the merge request which includes the commit that promoted the KAS Fleet Manager deployment to the current version.
    - Go to the `data/services/managed-services/cicd/saas` directory.
    - Select `saas-kas-fleet-manager.yaml` file.
    - Click on `History`.
    - Find the commit that promoted the KAS Fleet Manager deployment to the current version. The commit will have the following format: 
        ```
        chore: update kas-fleet-manager <prod/stage> version to <new-version>
        ```
- See the `Changes Included` section of the merge request description. This will have a link that lists all of the commits included and files changed in this version of KAS Fleet Manager.
    - Ensure that there aren't any changes that would prevent rollback to the previous version. This includes the following type of changes:
        - Database schema changes: The addition of a new database migration file would indicate changes in the database schema. If this is the case, an evaluation should be done to see if this includes non-backward compatible changes. 
        
            Database migration files are added to the `pkg/db/` directory and will have a name which follows the format `YYYYMMDDHHMM-<migration-name>.go`.

### Rollback the deployment of KAS Fleet Manager
If rollback is supported, please follow the steps listed below:
- Create a merge request in [app-interface](https://gitlab.cee.redhat.com/service/app-interface/) to revert the commit which promoted the deployment to the current version.
- Please seek approval from the list of approvers mentioned in the merge request to merge it.


## Roll Forward
If rollback is not supported, the deployment must be rolled forward to a new version that includes the change to fix the issue. 

- Report the issue to the Control Plane team. 
    - See the Control Plane team's [escalation policy](../../../data/teams/managed-services/escalation-policies/kas-fleet-manager.yaml) for further information.
- Once a new version is available, the Control Plane team will create a merge request to update the version of the KAS Fleet Manager.
