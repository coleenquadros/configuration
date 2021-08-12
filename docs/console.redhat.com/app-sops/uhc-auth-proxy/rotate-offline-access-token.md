# Create/Replace OCM Offline Access Token

## Severity

`Critical`

## Impact

`uhc-auth-proxy` application uses offline access token to get data about OCM clusters. Without valid tokens, requests will fail and OpenShift v4 clusters cannot upload its payload to Insights

## Resolution

1. Login to https://console.redhat.com/ with credentials stored in Vault secret [openshift-offline-token-console-login-creds](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-prod/uhc-auth-proxy-prod/openshift-offline-token-console-login-creds).
2. Navigate to https://console.redhat.com/openshift/token and copy the token.
3. Update [uhc-auth-proxy-secret](https://vault.devshift.net/ui/vault/secrets/insights/show/secrets/insights-prod/uhc-auth-proxy-prod/uhc-auth-proxy-secret) secret in Vault with the new token.
4. Update the Secret version number in [prod-uhc-auth-proxy-prod.yml](../../../../data/services/insights/uhc-auth-proxy/namespaces/uhc-auth-proxy-prod.yml) and raise MR to app-interface.
5. Once the MR is merged, the secret will be updated on the cluster and Deployment will be updated automatically.
