<!-- TOC -->

- [Onboard a new OSDv4 cluster to app-interface](#onboard-a-new-osdv4-cluster-to-app-interface)
- [Additional configurations](#additional-configurations)
  - [Selecting a Machine CIDR for VPC peerings](#selecting-a-machine-cidr-for-vpc-peerings)
  - [VPC peering with app-interface](#vpc-peering-with-app-interface)
  - [Enable enhanced dedicated-admin](#enable-enhanced-dedicated-admin)
  - [Enable observability on a v4 cluster](#enable-observability-on-a-v4-cluster)
  - [Enable logging (EFK)](#enable-logging-efk)
- [Offboard an OSDv4 cluster from app-interface](#offboard-an-osdv4-cluster-from-app-interface)
- [Legacy (v3)](#legacy-v3)
  - [Onboard a new OSDv3 cluster to app-interface](#onboard-a-new-osdv3-cluster-to-app-interface)

<!-- /TOC -->

# Onboard a new OSDv4 cluster to app-interface

To on-board a new OSDv4 cluster to app-interface, perform the following operations:

1. Login to https://cloud.redhat.com/openshift

1. Click `Subscriptions` and ensure you have enough quota to provision a cluster

    - Must have at least 1 cluster.aws of the desired type
    - Check that you have enough compute nodes quota for the desired total compute (4 are included in a single-az cluster, 6 in a multi-az)
    - Note that quota is driven via this [repo](https://gitlab.cee.redhat.com/service/ocm-resources/) and this is our [org file](https://gitlab.cee.redhat.com/service/ocm-resources/blob/master/data/uhc-production/orgs/12147054.yaml) in prod. Aaron Weitekamp

1. Click `Clusters`, then `Create Cluster`

1. Select `Red Hat OpenShift Dedicated` to provision a managed cluster

1. Select the following options

    - Billing model: Standard
    - Cluster name: (choose a short and descriptive name, ex: devtools01)
    - Region: (recommended: us-east-1)
    - Availability: Single/Multi-az
    - Scale: Choose desired configuration (LoadBalancers are typically not needed as the default Routes include their own LoadBalancers).
    - Persistent storage: 600Gi (we need a bit more more than the default 100Gi to provision our observability stack)
    - Networking: Basic (unless a special VPC config is needed - see Additional config section below)

1. Click create and wait for the cluster to be created

1. Contact App-SRE and request a new App-SRE Github Oauth Client. You will need to provide the callback URL.
  * Note: place the `client-id` and `client-secret` in a secret in [Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/integrations-input/ocm-github-idp/github-org-team/app-sre/) named `<cluster-name>-cluster`.

In order to create the OAuth client register to create a new application here:
https://github.com/organizations/app-sre/settings/applications

The callback template is:
https://oauth-openshift.apps.app-sre-prod-04.i5h0.p1.openshiftapps.com/oauth2callback/github-app-sre

Note: replace `app-sre-prod-04.i5h0` with the correct values.

1. App-SRE will provide the rest of the settings

    - Client ID: (provided by App-SRE)
    - Client Secret: (provided by App-SRE)
    - Type: Teams
    - Teams: (provided by App-SRE) should be: `<cluster-name>-cluster`

1. Add the cluster in app-interface

    ```yaml
    # /data/openshift/<cluster>/cluster.yml
    ---
    $schema: /openshift/cluster-1.yml

    labels:
      service: <cluster>

    name: <cluster>
    description: <cluster> cluster
    consoleUrl: ""
    kibanaUrl: ""
    prometheusUrl: ""
    serverUrl: "https://api.cluster..."

    auth:
      service: github-org-team
      org: app-sre
      team: <cluster>-cluster

    ocm:
      $ref: /dependencies/ocm/production.yml

    managedGroups:
    - dedicated-admins

    internal: false

    awsInfrastructureAccess:
    - awsGroup:
        $ref: /aws/app-sre/groups/App-SRE-admin.yml
      accessLevel: read-only
    - awsGroup:
        $ref: /aws/app-sre/groups/App-SRE-admin.yml
      accessLevel: network-mgmt
    ```

1. Grant dedicated-admin access to App-SRE team

    ```yaml
    # /data/teams/app-sre/roles/app-sre.yml
    ...
    access:
        ...
        - cluster:
            $ref: /openshift/<clustername>/cluster.yml
        group: dedicated-admins
    ```

1. Click `Open Console`

1. Verify that you see a link named `github-app-sre` (can take a few minutes to appear after the previous step)

1. Login to the cluster (as a dedicated-admin user)

1. Add the `app-sre-bot` ServiceAccount

    ```shell
    oc -n dedicated-admin create sa app-sre-bot
    oc -n dedicated-admin sa get-token app-sre-bot
    ```

1. Add the `app-sre-bot` credentials to vault at https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs/

1. Add the `app-sre-bot` credentials to the cluster file in app-interface

    ```yaml
    automationToken:
      path: app-sre/creds/kube-configs/<cluster>
      field: token
    ```

1. Add the `openshift-config` namespace in app-interface

    ```yaml
    # /data/openshift/<cluster>/namespaces/openshift-config.yml
    ---
    $schema: /openshift/namespace-1.yml

    labels: {}

    name: openshift-config
    description: <cluster> openshift-config namespace

    cluster:
      $ref: /openshift/<cluster>/cluster.yml

    app:
      $ref: /services/app-sre/app.yml

    environment:
      $ref: /products/app-sre/environments/<integration/stage/production>.yml

    managedResourceTypes:
    - Template
    - Project

    # when using `oc`, use the override as the kind instead of the resource
    managedResourceTypeOverrides:
    - resource: Project
      override: project.config.openshift.io

    managedResourceNames:
    # https://github.com/openshift/managed-cluster-config/blob/master/deploy/osd-project-request-template/02-role.dedicated-admins-project-request.yaml#L12
    - resource: Template
      resourceNames:
      - project-request
    - resource: Project
      resourceNames:
      - cluster

    openshiftResources:
    - provider: resource
      path: /setup/project-request.v4.template.yaml
    # this is a cluster scoped resources, but this should work for now
    - provider: resource
      path: /setup/cluster.project.v4.yaml
    ```

# Additional configurations

## Selecting a Machine CIDR for VPC peerings

If your cluster need to be peered with other clusters or AWS VPCs, it is required that the Machine CIDR is set to one that does not conflict with the other resources. This the case for most of the AppSRE clusters. In order to be able to select this you must used `Advanced` network definition option.

App-interface has network information for all v4 clusters it is managing. Thus, running a simple query in app-interface can help retrieve known CIDR and make a decision on which CIDR to use for the new clusters

```
{clusters_v1{name network{vpc service pod}}}
```

There is a convenience utility to fetch this data: `qontract-cli get clusters-network`.

The value of the NETWORK.VPC must be unique (find an unused /24 network), however, the NETWORK.SERVICE and NETWORK.POD can be reused (`10.120.0.0/16` and `10.128.0.0/14` respectively).

Note that the host prefix must be set to /23.

## VPC peering with app-interface

[app-interface-cluster-vpc-peerings.md](app-interface-cluster-vpc-peerings.md)

## Enable enhanced dedicated-admin

Some clusters may require enhanced dedicated-admin privileges. The process to get it enabled for a cluster can be found here: https://github.com/openshift/ops-sop/blob/master/v4/howto/extended-dedicated-admin.md#non-ccs-clusters

## Enable observability on a v4 cluster

1. Create DNS records:
- `prometheus.<cluster-name>.devshift.net`: `elb.apps.<clustername>.<clusterid>.p1.openshiftapps.com`
- `alertmanager.<cluster-name>.devshift.net`: `elb.apps.<clustername>.<clusterid>.p1.openshiftapps.com`

1. Configure a [deadmanssnitch](https://deadmanssnitch.com/) snitch for the new cluster. The snitch settings should be as follow:
    - Name: <cluster name>
    - Alert type: Basic
    - Interval: 15 min
    - Tags: app-sre
    - Alert email: sd-app-sre@redhat.com
    - Notes: Runbook: https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/sop/prometheus-deadmanssnitch.md

1. Add the deadmansnitch URL to this secret in Vault: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/alertmanager-integration

    - key: `deadmanssnitch-<clustername>-url`
    - value: the deadmanssnitch URL

1. Create an `openshift-customer-monitoring` namespace file for that specific cluster. Ex: https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/observability/namespaces/openshift-customer-monitoring.app-sre-prod-01.yml.

1. Add the new `openshift-customer-monitoring` namespace to the target namespaces in [saas-observability-per-cluster](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-observability-per-cluster.yaml) to deploy Prometheus and Alertmanager. Some options to look out for:
    - `clusterLabel` for the prometheus resource
    - `externalUrl` for both the `prometheus` and `alertmanager` resources

1. Create OAuth apps for Prometheus and Alertmanager:
    - Name: `<prometheus|alertmanager>.<cluster>.devshift.net`
    - Home page: `https://<prometheus|alertmanager>.<cluster>.devshift.net`
    - Callback URL: `https://<prometheus|alertmanager>.<cluster>.devshift.net/oauth2/callback`

1. Create the following secrets in Vault to match the OAuth apps created in the previous step:
    - https://vault.devshift.net/ui/vault/secrets/app-interface/show/<clustername>/openshift-customer-monitoring/alertmanager/alertmanager-auth-proxy ([example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quay-s-ue1/openshift-customer-monitoring/alertmanager/alertmanager-auth-proxy))
    - https://vault.devshift.net/ui/vault/secrets/app-interface/show/<clustername>/openshift-customer-monitoring/prometheus-additional-scrape-config ([example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quay-s-ue1/openshift-customer-monitoring/prometheus-additional-scrape-config))
    - https://vault.devshift.net/ui/vault/secrets/app-interface/show/<clustername>/openshift-customer-monitoring/prometheus-auth-proxy ([example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quay-s-ue1/openshift-customer-monitoring/prometheus-auth-proxy))

    *Note:* Both prometheus and alertmanager pods need a restart after a new secret is pushed

1. Add the `cluster-monitoring-view` cluster role to https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/roles/app-sre-osdv4-monitored-namespaces-view.yml.

1. Add the `observabilityNamespace` field on the cluster data file and reference the `openshift-customer-monitoring` namespace file created in the previous step. Ex: https://gitlab.cee.redhat.com/service/app-interface/blob/7ecd529584666d97b1418224b2772557807c6e1c/data/openshift/app-sre-prod-01/cluster.yml#L14-15

1. Create an `app-sre-observability-per-cluster` namespace file for that specific cluster. Ex: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/openshift/app-sre-prod-01/namespaces/app-sre-observability-per-cluster.yaml

1. Add the new `app-sre-observability-per-cluster` namespace to the target namespaces in [saas-nginx-proxy.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-nginx-proxy.yaml) to deploy nginx-proxy.

1. Add the new `app-sre-observability-per-cluster` namespace to the target namespaces in [saas-openshift-acme.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/cicd/ci-int/saas-openshift-acme.yaml) to deploy openshift-acme.

1. Verify `https://<prometheus|alertmanager>.<cluster>.devshift.net` have valid ssl certificates.

1. Update the Grafana datasources secret in Vault: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/grafana/datasources

    - Add a new key `<clustername>-prometheus` with a value that matches the `auth` key in the https://vault.devshift.net/ui/vault/secrets/app-interface/show/<clustername>/openshift-customer-monitoring/prometheus-auth-proxy secret (TODO: explain how)

1. Add Grafana data sources for the new cluster:
    - <clustername>-prometheus - the Prometheus instance in `openshift-customer-monitoring`
    - <clustername>-cluster-prometheus - the Cluster's Prometheus instance

1. Rollout Grafana to make the data source changes effective.

## Install the Container Security Operator

The Container Security Operator (CSO) brings Quay and Clair metadata to
Kubernetes / OpenShift. We use the vulnerabilities information in the tenants
dashboard and in the monthly reports.

1. Create a ticket to [OHSS](https://issues.redhat.com/secure/CreateIssue.jspa?pid=12323823&issuetype=3),
requesting `extended-dedicated-admin` for the user `app-sre-bot` on the new
cluster (provide the cluster id).

1. Create an `container-security-operator` namespace file for that specific
cluster. Example:

File name: `app-sre-cso-per-cluster.yml`

Content:

```yaml
---
$schema: /openshift/namespace-1.yml

labels: {}

name: container-security-operator
description: namespace for the app-sre per-cluster Container Security Operator

cluster:
  $ref: /openshift/<cluster>/cluster.yml

app:
  $ref: /services/container-security-operator/app.yml

environment:
  $ref: /products/dashdot/environments/production.yml

networkPoliciesAllow:
- $ref: /openshift/<cluster>/namespaces/openshift-operator-lifecycle-manager.yml
```

If the `openshift-operator-lifecycle-manager` namespace is not yet defined in
app-interface, you have to define it also:

File name: `openshift-operator-lifecycle-manager.yml`

Content:

```yaml
---
$schema: /openshift/namespace-1.yml

labels: {}

name: openshift-operator-lifecycle-manager

cluster:
  $ref: /openshift/<cluster>/cluster.yml

app:
  $ref: /services/app-sre/app.yml

environment:
  $ref: /products/app-sre/environments/production.yml

description: openshift-operator-lifecycle-manager namespace
```

1. Add the new `container-security-operator` namespace to the target
namespaces in the
[saas.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/container-security-operator/cicd/saas.yaml)
to deploy the Container Security Operator. Example:

```yaml
resourceTemplates:
- name: container-security-operator
  url: https://github.com/app-sre/container-security-operator
  path: /openshift/container-security-operator.yaml
  targets:
  ...
  - namespace:
      $ref: /openshift/app-sre-stage-01/namespaces/app-sre-cso-per-cluster.yml
    ref: <commit_hash>
```

## Enable logging (EFK)

The EFK stack is currently opt-in and installed by customers.

Installing cluster logging can be done in two steps.
1. Subscribe to the Elasticsearch and Cluster Logging operators
2. Create the logging instalce

Example MR: https://gitlab.cee.redhat.com/service/app-interface/commit/bcf699c973d04a7a539219a37f4caeca1b72d21b

OSD docs for reference: https://docs.openshift.com/dedicated/4/logging/dedicated-cluster-deploying.html

# Offboard an OSDv4 cluster from app-interface

To off-board an OSDv4 cluster from app-interface, perform the following operations:

1. Verify that the cluster is no longer in use and create a MR to remove it from app-interface.
  - Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/5793
  - Things to look out for:
    - openshift-customer-monitoring namespace does not contain any tenant monitoring resources
    - if the cluster has existing VPC peerings, remove them in a separate MR first

1. Merge the merge request before proceeding.

1. Delete the cluster from the Dead Man's Snitch console: https://deadmanssnitch.com/cases/0693dfc1-40e9-4e84-89b2-30d696e77e06/snitches?tags=app-sre

1. Delete the cluster from the OCM console: https://cloud.redhat.com/openshift

1. Delete the cluster credentials from Vault (verify that no secrets are in use):
  - https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs/
  - https://vault.devshift.net/ui/vault/secrets/app-interface/list/<cluster>/
  - https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/alertmanager-integration
  - https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/grafana/datasources


# Legacy (v3)

## Onboard a new OSDv3 cluster to app-interface

To on-board a new OSDv3 cluster to app-interface, perform the following operations:

1. Create `app-sre-bot` ServiceAccount in the `dedicated-admin` namespace and add permissions to the ServiceAccount:

```shell
oc -n dedicated-admin create serviceaccount app-sre-bot
```

2. Get the token of the `app-sre-bot` SeriveAccount:

```shell
oc -n dedicated-admin sa get-token app-sre-bot
```

3. Create a secret in Vault under the following path: `app-sre/creds/kube-configs/<cluster-name>`.
    * The secret should have a `token` key with the value being the token from step 2.
    * The secret should have a `server` key with the server URL. For example: `https://api.app-sre.openshift.com:443`.
    * The secret should have a `username` key with this text: `dedicated-admin/app-sre-bot # not used by automation`.
