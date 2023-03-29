# Vault Upgrades

This SOP details the process for evaluating new versions of HashiCorp Vault and promoting to AppSRE-managed Vault instances.

App-SRE intends to upgrade its vault instances approximately once every 6 months.

Versions are evaluated against `vault.stage.devshift.net`. See [Version Vetting](#version-vetting) for steps to evaluate new versions.  

Once the version is vetted, see [Production Upgrades](#production-upgrades) for promoting to `vault.ci.ext.devshift.net` and `vault.devshift.net`

# Version Vetting

## Select Version
Review specific version [Release Notes](https://developer.hashicorp.com/vault/docs/release-notes) to assist in selecting a version. Once a version is identified, review applicable [Upgrade Guide](https://developer.hashicorp.com/vault/docs/upgrading/upgrade-to-1.12.x) for specifics.

Review CVE reports for versions that patch vulnerabilities affecting components of Vault that we utilize (oidc auth, audit devices, etc)
* [example cve resource](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=hashicorp+vault)

**NOTE:** Per [Vault's upgrade documentation](https://developer.hashicorp.com/vault/docs/upgrading), large jumps are supported (ex: 1.5.4 to 1.9.2). However, the upgrade guides for all major versions in between (1.6, 1.7, and 1.8 for this example) must be reviewed for specific steps.

## Upgrade stage
* Look at the saas file for the vault about to be upgraded. Ensure the vault instance's ref for gitlab.cee.redhat.com/service/vault-devshift-net is a version such that the k8s deployment strategy is set to `Recreate` and NOT `RollingUpdate` ([example](https://gitlab.cee.redhat.com/service/vault-devshift-net/-/blob/29de6cf6dd4c5e84cf24ddcf7c17ed5c41744aa6/openshift-vault.yaml#L30-33)).
    * this is done to ensure that incompatability issues are not encountered by a newer image replica co-existing aloneside original replicas
* Ensure an image tag exists for the desired version within [quay.io/app-sre/vault](https://quay.io/repository/app-sre/vault?tab=tags)
* Create an MR that updates [image tag for vault.stage.devshift.net target](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/cicd/saas.yaml#L61)

## Evaluation

### Setup
Permission to alter Vault system resources is required in order to complete this checklist. Utilize the [vault-manager-stage](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/vault-manager-stage-creds) approle credentials for obtaining a token with necessary permission.  

Generate token with approle credentials via vault cli:
* ensure environment variable `VAULT_ADDR` is set to: `https://vault.stage.devshift.net`
```
vault write auth/approle/login role_id=<placeholder> secret_id=<placeholder>
```
Copy the outputted token
### Checklist
**NOTE:** If any issues are encountered while completing the checklist, a rollback should be performed. See [Rollback](#rollback) section for details.

1) Verify that the vault deployment is healthy  
    a) Review logs within the leader pod for errors (`/v1/sys/leader` endpoint)  
    b) Shell to leader pod and confirm [audit log file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/prod/audit-backends/file-audit.yml#L15) exists  
    c) Confirm UI is reachable and log in

2) Review [production vault-manager](https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/k8s/ns/app-interface-production/deployments/vault-manager/pods) logs
    * `vault-manager` handles reconciliation for all instances defined within [vault config](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/services/vault.devshift.net/config). If any errors are encountered while attempting to retrieve state of `vault.stage.devshift.net`, look for log output indicating specific component that is failing.

3) Verify `vault-manager`s ability to perform reconcile operations on supported resource types.  

    a) Scale [vault-manager deployment](https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/k8s/ns/app-interface-production/deployments/vault-manager) to `0` (to avoid a reconcile run in midst of performing following steps)  

    b) Delete the following:
    * approle
        ```
        vault delete auth/approle/role/vault-version-testing
        ```

    * secret-engine
        ```
        vault secrets disable version-testing/
        ```

    * policy
        ```
        vault policy delete vault-version-testing
        ```

    * entity
        ``` 
        vault delete identity/entity/name/<your entity name>
        ```
        * delete **your own entity**  
        * in order to properly validate, an entity with an oidc alias (user within RH SSO) must be deleted
        * entity name is value of `org_username` within your user file. [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/teams/app-sre/users/dwelch.yml#L7)
        

    c) Scale `vault-manager` back to `1` and review logs on reconcile run. Confirm that the resources deleted above are recreated (log output / within UI)

    d) Scale `vault-manager` back to `0`

    e) Create the following:
    * approle
        ```
        vault write auth/approle/role/test-approle
        ```
    * secret-engine
        ```
        vault secrets enable -path=v1-testing -version=1 kv
        ```
        ```
        vault secrets enable -path=v2-testing -version=2 kv
        ```

    * policy
        ```
        vault policy write test-policy - <<EOF
        path "version-testing/*" {
          capabilities = ["read"]
        }
        EOF
        ```

    f) Scale `vault-manager` back to `1` and review logs on reconcile run. Confirm that the resources created above are successfully deleted (log output / within UI)

    **Why go through this process?**  
    Reliance on success of a `dry-run` is insufficient for evaluating behavior of vault-manager because the endpoints that create/delete the resources are not being interacted with. The preceding process provides assurance that behavior of endpoint is identical between versions
    * [example](https://github.com/app-sre/vault-manager/blob/master/toplevel/role/role.go#L282)

4) Dry run the `slack-usergroups` qontract-reconcile integration with vault portion of config toml set to target vault.stage.devshift.net   
    a) utilize [app-interface-approle credentials](https://vault.stage.devshift.net/ui/vault/secrets/app-interface/show/app-sre/vault/app-interface-approle) within stage  
    b) copy [slack-app-sre-groups bot_token](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/slack-app-sre-groups) to [stage bot_token](https://vault.stage.devshift.net/ui/vault/secrets/app-sre/show/creds/slack-app-sre-groups) and [pd_api_key](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/pd_api_key) to [stage pd_api_key](https://vault.stage.devshift.net/ui/vault/secrets/app-sre/show/ci-int/pd_api_key)  
    c) set both stage values back to `placeholder` after executing dry run

