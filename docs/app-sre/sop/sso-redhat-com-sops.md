# SOPs for sso.redhat.com

- [SOPs for sso.redhat.com](#sops-for-ssoredhatcom)
  - [Client secret rotation](#client-secret-rotation)
    - [Summary](#summary)
    - [Access required](#access-required)
    - [Steps](#steps)
  - [Personal token rotation](#personal-token-rotation)
    - [Summary](#summary-1)
    - [Access required](#access-required-1)
    - [Steps](#steps-1)

The following are generic SOPs for situations involving sso.redhat.com

## Client secret rotation

### Summary

Many applications we run use IdP Service Account tokens from sso.redhat.com. Those application typically run with OCM and use it to authorize access to resources.

It may be necessary to rotate credentials for many reasons: credentials leaks, employee departure, etc

### Access required

- View the affected service secrets (in vault or in the cluster)
- Edit access to vault to update the secret
- Your GPG keypair

### Steps

**NOTE: Once the IT person generates a new secret, the old one will become invalid. As such, make sure you trigger the service incident/outage process accordingly if needed.**

- Find out what is the Client ID for which you need the secrets rotated.
  - The client ID will be typically part of a secret that is deployed along the application via app-interface
    - Look for secrets ending in `-sso` (note this naming is not enforced and tenants are free to name secrets however they want)
    - Look for secrets in which you have keys named `clientID` or `client.id` (note this naming is not enforced and tenants are free to name secrets however they want)
  - Looking at the app's namespace `type: vault-secret` resources in app-interface may help locating the secret that contains the SSO credentials. The resource will contain a path in vault where the actual client ID and secret values are located.
- Open an incident in [Service-Now](https://redhat.service-now.com/)
  - Create an Incident
    - On behalf of this user: `yourself` (typically)
    - Impact: `1 -  Affects external customers` (most of the time)
    - Urgency: `1 - Possible data loss, security compromise, or major revenue impact` (adjust as needed)
    - Affected application/system: `External SSO (Keycloak) - sso.redhat.com`
    - Short description: `Client secrets leaked, rotation required urgently` (adjust as needed)
    - Description (example)
        ```
        The following client secrets registered under `sso.redhat.com` have been leaked and need to be rotated

        my-client-secret-prod
        my-client-secret-stage
        ...

        I have attached my GPG key to this ticket so you can send me the new secrets in encrypted form
        ```
  - Attach your GPG public key to the ticket
- Escalate the incident in Google Chat room `IT User Community`
    - Create a new thread with a brief description and link to ticket
    - Type the following to ask their bot who the oncall person is
        ```
        @Platypus !oncall it-user
        ```

## Personal token rotation

### Summary

It may be required to invalidate and/or rotate a personal access token as provided by SSO (OCM)

### Access required

- Access to your personal SSO account (the one you use to login to OCM)

### Steps

- Go to https://sso.redhat.com/auth/realms/redhat-external/account/applications
- Section `Offline token` will list your currently active personal tokens
- Click `Revoke Grant` on the token that need to be invalidated
