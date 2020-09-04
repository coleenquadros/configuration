- [Info](#info)
- [Process](#process)
  - [Provisioning the cluster](#provisioning-the-cluster)
  - [Provisioning Hive](#provisioning-hive)
  - [Hive Monitoring](#hive-monitoring)
  - [Provisioning OSD operators](#provisioning-osd-operators)
    - [Resources](#resources)
    - [Others](#others)
  - [Validations](#validations)
  - [Adding the shard to OCM](#adding-the-shard-to-ocm)
  - [OSD operators notes](#osd-operators-notes)

# Info

**Aim of this doc:** This SOP serves as a step-by-step process on how to provision a new Hive shard from zero (no cluster) to a fully functioning hive shard used by OCM

**Feeds into Goal:** Scale out OSD + Managed Services control plane to meet increasing business demand for capacity, reduce risk and scale.

**Definition of Done:** This initiative has met its delivery target when
- We have 4 hive clusters, entirely managed via a single consistent pipeline
- We have de-provisioned the OSD-3 based old-hive-prod
- We have proven, documented and monitor for all hive cluster hosted components and their engagement with upstream services

These instructions have been adapted from the [original google doc](https://docs.google.com/document/d/1oXcxKFsiNyBxUi0IizJ_VAfMe-CgtyqFLV0vNj4ib8I/edit)

# Process

## Provisioning the cluster

1. Follow the standard [Cluster Onboarding SOP](app-interface-onboard-cluster.md) using the following specs

    |                    | Staging     | Production |
    |--------------------|-------------|------------|
    | Availability       | Single zone | Multizone  |
    | Compute type       | m5.xlarge   | m5.xlarge  |
    | Compute count      | 4           | 9          |
    | Persistent storage | 600 GB      | 600 GB     |
    | Load balancers     | 0           | 0          |
    | Machine CIRD       | See note    | See note   |
    | Privacy            | Private     | Private    |

1. Configure VPC peering
1. Add hive-readers and hive-admins in `cluster.yml`
1. Add `ClusterRoleBinding` (required?)

   - Example: https://issues.redhat.com/projects/OHSS/issues/OHSS-495

## Provisioning Hive

Provisioning hive is a multi-step process:
1. Create a new environment for this hive cluster in [/data/products/osdv4/environments](/data/products/osdv4/environments) and make sure that the namespaces created from this moment on in the new cluster belong to it.
1. Add the hive namespaces. Add a new directory named after shard in [`/data/services/hive/namespaces`](/data/services/hive/namespaces) and copy the contents of another shard from the same hive environment (production, staging, etc)
1. Hive is deployed using a saas file. In order to deploy to a new shard, a new target must be added to the Hive saas file located here: [`/data/services/hive/cicd/ci-int/saas-hive.yaml`](/data/services/hive/cicd/ci-int/saas-hive.yaml)

1. Assign hive permissions in

    | Role file                            | Staging                                 | Production                               |
    |----------------------------------------|-----------------------------------------|------------------------------------------|
    | `data/teams/hive/roles/dev.yml`        | hive-admins<br>View access to namespace | hive-readers<br>View access to namespace |
    | `data/teams/hive/roles/qe.yml`         | hive-admins                             | hive-readers                             |
    | `data/teams/ocm/roles/dev.yml`         | hive-readers                            | hive-readers                             |
    | `data/teams/app-sre/roles/app-sre.yml` | hive-admins                             | hive-admins                              |

## Provisioning OSD operators

### Resources

#### operator resources (secrets, configmaps, etc)

Add a new directory named after the shard name here: [`/data/services/osd-operators/namespaces`](/data/services/osd-operators/namespaces)

It is typical to copy the content from another shard of the same environment as we are re-using the same configs and secrets for all shards.

Make sure that the namespaces belong to the environment created above.

#### saas deploy jobs

OSD operator are deployed using saas-file. In order to deploy to a new shard, a new target must be added to all of the OSD operators saas files located here: [`/data/services/osd-operators/cicd/saas`](/data/services/osd-operators/cicd/saas)

Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/8650 adds all the saas deploy files and selector syncsets mentioned below.

Take into account the following for two of the operators

##### cloud-ingress-operator

Ensure that the new hive shard's egress gateway IP is listed in [`/data/services/osd-operators/cicd/saas/saas-cloud-ingress-operator.yaml`](/data/services/osd-operators/cicd/saas/saas-cloud-ingress-operator.yaml). In orther to get this, you have to access the hive shard cluster AWS account through a impersonation link and then find under VPC > Nat Gateway. There are two ways to get that link:

* OCM console: Go to https://cloud.redhat.com/openshift, then click into your cluster and then you will get the details under "AWS infrastructure access" in the "Access Control" section

* `ocm` cli:

  * Get cluster id using:
      ```
      ocm list clusters
      ```
  * Get your impersonation link inspecting the output of:
      ```
      ID=xxxxx
      ocm get /api/clusters_mgmt/v1/clusters/$ID/aws_infrastructure_access_role_grants

      ```
    **Hint**: Look for your RedHat login name

##### aws-account-operator

Once deployed AWS account operator, it has to be properly verified and enabled. Open a JIRA card such as https://issues.redhat.com/browse/OSD-5045 to get this done.

You can find further details of this process at the end of this document.

### Others

#### SelectorSyncSets

Deploy SelectorSyncSets to new hive cluster

Example MR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/6823

#### ClusterImageSets

To deploy ClusterImageSets to a new cluster, add a target in the matching saas file: [`/data/services/osd-operators/cicd/saas/clusterimagesets`](/data/services/osd-operators/cicd/saas/clusterimagesets)

#### Managed-tenants

To deploy the managed-tenants SelectorSyncSets, add a target in the managed-tenants saas file: [`/data/services/app-sre/cicd/ci-int/saas-managed-tenants.yaml`](/data/services/app-sre/cicd/ci-int/saas-managed-tenants.yaml)

## Monitoring

1. Hive and some operators are still monitored from `app-sre-prod-01`. Add scrapeconfigs here: [`/resources/observability/prometheus/prometheus-app-sre-additional-scrapeconfig.secret.yaml`](/resources/observability/prometheus/prometheus-app-sre-additional-scrapeconfig.secret.yaml). Example MR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/8846
1. Alerts. Example MR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/8848

This may not be needed in the future, as it is being reworked in https://issues.redhat.com/browse/APPSRE-2348

## Adding the shard to OCM

1. Add `uhc-leadership` namespace. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/6829
1. Add Service Account references to hive, aws-account-opeator and gcp-project-operator namespaces from the uhc namespaces. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/7655
1. Update `uhc-clusters-service` secret to add new shards. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/7665. It is important to note that the shard it is first attached into a distant region.
1. The id field is set to a random uuid unique per shard (uuidgen can be used to generate one)

## Validations

- Consult SDA QE for a full stack test
- Test provisioning an AWS cluster
- Test provisioning a GCP cluster
- Test that private clusters can be provisioned
  - Can SRE-P access them?
  - Does Hive report them as Reachable?
- Make sure certificates are delivered quickly (currently within 10 minutes of Ready in OCM)
- Verify that all syncsetinstances report Applied == true. Currently the managed-velero sss takes a while, but after some minutes, all should report successfully applied.
- Verify that at least one round of osde2e tests ran successfully when using the new shard. Dashboards:
  - https://prow.ci.openshift.org/job-history/gs/origin-ci-test/logs/osde2e-prod-aws-e2e-default
  - https://openshift.github.io/osde2e/

## OSD operators notes

#### aws-account-operator

- (SREP) AWS account pool creation: this takes some time because AWS has to enable enterprise support before accounts can be used

1. Confirm the total number of used accounts

    Make sure there are at least 300 accounts left in the payer account. To check it, run the command above from the payer account and compare it against the account limit per payer account. The account limit is 5000 in production, and the shared stage/integration limit has been increased to 7500 by AWS.

    ```
    $ aws organizations list-accounts | jq '.Accounts[].Name' | wc -l
    ```

1. Make sure the operator is up and running in the new shard

    Check operator logs and confirm there are no errors

    ```
    $ oc get pods -n aws-account-operator
    ```

1. Deploy an AccountPool CR in the new hive shard

    Apply to the new shard an [AccountPool CR](https://github.com/openshift/aws-account-operator/blob/master/deploy/crds/aws_v1alpha1_accountpool_cr.yaml) with PoolSize = 50

    [Card to automate this step](https://issues.redhat.com/browse/OSD-4602)

1. Apply AWSFederatedRoles

    Apply all AWSFederatedRoles from the [deploy/crds](https://github.com/openshift/aws-account-operator/tree/master/deploy/crds) folder, using:

    ```
    $ osdctl federatedrole apply -f aws_v1alpha1_awsfederatedrole_networkmgmt_cr.yaml
    $ osdctl federatedrole apply -f aws_v1alpha1_awsfederatedrole_readonly_cr.yaml
    ```

    [Card to automate this step](https://issues.redhat.com/browse/OSD-4603)

1. Validate - Confirm accounts have been created to fill the Pool

    Check the account CRs in the new shard have been created, initialized and have EnterpriseSupport on, by checking the account CRs. Account creation and initialization takes around 1min/account, so initializing the initial pool of 50 accounts will take close to 1hour. After this period you’ll notice the account CRs will be moved to the PendingVerification status:

    ```
    $ oc get accounts -n aws-account-operator
    osd-creds-mgmt-wqdf9f   PendingVerification                                 13m
    osd-creds-mgmt-wsszvm   PendingVerification                                 14m
    osd-creds-mgmt-wzwpd9   PendingVerification                                14m
    osd-creds-mgmt-x78rz9   PendingVerification                                13m
    osd-creds-mgmt-x7jh4m   PendingVerification                                13m
    osd-creds-mgmt-xvt6h9   PendingVerification                                13m
    osd-creds-mgmt-zmrdht   PendingVerification                                 11m
    osd-creds-mgmt-zrfxh6   PendingVerification                                 11m
    osd-creds-mgmt-zz8tzf   PendingVerification                                 13m
    osd-creds-mgmt-zzfz9j   PendingVerification                                 10m
    ```

    In the **PendingVerification** status, the account is pending on action from AWS, processing a SupportCase the operator creates automatically to request EnterpriseSupport to be turned on. It's a manual operation performed in Amazon, so the time it takes can vary (from 30 minutes to 4 hours).

    When adding a production shard we should wait for all the accounts to be initialized and processed by AWS before turning on scheduling clusters to it.

#### certman-operator

We are re-using the same ConfigMap across all shards

We are re-using the same Secrets across all shards

#### deadmanssnitch-operator

We are re-using the same secrets (same API key) across all shards

#### gcp-project-operator

We are re-using the same secrets (gcp^credentials) across all shards

#### pagerduty-operator

It is known and acknowledged that we are starting with using the same key for the different shards, so there is no extra steps needed for pagerduty-operator once namespaces/CR are deployed through app-interface.

#### splunk-forwarder-operator

We are re-using the same secrets across all shards
