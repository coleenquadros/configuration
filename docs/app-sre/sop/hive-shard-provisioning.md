- [Info](#info)
- [Process](#process)
  - [Provisioning the cluster](#provisioning-the-cluster)
  - [Label cluster as CCS](#label-cluster-as-ccs)
  - [Provisioning Hive](#provisioning-hive)
  - [Provisioning OSD operators](#provisioning-osd-operators)
    - [Resources](#resources)
    - [Others](#others)
  - [Provisioning backplane](#provisioning-backplane)
  - [Monitoring](#monitoring)
  - [Adding the shard to OCM](#adding-the-shard-to-ocm)
  - [Validations](#validations)
    - [Test provisioning an AWS cluster](#test-provisioning-an-aws-cluster)
    - [Test provisioning a GCP cluster](#test-provisioning-a-gcp-cluster)
    - [Test that private clusters can be provisioned](#test-that-private-clusters-can-be-provisioned)
  - [Disabling shards from rotation](#disabling-shards-from-rotation)
    - [Verify that at least one round of osde2e tests ran successfully when using the new shard. Dashboards:](#verify-that-at-least-one-round-of-osde2e-tests-ran-successfully-when-using-the-new-shard-dashboards)
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

    |                            | Staging     | Production |
    |----------------------------|-------------|------------|
    | Availability               | Single zone | Multizone  |
    | Compute type               | m5.xlarge   | m5.xlarge  |
    | Compute count (autoscale)  | 4 - 25      | 9 - 27     |
    | Persistent storage         | 600 GB      | 600 GB     |
    | Load balancers             | 0           | 0          |
    | Machine CIRD               | See note    | See note   |
    | Privacy                    | Private     | Private    |

1. Configure VPC peering
1. Configure TGW attachments to the appropriate PrivateLink AWS account (for example, production shards should be attached to the osd-privatelink-prod AWS account)
1. Add hive-readers and hive-admins in `cluster.yml`
1. Add External Configuration labels to the cluster:
    ```yaml
    externalConfiguration:
    labels:
        ext-managed.openshift.io/hive-shard: "true"
    ```
## Label cluster as CCS

1. Label cluster as CCS

    Create a ticket to [OHSS](https://issues.redhat.com/secure/CreateIssue.jspa?pid=12323823&issuetype=3) requesting `ccs` on the new cluster (provide the cluster id).

    Here's an [example](https://issues.redhat.com/browse/OHSS-1752)

    *NOTE*: It wouldn't block it from being functional, just limit number of clusters it can provision in a day.

## Provisioning Hive

Provisioning hive is a multi-step process:
1. Create a new environment for this hive cluster in [/data/products/osdv4/environments](/data/products/osdv4/environments) and make sure that the namespaces created from this moment on in the new cluster belong to it.
1. Add the hive namespaces. Add a new directory named after shard in [`/data/services/hive/namespaces`](/data/services/hive/namespaces) and copy the contents of another shard from the same hive environment (production, staging, etc) example [1](https://gitlab.cee.redhat.com/service/app-interface/-/blob/12523a31d486a691568045c9484389d2a8d266de/data/openshift/hivep04ew2/cluster.yml#L88-90) [2](https://gitlab.cee.redhat.com/service/app-interface/-/blob/12523a31d486a691568045c9484389d2a8d266de/data/openshift/hivep04ew2/cluster.yml#L109-116)
1. Add an AWS IAM service account for PrivateLink access for the new shard. [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/12523a31d486a691568045c9484389d2a8d266de/data/services/hive/namespaces/hivep01ue1/hive-production.yml#L124-142)
1. Add all existing AWS IAM service account secrets to the new shard. [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/12523a31d486a691568045c9484389d2a8d266de/data/services/hive/namespaces/hivep04ew2/hive-production.yml#L40-64)
    * For production, use the [shared-resources](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/hive/shared-resources/production-terraform-output-secrets.yml) file.
1. Hive is deployed using a saas file. In order to deploy to a new shard, a new target must be added to the Hive saas file located here: [`/data/services/hive/cicd/ci-int/saas-hive.yaml`](/data/services/hive/cicd/ci-int/saas-hive.yaml)

1. Assign hive permissions in

    | Role file                                    | Staging                                 | Production                               |
    |----------------------------------------------|-----------------------------------------|------------------------------------------|
    | `data/teams/hive/roles/dev.yml`              | hive-admins<br>View access to namespace | hive-readers<br>View access to namespace |
    | `data/teams/hive/roles/qe.yml`               | hive-admins                             | hive-readers                             |
    | `data/teams/ocm/roles/dev.yml`               | hive-readers                            | hive-readers                             |
    | `data/teams/app-sre/roles/app-sre.yml`       | hive-admins                             | hive-admins                              |
    | `data/teams/sd-sre/roles/sre.yml`            | dedicated-readers                       | dedicated-readers                        |
    | `data/teams/sd-sre/roles/sre-breakglass.yml` | -                                       | hive-frontend                            |

## Provisioning OSD operators

### Resources

#### operator resources (secrets, configmaps, etc)

Add a new directory named after the shard name here: [`/data/services/osd-operators/namespaces`](/data/services/osd-operators/namespaces). A few notes about this:

* It is typical to copy the content from another shard of the same environment as we are re-using the same configs and secrets for all shards. Unless instructed otherwise, start with a prod as an example as it will have a really working setup.
* Make sure that the namespaces belong to the environment created above.

#### saas deploy jobs

OSD operator are deployed using saas-file. In order to deploy to a new shard, a new target must be added to all of the OSD operators saas files located here: [`/data/services/osd-operators/cicd/saas`](/data/services/osd-operators/cicd/saas)

Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/8650 adds all the saas deploy files and selector syncsets mentioned below.

Take into account the following for two of the operators

##### cloud-ingress-operator

Ensure that the new hive shard's egress gateway IP is listed in
[`/data/services/osd-operators/cicd/saas/saas-cloud-ingress-operator.yaml`](/data/services/osd-operators/cicd/saas/saas-cloud-ingress-operator.yaml).
In order to get this, you have to access the hive shard cluster AWS account
through a impersonation link. There are two ways to get the impersonation link:

* OCM console: Go to https://console.redhat.com/openshift, then click into your
cluster and then you will get the details under "AWS infrastructure access" in
the "Access Control" section.

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

Having access to the AWS console, find the egress gateway IP under:

* VPC -> NAT Gateways -> Elastic IP address

IMPORTANT:

* The "Elastic IP address" from all NAT gateways should be listed. 
* Add `/32` to each os the IPs in the saas file list. 

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

To deploy the managed-tenants manifests, add a target in the managed-tenants
saas files:

* [`/data/services/addons/cicd/ci-int/saas-mt-SelectorSyncSet.yaml`](/data/services/addons/cicd/ci-int/saas-mt-SelectorSyncSet.yaml)
* [`/data/services/addons/cicd/ci-int/saas-mt-PagerDutyIntegration.yaml`](/data/services/addons/cicd/ci-int/saas-mt-PagerDutyIntegration.yaml)
* [`/data/services/addons/cicd/ci-int/saas-mt-DeadmansSnitchIntegration.yaml`](/data/services/addons/cicd/ci-int/saas-mt-DeadmansSnitchIntegration.yaml)

## Provisioning backplane

Backplane should run on all v4 hive, to deploy backplane on a new v4 hive cluster:

1. Create a new enviroment file under here: [`/data/services/backplane/namespaces`](/data/services/backplane/namespaces).

2. Add a new target in the saas file: [`/data/services/backplane/cicd/saas/saas-backplane-api.yaml`](/data/services/backplane/cicd/saas/saas-backplane-api.yaml).

## Monitoring

All v4 hive shards (clusters) are monitored with their own workload prometheus, which runs in the `openshift-customer-monitoring` namespace.

1. Check that an `openshift-customer-monitoring` namespace file exists for the specific hive cluster. This is usually done as part of [onboarding any new cluster](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/app-interface-onboard-cluster.md#step-4-observability)

1. Use the hive monitoring boilerplate to add hive specific monitoring rules and servicemonitors to the `openshift-customer-monitoring` namespace file for the specific hive cluster:

```
# ServiceMonitor
## Hive
- provider: resource-template
  type: extracurlyjinja2
  path: /services/hive/hive-controllers.servicemonitor.yaml
  variables:
    namespace: hive
- provider: resource-template
  type: extracurlyjinja2
  path: /services/hive/hive-clustersync.servicemonitor.yaml
  variables:
    namespace: hive
- provider: resource-template
  type: extracurlyjinja2
  path: /services/osd-operators/hive-operator-generic.servicemonitor.yaml
  variables:
    operator_name: aws-account-operator
- provider: resource-template
  type: extracurlyjinja2
  path: /services/osd-operators/hive-operator-generic.servicemonitor.yaml
  variables:
    operator_name: certman-operator
- provider: resource-template
  type: extracurlyjinja2
  path: /services/osd-operators/hive-operator-generic.servicemonitor.yaml
  variables:
    operator_name: deadmanssnitch-operator
- provider: resource-template
  type: extracurlyjinja2
  path: /services/osd-operators/hive-operator-generic.servicemonitor.yaml
  variables:
    operator_name: pagerduty-operator


# PrometheusRule
## SHARDNAME
- provider: resource-template
  type: extracurlyjinja2
  path: /services/hive/hive-production-common.prometheusrules.yaml
  variables:
    shard_name: SHARDNAME
    aws_account_operator_accounts_threshold: 4950
    grafana_datasource: SHARDNAME-prometheus

```

1. Make sure you're using the correct rules depending on the environment (integration/stage/production). Pay close attention to the value for aws_account_operator_accounts_threshold, which depends on the environment.

1. Make RBAC changes and allow network traffic from `openshift-customer-monitoring` on all relevant namespaces. For example, see PR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/10168/diffs. Note that you'll need to do the same for the `hive` namespace on the cluster

1. Add federation config for shard metrics in [/resources/observability/prometheus/prometheus-app-sre-additional-scrapeconfig.secret.yaml](/resources/observability/prometheus/prometheus-app-sre-additional-scrapeconfig.secret.yaml)
    - You can copy the block from another shard
    - Make sure the targets hostnames match the cluster hostname
    - Ensure the appsre_env label is set to the correct environment

Post file creation checks:

1. Make sure SHARDNAME is replaced by the actual shard name, for example `hivep01ue1`

At this point, the monitoring is all set, and you're ready to move on to the next step


## Adding the shard to OCM

1. Add `uhc-leadership` namespace. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/6829
1. Add `view` access to the `uhc-leadership` namespace to the OCM [dev role](/data/teams/ocm/roles/dev.yml).
1. Add Service Account references to hive, aws-account-opeator and gcp-project-operator namespaces from the uhc namespaces. Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/7655
1. Update `clusters-service` secret to add new shards. Example: https://gitlab.cee.redhat.com/service/app-interface/-/blob/55beecac/data/services/ocm/shared-resources/production.yml#L31-35.
1. The id field is set to a random uuid unique per shard (uuidgen can be used to generate one)

## Adding the shard to support PrivateLink

1. Add the shard's information to the relevant environment's HiveConfig (under .spec.awsPrivateLink.associatedVPCs).
    * The VPC ID can be retreived from the cluster's AWS account using the AWS Infrastructure Access feature.
    * The HiveConfig files live in app-interface and are referenced from the hive namespace files.

## Validations

When creating clusters make sure that you're logged in the correct environment. Use the option `--url` of the `ocm login` command to connect to the proper environment.

* You can follow the cluster creation using the `ocm status` command
* Make sure you delete the clusters created with the `ocm delete /api/clusters_mgmt/v1/clusters/<CLUSTER ID>` command

For all the created clusters perform the following validations:

* Make sure certificates are delivered quickly (at least 10 minutes from `Ready` status reported by `ocm`). You can inspect the console url:

    ```shell
    ID=<cluster id>
    CONSOLE=$(ocm get cluster $ID | jq -r '("console-openshift-console.apps." + .name + "." + .dns.base_domain)')
    openssl s_client -servername $CONSOLE -showcerts -connect $CONSOLE:443 2>/dev/null </dev/null | openssl x509 -text
    ```

    and make sure that it is not self signed. Alternative you can make sure that `curl` doesn't complain (but that needs that you have up to date CAs installed in your system, which is not always the case)

* Verify that all syncsetinstances report `Applied == true`. Currently the managed-velero sss takes a while, but after some minutes, all should report successfully applied. In order to do this you have to inspect the `ClusterSync` CRD in the shard project related to the cluster you have created, e.g

   ```shell
   oc get clustersync -n uhc-staging-1fjs44ifpfolii89opv6ua394b1qti0l -o yaml | grep result | sort --uniq
         result: Success
   ```

### Test provisioning an AWS cluster

In the following example we create a cluster pinning it to the shard we have added to OCM before.

```shell
ocm post /api/clusters_mgmt/v1/clusters <<EOJ
{
    "byoc": false,
    "name": "rporresm-aws01",
    "region": {
        "id": "us-east-1"
    },
    "nodes": {
        "compute": 4,
        "compute_machine_type": {
            "id": "m5.xlarge"
        }
    },
    "managed": true,
    "cloud_provider": {
        "id": "aws"
    },
    "multi_az": false,
    "load_balancer_quota": 0,
    "storage_quota": {
        "unit": "B",
        "value": 107374182400
    }
    ,
    "properties": {
        "provision_shard_id": "11015a3e-9e4d-4cf1-93d7-06fb2cf83a1c"
    }
}
EOJ
```

### Test provisioning a GCP cluster

Example

```shell
ocm post /api/clusters_mgmt/v1/clusters <<EOJ
{
    "byoc": false,
    "name": "gshereme-test3-sep10",
    "region": {
        "id": "us-east1"
    },
    "nodes": {
        "compute": 4,
        "compute_machine_type": {
            "id": "custom-4-16384"
        }
    },
    "managed": true,
    "cloud_provider": {
        "id": "gcp"
    },
    "multi_az": false,
    "load_balancer_quota": 0,
    "storage_quota": {
        "unit": "B",
        "value": 107374182400
    },
    "properties": {
        "provision_shard_id": "11015a3e-9e4d-4cf1-93d7-06fb2cf83a1c"
    }
}
EOJ
```

### Test that private clusters can be provisioned

Example:

```shell
ocm post /api/clusters_mgmt/v1/clusters <<EOJ
{
    "byoc": false,
    "name": "rporresm-aws02p",
    "region": {
        "id": "us-east-1"
    },
    "nodes": {
        "compute": 4,
        "compute_machine_type": {
            "id": "m5.xlarge"
        }
    },
    "managed": true,
    "cloud_provider": {
        "id": "aws"
    },
    "multi_az": false,
    "load_balancer_quota": 0,
    "storage_quota": {
        "unit": "B",
        "value": 107374182400
    },
    "network": {
        "machine_cidr": "10.225.0.0/16",
        "service_cidr": "172.30.0.0/16",
        "pod_cidr": "10.128.0.0/14"
    },
    "api": {
        "listening": "internal"
    },
    "properties": {
        "provision_shard_id": "11015a3e-9e4d-4cf1-93d7-06fb2cf83a1c"
    }
}
EOJ
```

Once created, there are two further validations

* Can SRE-P access them? Create a JIRA card in OHSS project to make sure that SREP can access the cluster. Example: https://issues.redhat.com/browse/OHSS-1321
* Does Hive report them as Reachable? To check this, you have to go into the cluster project in the hive shard (`uhc-<environment>-<cluster_id>`) and inspect the `ClusterDeployment` CRD.  Under the `.status.conditions` section you will find the `type` `ActiveAPIURLOverride` that should tell you that the cluster is reachable. e.g.

    ```shell
    oc get clusterdeployment rporresm-aws02p -o json | jq '.status.conditions[] | select(.type | contains("ActiveAPIURLOverride"))'
    {
      "lastProbeTime": "2020-09-10T16:20:10Z",
      "lastTransitionTime": "2020-09-10T16:20:10Z",
      "message": "cluster is reachable",
      "reason": "ClusterReachable",
      "status": "True",
      "type": "ActiveAPIURLOverride"
    }
    ```

## Disabling shards from rotation

A shard can be taken out of rotation pick for new clusters, by setting its status to "maintenance".

### Verify that at least one round of osde2e tests ran successfully when using the new shard. Dashboards:

osd2e2e tests use `osdctl` to create new clusters periodically and run validations on top of them. At the moment `osdctl` does not support to specify a shard, so these tests will be run once we have attached the shard to a region. Once that is done, wait a few hours and check the following urls to see a cluster associated in the new shard passing osde2e tests.

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
