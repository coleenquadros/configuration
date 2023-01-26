<font size=24> Glitchtip </font>
---

[toc]

# Onboarding new Glitchtip Instance

## Create admin and qontract-reconcile accounts

1. Enter new user credentials to [vault](https://vault.devshift.net/ui/vault/secrets/app-interface/list/app-sre/glitchtip/)
   1. Admin account is to log in to the Glitchtip django admin interface. Enter `email` and `password`
   1. qontract-reconcile for the glitchtip integration. Enter `email` and `token`
1. These credentials are entered into the glitchtip RDS during the startup of the glitchtip app.

# Notes

The qontract-reconcile glitchtip integration manages organizations where the automation account (e.g., `sd-app-sre+glitchtip@redhat.com`) has the owner role! Glitchtip doesn't have the global admin concept; an organization's role handles the permissions. The integration can see other organizations and, therefore, can't control those.

# FAQ

## I'm logged in, but I can't see any organizations or projects. What should I do?

The user has to use the invitation link to join an organization. In Glitchtip itself, you don't see any open invitations.

## Create new account or log in with existing account?

![](images/glitchtip_invite.png)

**Log in with existing account**. Glitchtip is using Red Hat SSO as an authentication provider.
## I've clicked the invitation link, but I can't see any organizations or projects. What should I do?

Click it again and be sure that you're already logged in. If you're not logged in, you'll be redirected to the login page, and the original invitation link will be lost.

## I can't find the invitation email, or the link has expired. What should I do?

Ask a Glitchtip admin to resend the invitation by deleting your Glitchtip organization user (https://glitchtip.devshift.net/admin/organizations_ext/organizationuser/). The integration will recreate the organization user and resend the invitation.

## How can I login to the Glitchtip admin interface? (AppSRE only)

The Glitchtip admin interface is available at https://glitchtip.devshift.net/admin/. The credentials are stored in [vault](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/glitchtip-production/admin).
