# Onboard a new OSDv4 cluster to app-interface

To on-board a new OSDv4 cluster to app-interface, perform the following operations:

1. Login to https://cloud.redhat.com/

1. Go to `OpenShift Cluster Manager`

1. Click `Subscriptions` and ensure you have enough quota to provision a cluster
    
    - Must have at least 1 cluster.aws of the desired type
    - Check that you have enough compute nodes quota for the desired total compute (4 are included in a single-az cluster, 6 in a multi-az)

1. Click `Clusters`, then `Create Cluster`

1. Select `Red Hat OpenShift Dedicated` to provision a managed cluster

1. Select the following options

    - Billing model: Standard
    - Cluster name: (choose a short and descriptive name, ex: devtools01)
    - Region: (recommended: us-east-1)
    - Availability: Single/Multi-az
    - Scale: Choose desired configuration (LoadBalancers are typically not needed)
    - Networking: Basic (unless a special VPC config is needed)

1. Click create and wait for the cluster to be created

1. Click `Access Control`, then `Add Identity Provider`

    - Provider: Github
    - Name: github-app-sre
    - Mapping Method: claim

1. Contact App-SRE and request a new App-SRE Github Oauth Client. You will need to provide the callback URL.

1. App-SRE will provide the rest of the settings

    - Client ID: (provided by App-SRE)
    - Client Secret: (provided by App-SRE)
    - Type: Teams
    - Teams: (provided by App-SRE)

1. Click `Open Console`

1. Verify that you see a link named `github-app-sre` (can take a few minutes to appear after the previous step)

1. Go back to your cluster in OCM, then `Access control`

1. Add the github username of the App-SRE team member who is setting up your cluster in app-interface to grant dedicated-admin access

1. Login to the cluster as a dedicated-admin user

1. Add the `app-sre-bot` ServiceAccount

    ```shell
    oc -n dedicated-admin create sa app-sre-bot
    oc -n dedicated-admin sa get-token app-sre-bot
    ```

1. Add the `app-sre-bot` credentials to vault at https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs/

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

    automationToken:
      path: app-sre/creds/kube-configs/<cluster>
      field: token

    internal: false
    ```

1. Add the `openshift-config` namespace in app-interface

    ```yaml
    # /data/services/app-sre/namespaces/<cluster>-openshift-config.yml
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

1. Create permissions to grant cluster access to others

    ```yaml
    # /data/openshift/<cluster>/permissions/auth.yml
    ---
    $schema: /access/permission-1.yml

    labels: {}

    name: <cluster>-auth
    description: Access to <cluster> cluster

    service: github-org-team
    org: app-sre
    team: <cluster>-cluster
    ```

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
