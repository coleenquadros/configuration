# Managing Secrets

Note, if you are facing a AWS Access Key leak, please refer to the [AppSRE SOP - When an AWS Access Key is Exposed](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/security/compromised-aws-access-key.md#when-an-aws-access-key-is-exposed).

## Pre-requisites

* [Gain access to Add or update secrets in the AppSRE Vault](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/getting-access.md) - specifically add the Stonesoup vault role `/teams/stonesoup/roles/stonesoup-vault.yml` to your user account
* [Gain access to Argo CD](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/fleet-manager-argocd.md) to re-start applications after changing secrets


## Adding New Secrets

This process outlines the instructions for adding a new secret for RHTAP

### Steps

1. Log into Vault and make sure you're at the [root URL](https://vault.devshift.net/ui/vault/secrets).

2. Navigate to your secret within the UI:

    1. Click on `stonesoup/production/` to get to secrets for production are stored

    2. Click on `stonesoup/staging/` to get to secrets for staging are stored

    3. Select the relevant component, such as `has`, for where you want to add the secret

3. Click "Create new version +" in the top-right corner.

4. Set "Maximum Number of Versions" to 0, which removes the maximum. Make updates to your secret, and hit "Save".

5. Open a PR in https://github.com/redhat-appstudio/infra-deployments, adding an `ExternalSecret` resource for the secret.

    1. Create a file containing an `ExternalSecret` resource that points to your secret. For example:

       ```
        apiVersion: external-secrets.io/v1beta1
        kind: ExternalSecret
        metadata:
        name: <resource-name>
        annotations:
            argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
            argocd.argoproj.io/sync-wave: "-1"
        spec:
        dataFrom:
            - extract:
                key: <vault-path-to-secret>
        refreshInterval: 1h
        secretStoreRef:
            kind: ClusterSecretStore
            name: appsre-stonesoup-vault
        target:
            creationPolicy: Owner
            deletionPolicy: Delete
            name: <secret-name>
       ```
    
    2. Save the file under the `ExternalSecrets` folder in the component that the secret belongs to, for example [components/image-controller/base/external-secrets/](https://github.com/redhat-appstudio/infra-deployments/tree/main/components/image-controller/base/external-secrets/), 

    3. Add any necessary kustomize patches to configure the `ExternalSecret` per-environment

## Updating Vault Secrets

The following steps outline the process to update or cycle secrets in Vault for RHTAP.

Be aware, the secret will appear in the staging or production environment after a time determined by the `refreshInterval` value set in the secret's `ExternalSecret` resource.
### Steps

1. Log into Vault and make sure you're at the [root URL](https://vault.devshift.net/ui/vault/secrets).

2. Navigate to your secret within the UI:

    1. Click on `stonesoup/production/` to get to secrets for production are stored

    2. Click on `stonesoup/staging/` to get to secrets for staging are stored

    3. Select the relevant component, such as `has`, for the secret you want to update

    4. Select the secret that needs updating

3. Click "Create new version +" in the top-right corner.

4. Wait for the secret to be refreshed on the cluster, determined by the `refreshInterval` value set in the secret's `ExternalSecret` resource.

5. Pods will not usually pick up the new secrets without a re-start. Access [Argo CD](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/fleet-manager-argocd.md) for each affected application, drill down to the affected pod(s) and click on the "Delete" button.  The pods will be re-created automatically.
