# Design doc: Identity provider replacement for GitHub

## Author/date
`Patrick Martin` / `November 2021`

## Tracking JIRA
[APPSRE-3929](https://issues.redhat.com/browse/APPSRE-3929)

## Problem Statement
We currently use GitHub as an identity provider for a number of our services. See [this document](https://docs.google.com/document/d/1kOtBius6vrW55xTx1mPFv8uYYW0d47zTdVgMnnqeXyY) for a description of this use.

This creates some security concerns in some cases, especially where we may handle sensitive data. We have been tasked to switch to an other provider for Jenkins and are thinking of Vault and Openshift as next steps.

## Goals
A new identity provider must be defined, fulfilling our needs in terms of usage and in terms of security:
- it must be owned by Red Hat (since we do not trust external parties)
- it must be usable for authenticating on internal (as in 'VPN') and external (as in Internet-facing) services
- it must offer a standard authentication protocol / API
- using this provider should allow us to manage permissions on our applications. This could be to users or group. Note that some of our apps (can) manage groups internally (eg Jenkins via the role-based strategy, Openshift, ..)

## Non-objectives
- This doc does not aim at actually implementing the new IdP. Only to select the one we'd use.

## Proposal
For any app-sre application/service which we want to unplug from an external identity provider like GitHub, we will use the "Red Hat Internal / Employee SSO".

The "Red Hat Internal / Employee SSO" is auth.redhat.com. It is the SSO service used by Red Hat employees only (no external users) to access Red Hat restricted resources, with MFA.

auth.redhat.com is actually implemented with the product [Red Hat SSO](https://access.redhat.com/products/red-hat-single-sign-on). The upstream community project is [KeyCloak](https://www.keycloak.org/) ([GitHub](https://github.com/keycloak/keycloak)). This implementation uses the Red Hat corporate LDAP (ldap.corp.redhat.com) as a backend. It allows to build an SSO solution with standards like [SAML](https://en.wikipedia.org/wiki/Security_Assertion_Markup_Language) and [OpenID Connect (aka OIDC)](https://openid.net/connect/).

The IAM team is working on an API which should allow to manage groups in auth.redhat.com. See the documentation here: https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/enterprise_iam_user_documentation#jive_content_id_Group_Management.

Discussions are ongoing to see when we'd be able to really use this API. Their current wish is to wait for Rover Groups to implement that API first. This is to avoid group name clash or mistakenly overridden by Rover Groups. Rover Group (Philip Meilleur) stated they wish to finish that migration by the end of 2021. This means we'd be able to use the IAM API beginning of 2022. There are no commitments there. We're also discussing if we can accept that group name clash risk.

New integrations need to be requested via ServiceNow with a [SSO Enablement Request request](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=7ab45993131c9380196f7e276144b054) like [RITM1027367](https://redhat.service-now.com/help?id=rh_ticket&table=sc_req_item&sys_id=b3f807d61be7f850c57c3224cc4bcb49)

Contacts in IAM team:
- Dustin Minnich
- Matthew Carpenter
- Chris Johnson

Links:
- [IAM Wiki](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki)
- [configuration of the internal SSO OIDC in Hashicorp Vault](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/vault_oidc_auth_method)
- Example of [Jenkins configuration using SAML](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/jenkins_saml_enablement_notes)
- [Hashicorp Vault official doc on OIDC](https://www.vaultproject.io/docs/auth/jwt)
- [Stage SSO entrypoint](https://auth.stage.redhat.com/)
- [Prod SSO entrypoint](https://auth.redhat.com/)

## Alternatives considered
- Internal LDAP
  - example of automated group management: https://gitlab.cee.redhat.com/service/sre-posix-management. However, the IAM group would prefer to not have groups managed directly in LDAP: risk of name conflicts + upcoming migration to IPA
  - this is not reachable from outside, so not usable for some of our use cases (external vault, external Jenkins)
- External/Customer SSO (sso.redhat.com)
  - Should be used for services that are also accessed by Red Hat customers, which is not our case: our users are *only* Red Hat employees.
- Self-hosted Keycloak
  - We thought of running our own Keycloak solution, enabling group management on our side and backed by an official Red Hat identity provider for authentication
  - However this would be yet an additional service to maintain, with pretty high constraints, so we wish to not go that path for now.

## Milestones
This doc serves as a decision logs. Milestones will be set for each individual implementation of the Identity Provider (Jenkins, Vault, openshift, ...) in dedicated design docs. This is because each implementation will be different : integration protocol, parameters, group and permission management, ...
