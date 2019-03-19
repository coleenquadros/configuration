# SOP : Cycling OSIO tenant cluster tokens

## Alert: 
> Zabbix: starter-us-east-xx.openshift.com    openshift.token.valid[devtools-sre] - Token invalid or expired

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

1. Get the current token used in Zabbix  
    - `ssh n3.c1.rdu2c.fabric8.io`
    - `cd /usr/lib/zabbix/externalscripts`
    - Each cluster has a `starter-us-east-xx.cfg` file with the token, find `openshift_devtools_sre_token` corresponding to the cluster you're troubleshooting

2. Log in to OSD staging/preview depending on what cluster token has expired: 
- east-2a has both staging and preview environments
- All other starter clusters are production only, so look at dsaas OSD.

3. Find `auth.token.key` and `service-account-token` as described in the Relevant secrets section above.

4. Decrypt the `service-account-token` to get the actual user token, using the command: 

    `echo -n <encrypted string> | base64 -d | gpg -d`

5. Check if you obtained from Zabbix matches the token obtained in the last step

6. If token matches the one in Zabbix, try to login using the token: 

`oc login --token=<token> api.starter-us-east-xx.openshift.com`

7. Once you have confirmed that login fails, proceed further. 

### Generating a new token and updating the Secret

1. Log in to relevant cluster with devtool-sre@redhat.com user. The credentials are in Vault at: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/devtools-sre-rhd-account

2.  Once logged in, execute: 

    `oc whoami -t`

    This will get you the token

3. Encrypt token with the `auth.token.key` symmetric key, using the following command: 

> Note: The default pin entry program doesn’t allow pasting into it, so the workarounds are either: 
>
> a. Specify the symmetric encryption password via a flag to the gpg command (use `--passphrase <passphrase>` and single quotes for escaping special characters (or escape appropriately)
>
> b. Change pinentry-program in ~/.gnupg/gpg-agent.conf to /usr/bin/pinentry-qt 


	`echo -n <token> | gpg --symmetric --cipher-algo AES256 | base64`

In the end, you get a token that is encrypted and base64 encoded. 


4. Validate the steps in reverse: 
    - Decode the string obtained in the last step
    - Decrypt it 
    - See if you arrive at the token
    
    You can use the following command for decryption: 

    `echo -n <encrypted string> | base64 -d | gpg -d`

5. Update the token in Vault, in the corresponding secret

6. Send a merge request to app-interface to bump the version of the secret

7. Merge app-interface PR.

8. Update the token in Zabbix, so that the token expiry checks still work.
    - `ssh n3.c1.rdu2c.fabric8.io`
    - `cd /usr/lib/zabbix/externalscripts`
    - Each cluster has a `starter-us-east-xx.cfg` file with the token, you need to update the value for `openshift_devtools_sre_token` corresponding to the cluster you're updating the token for