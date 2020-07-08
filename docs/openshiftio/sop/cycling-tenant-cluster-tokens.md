# SOP : Cycling OSIO tenant cluster tokens

## Alert: 
> Defined [alerts](https://gitlab.cee.redhat.com/service/app-interface/blob/master/resources/observability/prometheusrules/blackbox-exporter.prometheusrules.yaml) and [checks](https://gitlab.cee.redhat.com/service/app-interface/blob/master/resources/observability/prometheus/v4/prometheus-app-sre-additional-scrapeconfig.secret.yaml)

First need to check if probes failing because of tokens or because of other reasons for API unaviability

## Severity: High

## Impact: 
OSIO tenant services cannot talk the the starter cluster control plane, provisioning and updates to the OSIO tenant space on that cluster are blocked. The services that are already running have no impact. 

## Summary: 
- The token used by the OSIO tenant-services to connect to the starter clusters are user-tokens, and not ServiceAccount tokens. 
- User-tokens have an expiry. Once the token has expired, the OSIO tenant service cannot talk to the starter clusters, blocking any new provisioning/updates into the OSIO tenant spaces.

## Pre-flight checks:
- At any point, you must not log out using the token, as it will invalidate the token
- Verify that the token has expired before cycling. The current token can be 
- If you log in with a fresh user token, you may invalidate old tokens
- Note that you should Never log out using this token, since it will invalidate the token
- Only log in to the clusters directly with the devtools-sre@redhat.com credentials. Do not use the creds to log in into RHD itself

## Access required:
- [Vault (app-sre, app-interface engines)](https://vault.devshift.net)
- OSIO OSDs:
    - Staging: http://console.dsaas-stg.openshift.com/
    - Production: http://console.dsaas.openshift.com/
- [App-interface repository](https://gitlab.cee.redhat.com/service/app-interface)


## Relevant secrets:

OSO account creds to get into the Starter cluster console: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/devtools-sre-rhd-account

On dsaas/dsaas-stg OSD clusters:
- Namespace: dsaas-{preview/production}
- Secret: `f8cluster-config-files`
- Key: `oso.clusters`
- Value: `service-account-token` for the cluster that you want to replace it for

Symmetric key for token encryption/decryption: 

On dsaas/dsaas-stg OSD clusters:
- Namespace: dsaas-{preview/production}
- Secret: `f8tenant`
- Key: `auth.token.key`

## Steps: 

### Validating that the token has actually expired

1. Log in to OSD staging/preview depending on what cluster token has expired: 
- east-2a has both staging and preview environments
- All other starter clusters are production only, so look at dsaas OSD.

2. Find `auth.token.key` and `service-account-token` as described in the Relevant secrets section above.
 
        # auth.token.key
        oc -n dsaas-production get secret f8tenant -ojson | jq -r '.data["auth.token.key"]' | base64 -d
        
        # oso.clusters
        oc -n dsaas-production get secret f8cluster-config-files -ojson | jq -r '.data["oso.clusters"]' | base64 -d

3. Decrypt the `service-account-token` to get the actual user token, using the command: 

        echo -n <encrypted string> | base64 -d | gpg -d

4. Try list namespaces (or anything else) using the token: 

        oc --server=api.starter-us-east-xx.openshift.com --token=<token> get namespaces

5. Once you have confirmed that login fails, proceed further. 

### Generating a new token and updating the Secret

1. Log in to relevant cluster with devtool-sre@redhat.com user. The credentials are in Vault at: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/devtools-sre-rhd-account

2. Once logged in, execute the following to retrieve the user token: 

        oc whoami -t

3. Encrypt token with the `auth.token.key` symmetric key retrieved earlier, using the following command: 

> Note: The default pin entry program doesn’t allow pasting into it, so the workarounds are either: 
>
> a. Specify the symmetric encryption password via a flag to the gpg command (use `--passphrase <passphrase>` and single quotes for escaping special characters (or escape appropriately)
>
> b. Change pinentry-program in ~/.gnupg/gpg-agent.conf to /usr/bin/pinentry-qt 


	    echo -n <token> | gpg --symmetric --cipher-algo AES256 | base64

In the end, you get a token that is encrypted and base64 encoded. 

4. Validate the steps in reverse by decoding the encrypted `service-account-token`. You should arrive at the original token.

        echo -n <encrypted string> | base64 -d | gpg -d

5. Update the token in Vault, in the corresponding secret. For paths, [consult](#relevant-secrets)

6. Send a merge request to app-interface to bump the version of the secret 

7. Merge app-interface PR.
 
8. Rollout the `f8tenant` and `auth` deployments in the relevant namespace/cluster

9. Update the token in Vault for blackbox-exporter checks, this should clear alert
    - Put token in [Vault](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/blackbox-exporter/osio-devtools-bot)
    - Check if secret updated for blackbox-exporter
    - Do rolout for blackbox-eporter to pick-up changes
