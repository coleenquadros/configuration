# Design doc: Cloudflare user management

## Author/date

steahan / January 2023

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-6560

## Problem Statement

The Quay team has shifted significant amounts of traffic to Cloudflare following the
completion of [SDE-1958](https://issues.redhat.com/browse/SDE-1958). As they increase
their usage of this CDN, we'll need to ensure that AppSRE and Quay team members can
access the console with the proper permissions to debug issues. The AppSRE team is
currently sharing a service account and only one Quay team member has been provided
read-only access manually. This will not scale long-term and doesn't follow standard
InfoSec best practices.

Additionally, with [SDE-294](https://issues.redhat.com/browse/SDE-294) the SREP team
will be moving DNS workloads from Dyn to Cloudflare. Their team may also require console
access for debugging issues.

## Goals

* Support granting/revoking Cloudflare roles to/from an app-interface user's Cloudflare
  account

## Non-goals

* Creating Cloudflare accounts
    * The model for accounts is quite different than AWS IAM users. Cloudflare users
      have a one-to-many relationship with Cloudflare accounts, so the account doesn't
      actually manage the user like in AWS.
    * We can think of this model as BYO account, like we support with GitHub
* Single sign-on
    * SSO can only be enabled for all Cloudflare users with a redhat.com email address
    * Asking Cloudflare to enable this would essentially change the way 100+ other
      Cloudflare users at Red Hat access their account
    * Cloudflare created a feature request (FR-11275) on our behalf for per-account SSO
      configurations
* Revoking API tokens
    * Tokens are managed by the Cloudflare user (rather than the Cloudflare account), so
      it's impossible for us to revoke tokens for a user account
    * Again, think of this more like a GitHub account than AWS IAM users
* Service accounts
    * Cloudflare doesn't support tokens that aren't associated with a human user at this
      time. It seems this could happen in Q2. In either case, these service accounts
      will likely still be outside the scope of the integration outlined in this
      document.
* MFA enforcement
    * Cloudflare enforces MFA at the account rather than the user, so MFA will not be
      managed by this integration

## Proposal

### New integration: terraform-cloudflare-users

A new integration will be added to serve a purpose similar to `terraform-users` for AWS
IAM accounts. This integration will use the Cloudflare terraform
provider [cloudflare_account_member resource](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/account_member)
to assign a role to a Cloudflare user.

The required steps to gain access to an account would be:

1. The user creates a Cloudflare account if they don't already have one
2. The user adds their Cloudflare user email to their `/access/user-1.yml` file
3. The appropriate `/access/role-1.yml` is referenced from the `/access/user-1.yml` file

#### User off-boarding

The general user offboarding documentation can be
found [here](https://gitlab.cee.redhat.com/service/app-interface#user-off-boarding-revalidation-loop)
. It will be important to test that the new integration works properly when a user file
is removed (Cloudflare access should be revoked).

### Schema changes

The examples below are a very rough idea of what the schema changes might look like.

**User file changes**

The existing user schema will get a new field to track the cloudflare username (email
address). The email used may or may not match the `org_username` due to user aliases
and/or email sub-addressing (email+something@redhat.com).

To avoid the potential for granting access to accounts outside of Red Hat, we will add
an allow-list to `app-interface-settings-1.yml` so that only emails ending in redhat.com
can be used.

```yaml
$schema: /access/user-1.yml

name: Some User
org_username: suser
...
cloudflare_user: suser@redhat.com
```

**Cloudflare Account Access**

A new schema will be added that can be associated with a `/access/role-1.yml` to provide
access to some number of roles within a single account.

The [cloudflare_account_roles data source](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/account_roles)
will likely need to be used to map the user-friendly role name (ex. Administrator) to
a role identifier that will be used by
the [cloudflare_account_member resource](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/account_member)
.

```yaml
$schema: /cloudflare/account-role-1.yml

account:
  $ref: /cloudflare/app-sre/account.yml

name: app-sre-cloudflare-read-only
description: Read-only access to the app-sre Cloudflare account

roles:
  - 'Administrator Read Only'
```

A minor update will need to be made to `/access/role-1.yml` to reference the schema
change above.

```yaml
---
$schema: /access/role-1.yml

name: app-sre

cloudflare_access:
  - $ref: /dependencies/cloudflare/permissions/app-sre-read-only.yml
```

### API Access and Token Management

API tokens are owned by the Cloudflare user that created them. The admin of a Cloudflare
account doesn't have the ability to revoke tokens and/or manage them in any way.
Additionally, Cloudflare doesn't automatically scan common services like GitHub for
leaked tokens. Together, this might cause some InfoSec concerns.

For the purposes of the initial release of Cloudflare user management, it seems that
most users would only need read-only access to the console for debugging issues.
Cloudflare recently released a new feature that would allow us
to [disable API access with tokens](https://blog.cloudflare.com/improved-api-access-control/)
by default. The Terraform credentials used by qontract-reconcile could be the exception
to this rule. Additionally, users would be able to request access to the Cloudflare API
as an exception.

Initially, any requests for API access can be handled manually. This is a new Cloudflare
feature and isn't yet available in the Cloudflare Terraform provider. Once the provider
is updated, we can extend the terraform-cloudflare-users integration to support
enabling API access on a per-user basis. This would at least make it easy to audit
which users have the ability to access the Cloudflare API with tokens.

## Milestones

The scope of this integration will be fairly limited. The major milestone will be the
delivery of the integration in a completed state. There aren't any known enhancements
that will be required after the initial delivery.
