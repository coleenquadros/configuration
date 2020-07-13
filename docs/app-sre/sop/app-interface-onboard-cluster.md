<!-- TOC -->

- [Onboard a new OSDv4 cluster to app-interface](#onboard-a-new-osdv4-cluster-to-app-interface)
- [Additional configurations](#additional-configurations)
  - [Selecting a Machine CIDR for VPC peerings](#selecting-a-machine-cidr-for-vpc-peerings)
  - [VPC peering with app-interface](#vpc-peering-with-app-interface)
  - [Enable enhanced dedicated-admin](#enable-enhanced-dedicated-admin)
  - [Enable observability on a v4 cluster](#enable-observability-on-a-v4-cluster)
  - [Install the Container Security Operator](#install-the-container-security-operator)
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
    - Note that quota is driven via this [repo](https://gitlab.cee.redhat.com/service/ocm-resources/) and this is our [org file](https://gitlab.cee.redhat.com/service/ocm-resources/blob/master/data/uhc-production/orgs/12147054.yaml) in prod. The `@ocm-resources` Slack alias can also be pinged for any questions or if the change is urgent.

1. Click `Clusters`, then `Create Cluster`

1. Select `Red Hat OpenShift Dedicated` to provision a managed cluster

1. Select the following options
    - Billing model: Standard
    - Cluster name: Follow naming convention [here](https://docs.google.com/document/d/1OIe4JGbScz57dIGZztThLTvji056OBCfaHSvGAo7Hao)
    - Region: (recommended: us-east-1)
    - Availability: Multi-az
    - Choose appropriate instance type
    - Scale: Choose desired configuration (LoadBalancers are typically not needed as the default Routes include their own LoadBalancers).
    - Persistent storage: at least 600Gi (we need a bit more more than the default 100Gi to provision our observability stack)
    - Networking: Advanced (see [Additional configurations](#additional-configurations) section below.  If those conditions do not apply, then Simple networking will be fine)

1. Click create and wait for the cluster to be created

1. Create a new App-SRE Github Oauth Client.
    In order to create the OAuth client register to create a new application here:
    https://github.com/organizations/app-sre/settings/applications

    - Name: <cluster_name> cluster
    - Homepage URL: https://console-openshift-console.apps.<cluster_name>.<cluster_id>.p1.openshiftapps.com/
        * Note: cluster_id can be obtained from the console.  In OCM, click on the link for the cluster and then click on the `Open Console` button in the upper right corner.  Looking at the URL bar there should be something like: `oauth-openshift.apps.<cluster_name>.<cluster_id>.p1.openshiftapps.com`
    - Authorization callback URL: (Retrieve this from OCM)
        * Note: To get the callback URL do the following:
            - Go to OCM and click on the cluster.
            - Go to the `Access Control` tab and look for the `Identity providers` section.  Click the `Add identity provider` button.
            - On the following screen copy the url from the `OAuth callback URL` field.
            - Press the `Cancel` button to exit that screen.
            - The callback URL from OCM will end with `oauth2callback/GitHub`.  This needs to be changed to `oauth2callback/github-app-sre`.

1. Place the `client-id` and `client-secret` from the Oauth Client in a secret in [Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/list/integrations-input/ocm-github-idp/github-org-team/app-sre/) named `<cluster_name>-cluster`.

1. Add the cluster in app-interface

    ```yaml
    # /data/openshift/<cluster_name>/cluster.yml
    ---
    $schema: /openshift/cluster-1.yml

    labels:
      service: <service>

    name: <cluster_name>
    description: <cluster_name> cluster
    consoleUrl: "https://console-openshift-console.apps.<cluster_name>.<cluster_id>.p1.openshiftapps.com"
    kibanaUrl: ""
    prometheusUrl: ""
    serverUrl: "https://api.<cluster_name>.<cluster_id>.p1.openshiftapps.com:6443"

    auth:
      service: github-org-team
      org: app-sre
      team: <cluster_name>-cluster

    ocm:
      $ref: /dependencies/ocm/production.yml

    managedGroups:
    - dedicated-admins

    spec:
      provider: aws
      region: (Region chosen at cluster creation)
      major_version: 4
      multi_az: true
      nodes: (Compute value on OCM->cluster Overview tab)
      instance_type: (Instance type chosen at cluster creation)
      storage: (Persistent storage value on OCM->cluster Overview tab)
      load_balancers: (Load Balancer value on OCM->cluster Overview tab)

    network:
      vpc: (Machine CIDR value on OCM->cluster Overview tab)
      service: (Service CIDR value on OCM->cluster Overview tab)
      pod: (Pod CIDR value on OCM->cluster Overview tab)

    disable:
      e2eTests:
      - create-namespace
      - dedicated-admin-rolebindings
      - default-network-policies
      - default-project-labels

    internal: false

    awsInfrastructureAccess:
    - awsGroup:
        $ref: /aws/<aws account name>/groups/App-SRE-admin.yml
      accessLevel: read-only
    - awsGroup:
        $ref: /aws/<aws account name>/groups/App-SRE-admin.yml
      accessLevel: network-mgmt
    ```

1. Grant dedicated-admin access to App-SRE team

    ```yaml
    # /data/teams/app-sre/roles/app-sre.yml
    ...
    access:
        ...
        - cluster:
            $ref: /openshift/<cluster_name>/cluster.yml
        group: dedicated-admins
    ```

1. The above two steps will create an IDP on the cluster and give everyone in the App-SRE team dedicated-admin access.  Submit a MR to app-interface with the changes from the 2 steps above.

1. Once the MR has merged and the integrations have created the IDP and added the app-sre user accounts to the dedicated-admins group,  the `Access control` tab for the cluster in OCM should display an IDP as well as all the app-sre users as dedicate-admins.  Open the console in OCM by clicking `Open Console` for the cluster.

1. Verify that you see a link named `github-app-sre` (can take a few minutes to appear after the previous steps)

1. Add your user account to the github team
   - Navigate to the github team: https://github.com/orgs/app-sre/teams/<cluster_name>-cluster
   - Add your user account to this team

   Note: This step is a workaround and should be removed once the core chicken/egg problem is resolved

1. Login to the cluster using the `github-app-sre` link and retrieve the command to log into the cluster from the commandline.
   * Note: The command can be retrived by clicking on the username in the upper-right hand corner and selecting `Copy Login Command`.  A new page will open requiring re-authentication via the `github-app-sre` link.  Once authenticated click on the `Display token` link and copy the command provided and use it to log into the cluster on the command line.

1. Add the `app-sre-bot` ServiceAccount

    ```shell
    oc -n dedicated-admin create sa app-sre-bot
    oc -n dedicated-admin sa get-token app-sre-bot
    ```

1. NOTE: The remaining modifications can be completed in a single MR

1. Add the `app-sre-bot` credentials to vault at https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs

   Create a secret named after the <cluster_name>

       - server: https://api.<cluster_name>.<cluster_id>.p1.openshiftapps.com:6443
       - token: <token>
       - username: `dedicated-admin/app-sre-bot # not used by automation`

1. Add the `app-sre-bot` credentials to the cluster file in app-interface
   Create a secret named after the <cluster_name>

    ```yaml
    # /data/openshift/<cluster_name>/cluster.yml
    automationToken:
      path: app-sre/creds/kube-configs/<cluster_name>
      field: token

1. Add the `openshift-config` namespace in app-interface.  This adds the project request template to the cluster

    ```yaml
    # /data/openshift/<cluster_name>/namespaces/openshift-config.yml
    ---
    $schema: /openshift/namespace-1.yml

    labels: {}

    name: openshift-config
    description: <cluster_name> openshift-config namespace

    cluster:
      $ref: /openshift/<cluster_name>/cluster.yml

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

1. Re-enable e2e tests on the cluster by removing the following lines from the cluster definition:

    ```yaml
    # /data/openshift/<cluster_name>/cluster.yml
    ...
    disable:
      e2eTests:
      - create-namespace
      - dedicated-admin-rolebindings
      - default-network-policies
      - default-project-label
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
    - `prometheus.<cluster_name>.devshift.net`: `elb.apps.<cluster_name>.<clusterid>.p1.openshiftapps.com`
    - `alertmanager.<cluster_name>.devshift.net`: `elb.apps.<cluster_name>.<clusterid>.p1.openshiftapps.com`

    NOTE: Currently only Paul Bergene and Jean-Francois Chevrette can create these DNS entries. (Pending https://issues.redhat.com/browse/APPSRE-1987)

1. Configure a [deadmanssnitch](https://deadmanssnitch.com/) snitch for the new cluster. The snitch settings should be as follow:
    - Name: prometheus.<cluster_name>.devshift.net
    - Alert type: Basic
    - Interval: 15 min
    - Tags: app-sre
    - Alert email: sd-app-sre@redhat.com
    - Notes: Runbook: https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/sop/prometheus-deadmanssnitch.md

1. Add the deadmansnitch URL to this secret in Vault: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/alertmanager-integration

    - key: `deadmanssnitch-<cluster_name>-url`
    - value: the `Unique Snitch URL` from deadmanssnitch

1. Create an `openshift-customer-monitoring` namespace file for that specific cluster. Ex: https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/observability/namespaces/openshift-customer-monitoring.app-sre-prod-01.yml.

1. Add the new `openshift-customer-monitoring` namespace to the target namespaces in [saas-observability-per-cluster](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-observability-per-cluster.yaml) to deploy Prometheus and Alertmanager. New entries need to be added for Prometheus and Alertmanager:

    ```yaml
    # Prometheus
    ...
    - namespace:
      $ref: /services/observability/namespaces/openshift-customer-monitoring.<cluster_name>.yml
    ref: <sha>  # Use the same sha that existing entries are using
    parameters:
      CLUSTER_LABEL: <cluster_name>
      ENVIRONMENT: The environment, usually one of [integration|staging|production]
      EXTERNAL_URL: https://prometheus.<cluster_name>.devshift.net
    ...
    # Alertmanager
    - namespace:
      $ref: /services/observability/namespaces/openshift-customer-monitoring.<cluster_name>.yml
    ref: <sha>  # Use the same sha that existing entries are using
    parameters:
      ENVIRONMENT: The environment, usually one of [integration|staging|production]
      EXTERNAL_URL: https://alertmanager.<cluster_name>.devshift.net
    ```

    Note: The only entry that should not be using a specific SHA should be the app-sre-stage-01 cluster.  That cluster should be using a ref of master.

1. Create OAuth apps for Prometheus and Alertmanager [here](https://github.com/organizations/app-sre/settings/applications):
    - Name: `<cluster_name> <prometheus|alertmanager>`
    - Homepage URL: `https://<prometheus|alertmanager>.<cluster_name>.devshift.net`
    - Callback URL: `https://<prometheus|alertmanager>.<cluster_name>.devshift.net/oauth2/callback`

1. Update the Grafana datasources secret in Vault: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/grafana/datasources

    - Add a new key `<cluster_name>-prometheus` with value that is to be used as a password.  It can be any password.  It is recommended to use a tool like pwgen (ex to create a single 16 character random password: `pwgen -cns 32 1`

1. Create the following secrets in Vault to match the OAuth apps created in the previous step:
    - Generate the auth token value: `htpasswd -s -n app-sre-observability`
        At the password prompt, enter the password stored in the [grafana datasources secret](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/grafana/datasources) for the cluster
    - Create `https://vault.devshift.net/ui/vault/secrets/app-interface/show/<cluster_name>/openshift-customer-monitoring/alertmanager/alertmanager-auth-proxy` ([example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quay-s-ue1/openshift-customer-monitoring/alertmanager/alertmanager-auth-proxy))

        Secret keys:
        - auth: `<generated auth token value from above>`
        - client-id: <from_github_OAuth_app>
        - client-secret: <from_github_OAuth_app>
        - cookie-secret: <random_128_char_string> (Can use this [tool](https://pinetools.com/random-string-generator) or similar to generate )

    - Create `https://vault.devshift.net/ui/vault/secrets/app-interface/show/<cluster_name>/openshift-customer-monitoring/prometheus-auth-proxy` ([example](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quay-s-ue1/openshift-customer-monitoring/prometheus-auth-proxy))

        Secret keys:
        - auth: `<generated auth token value from above>`
        - client-id: <from_github_OAuth_app>
        - client-secret: <from_github_OAuth_app>
        - cookie-secret: <random_128_char_string> (Can use this [tool](https://pinetools.com/random-string-generator) or similar to generate )

    *Note:* If a new version of either secret is deployed to the cluster than both prometheus and alertmanager pods will need to be restarted

1. Add the `cluster-monitoring-view` ClusterRole for the cluster to https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/roles/app-sre-osdv4-monitored-namespaces-view.yml.

   *Note*: This file will need to be updated again once application namespaces are applied to the cluster. (Ex. https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/roles/app-sre-osdv4-monitored-namespaces-view.yml#L120-134)

1. Add the `observabilityNamespace` field on the cluster data file and reference the `openshift-customer-monitoring` namespace file created in the previous step. Ex: https://gitlab.cee.redhat.com/service/app-interface/blob/7ecd529584666d97b1418224b2772557807c6e1c/data/openshift/app-sre-prod-01/cluster.yml#L14-15

1. Create an `app-sre-observability-per-cluster` namespace file for that specific cluster. Ex: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/openshift/app-sre-prod-01/namespaces/app-sre-observability-per-cluster.yml

1. Add the new `app-sre-observability-per-cluster` namespace to the target namespaces in [saas-nginx-proxy.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/observability/cicd/saas/saas-nginx-proxy.yaml) to deploy nginx-proxy.

1. Add the new `app-sre-observability-per-cluster` namespace to the target namespaces in [saas-openshift-acme.yaml](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/cicd/ci-int/saas-openshift-acme.yaml) to deploy openshift-acme.

1. After the above changes have merged and the integrations have applied the changes, verify `https://<prometheus|alertmanager>.<cluster_name>.devshift.net` have valid ssl certificates by accessing the URLs.  If no security warning is given and the connection is secure as notifed by the browser than the ssl certificates are valid.

1. Edit the grafana data sources secret and add the following entries for the new cluster: (Ex https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/observability/grafana/grafana-datasources.secret.yaml#L43-73)
    - <cluster_name>-prometheus - the Prometheus instance in `openshift-customer-monitoring`
        ```yaml
        # /resources/observability/grafana/grafana-datasources.secret.yaml
            {
                "access": "proxy",
                "basicAuth": true,
                "basicAuthPassword": "{{{ vault('app-interface/app-sre/app-sre-observability-production/grafana/datasources', '<cluster_name>-prometheus') }}}",
                "basicAuthUser": "app-sre-observability",
                "editable": false,
                "jsonData": {
                    "tlsSkipVerify": true
                },
                "name": "<cluster_name>-prometheus",
                "orgId": 1,
                "type": "prometheus",
                "url": "https://prometheus.<cluster_name>.devshift.net",
                "version": 1
            }
        ```
    - <cluster_name>-cluster-prometheus - the Cluster's Prometheus instance
        ```yaml
        # /resources/observability/grafana/grafana-datasources.secret.yaml
            {
                "access": "proxy",
                "editable": false,
                "jsonData": {
                    "tlsSkipVerify": true,
                    "httpHeaderName1": "Authorization"
                },
                "name": "<cluster_name>-cluster-prometheus",
                "orgId": 1,
                "secureJsonData": {
                    "httpHeaderValue1": "Bearer {{{ vault('app-sre/creds/kube-configs/<cluster_name>', 'token') }}}"
                },
                "type": "prometheus",
                "url": "https://prometheus-k8s-openshift-monitoring.<cluster-url>",
                "version": 1
            }
        ```

    *Note*: The `<cluster-url>` can be retrieved from the cluster console.  Remove the `https://console-openshift-console` from the beginning and end with `openshiftapps.com`, removing all the trailing slashes and paths.

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
  - https://vault.devshift.net/ui/vault/secrets/app-interface/list/<cluster_name>/
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

3. Create a secret in Vault under the following path: `app-sre/creds/kube-configs/<cluster_name>`.
    * The secret should have a `token` key with the value being the token from step 2.
    * The secret should have a `server` key with the server URL. For example: `https://api.app-sre.openshift.com:443`.
    * The secret should have a `username` key with this text: `dedicated-admin/app-sre-bot # not used by automation`.
