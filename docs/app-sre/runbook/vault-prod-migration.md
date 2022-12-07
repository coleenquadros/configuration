# Vault Production Migration Runbook - TBD

# Summary

Vault production instance is going to be migrated from a public cluster
(app-sre-prod-01) to a cluster inside the VPN (appsrep05ue1) to enforce
security on the product.

# Details

**Service Name**: AppSRE Production Vault

**Start of Maintenance Window**: TBD

**Estimated duration of Maintenance Window**: 1h

**List of services impacted**: \<list all affected services here, not
just once being updated\>

**Engineering team participants**: AppSRE

**SREs assisting**: N/A

# Prerequisite Checklist

-   Complete this runbook

-   Runbook review

-   Send email notification X days before the migration

-   Move all integrations to internal cluster appsrep05ue1 - [APPSRE-6044](https://issues.redhat.com/browse/APPSRE-6044)

-   Allow connectivity between internal cluster and RDS (infra repo) - [APPSRE-6050](https://issues.redhat.com/browse/APPSRE-6050)

-   Move certificates from digicert to cert manager

-   Migrate Tekton pipelines to internal cluster - [APPSRE-6096](https://issues.redhat.com/browse/APPSRE-6096)

-   **Pre-submit all MRs in advance so they can be reviewed**

# Timeline

*For any items with deadlines/timeframes, add them here. A few samples
are given.*

# Runbook Summary

*This section summarizes the major steps involved during the maintenance
window.*

This maintenance operation will include the following activities:

-   **Deploy Vault Workloads on appsrep05ue1**

-   **Disable all integrations** **but terraform-aws-route53**

-   **Change DNS from app-sre-prod-01 to appsrep05ue1**

-   **Disable terraform-aws-route53 integration**

-   **Downscale deployment on app-sre-prod-01 and scale appsrep05ue1 deployment**

-   **Test vault & vault-secrets integration + CI Int/Ext**

-   **Re-enable all integrations**

-   **Remove Vault components from app-sre-prod-01**

# Runbook Pre-Steps (T-2d)

The following list **must be done in order**:

- [ ] Move all integrations running on app-sre-prod-01 to appsrep05ue1

- [ ] Enable RDS access for appsrep05ue1 to appsre aws account

- [ ] Deploy a vault-prod namespace to appsrep05ue1

- [ ] Move certificates from Digicert to cert manager

- [ ] Migrate Tekton pipelines to internal cluster

- [ ] Prepare MR to add a new target to saasfile to deploy vault into appsrep05ue1

- [ ] Prepare MR to change dns for vault.devshift.net to appsrep05ue1

- [ ] **Send** **reminder email** about the upcoming planned maintenance


# Runbook Steps (TBD)

*This lists the actual runbook steps during the maintenance window.*

## Deploy Vault Workloads on appsrep05ue1

***Description***

First step would be to deploy all the necessary workloads to the new
cluster appsrep05ue1, this will deploy all the necessary components on
the new cluster, but as the DNS is still pointing to the external
cluster, all components will keep working as expected.

Check that pods are able to run without any unexpected problem
(CrashLoopBackOff...) and if it's the case, downscale the deployment to
0 pods to prevent a leader change that can fall into these new
deployment pods generating errors on the vault usage.

***Success Criteria***

-   Vault deployment and route are present on appsrep05ue1 and pods start without issues

-   Deployment is scaled down to 0 pods to prevent errors before the DNS change

***Rollback***

-   Check that vault-prod deployment still contains the leader pod and it's capable of attending vault requests

    -   If leader is in any of the pods on appsrep05ue1, downscale both deployments to 0 and scale up app-sre-prod-01 deployment, this
    will cause a minor downtime while pods are recreated but
    everything will be working after pods are running

-   Delete the resources created in the MR this can be done using the
    integrations by adding a \`delete: true\` on the target of the
    saasfile or reverting the MR and deleting the resources manually.

## Disable all integrations but terraform-aws-route53

***Description***

After Vault is successfully deployed in appsrep05ue1, disable all
integrations that rely on Vault to prepare the DNS migration but
terraform-aws-route53 to be able to perform the DNS change.

***Success Criteria***

-   All integrations are disabled and vault migration can be performed
    without errors.

***Rollback***

Re-enable all integrations.

## Change DNS of vault.devshift.net to new cluster

***Description***

Change the TTL for vault.devshift.net to 5s to reduce the DNS propagation time and reduce the possible downtime to minimum. For this, there will be an MR ready, merge it and wait for the changes to apply before proceding with the DNS change.

A MR will be prepared to change the DNS zone of vault.devshift.net from
the current cluster app-sre-prod-01 to appsrep05ue1. Merge it and wait
for the changes to take place. This will make Vault being unacessible
until the next step is completed. Be aware that some errors / alerts can
fire.

***Success Criteria***

-   valut.devshift.net TTL is set to 5s before the DNS change
-   DNS for vault.devshift.net is pointing to appsrep05ue1 cluster

***Rollback***

From this point forward, vault will be unresponsive and app-interface /
QR will fail to make any changes.

To rollback the change:

-   Point vault to one of the IPs of the app-sre-prod-01 ELB in your local hosts file

-   Revert the DNS change in your local app-interface

-   Generate a new bundle and reconcile the changes following [this SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/188a67166607734d51fa2a9b79d48f30cf42405f/docs/app-sre/sop/app-interface-manual-deployment.md)

-   Revert the TTL change for vault.devshift.net record

## Disable terraform-aws-route53 integration

***Description***

After DNS change is done and terraform-aws-route53 has applied the changes, disable the integrations through unleash

***Success Criteria***

-   terraform-aws-route53 integration is disabled along with the rest of integrations.

***Rollback***

Re-enable terraform-aws-route53 integration.

## Downscale app-sre-prod-01 deployment and scale appsrep05ue1

***Description***

Downscale the deployment of Vault on app-sre-prod-01 and scale up to 3
replicas of the deployment on appsrep05ue1.

This will make Vault available from appsrep05ue1 and we will be able to
start re-enabling the integrations.

***Success Criteria***

-   Vault deployment on app-sre-prod-01 is scaled to 0 pods

-   Vault deployment on appsrep05ue1 is scaled to 3 pods and all pods are running fine.

-   Vault is accessible from vault.devshift.net

***Rollback***

-   Downscale the deployment on appsrep05ue1

-   Scale to 3 replicas the deployment on app-sre-prod-01

## Test Vault manually and vault-secrets integration + CI Int/Ext

***Description***

Test that Vault is working fine both from the integration perspective
and manually using it from the CLI / UI a script to test the creation,
reading and deletion of secrets is available on this gitlab gist (TBD)

Also test that CI Int and CI Ext can properly communicate with Vault
after the migration to ensure that everything is working properly.

***Success Criteria***

-   Vault works both via integrations and manually
-   CI int/ext work as expected

***Rollback***

-   Rollback steps 3 & 4 to recover Vault on app-sre-prod-01

## Re-enable all integrations

***Description***

Enable all integrations to recover the working state of app-interface /
qontract-reconcile and all related AppSRE tooling.

***Success Criteria***

-   All integrations are working as expected using the new Vault deployed on appsrep05ue1

***Rollback***

-   N/A

## Remove all vault components from app-sre-prod-01

***Description***

Remove all components related to vault from app-sre-prod-01 cluster

***Success Criteria***

-   Vault deployments, Openshift-Acme and routes are removed from app-sre-prod-01 cluster.

***Rollback***

-   N/A