5) Run the [test vault devshift stage access](https://ci.int.devshift.net/job/gl-test-vault-devshift-net-stage-access/) Jenkins job
    * basic job within [ci.int](https://ci.int.devshift.net/) that attempts to retrieve a dumby secret from within `vault.stage.devshift.net` and provides assurance that incompatabilities with the Jenkins Vault plugin / JJB are not present with new version.
        * [job template definition](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/jenkins/vault.devshift.net/job-templates.yaml)


# Production Upgrades

## Announcement
Notification of upgrade via email should be made at least 2 business days in advance.  
At a minimum this email should contain: 
* date and time of upgrade
* anticipated duration of upgrade
* if downtime is anticipated. If so, the expected duration
* minor changes to workflows (ex: "within the UI, the oidc login has moved to x location")
    * major/breaking changes should be addressed while evaluating stage
* quality of life improvements

## Backups
S3: trigger the vault backup cronjob. example: [vault.devshift.net cronjob](https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/k8s/ns/vault-prod/cronjobs/vault-backup/). When logged into the cluster and targeting the proper namespace, you can trigger a job based on this cronjob by running: `oc create job --from=cronjob/vault-backup <name for job>`
RDS: [create a database snapshot](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateSnapshot.html)

## Upgrade
* Look at the saas file for the vault about to be upgraded. Ensure the vault instance's ref for gitlab.cee.redhat.com/service/vault-devshift-net is a version such that the k8s deployment strategy is set to `Recreate` and NOT `RollingUpdate` ([example](https://gitlab.cee.redhat.com/service/vault-devshift-net/-/blob/29de6cf6dd4c5e84cf24ddcf7c17ed5c41744aa6/openshift-vault.yaml#L30-33)).
    * this is done to ensure that incompatability issues are not encountered by a newer image replica co-existing aloneside original replicas
* Create an MR that updates the image tag parameter for desired instance.
    * [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/cicd/saas.yaml#L82)
    * **this should match existing image tag for vault.stage.devshift.net**

## Evaluate
1. Review [production vault-manager](https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/k8s/ns/app-interface-production/deployments/vault-manager/pods) logs
2. Review openshift-secrets integration logs
3. Verify communication with Jenkins 
    * ex: run [app-interface schema validator](https://ci.int.devshift.net/job/service-app-interface-gl-pr-check/) 
    * ensure you're validating against the correct Jenkins cluster (ci.ext for vault.ci.ext.devshift.net)

# Rollback
In the event that an upgrade yields unexpected behavior, perform the following actions to rollback to prior version.

1. Scale the deployment to `0`
2. Restore s3 backup
    * Vault upgrades can make backward-incompatibility changes to the data store. Data store should be rolled back before redeploying old binary
    *   ```
        aws s3 --profile <profile_for_bucket> sync --delete <s3_source_bucket> <s3_destination_bucket>
        ```
        example: 
        ```
        aws s3 --profile app-sre sync --delete s3://app-sre-vault-prod-backup-2022-08-03 s3://app-sre-vault-prod
        ```
    * `--delete` is utilized to ensure any new artifacts created by the upgrade are removed
3. [Restore rds HA coordination database from snapshot](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_RestoreFromSnapshot.html)
4. Revert MR changing image tag
    * this will automatically scale the deployment back up
5. Change Deployment Strategy back to `RollingUpdate` ([example](https://gitlab.cee.redhat.com/service/vault-devshift-net/-/merge_requests/53/diffs#77f031dd616efd80f5713f8c009d99075d45e56b))
