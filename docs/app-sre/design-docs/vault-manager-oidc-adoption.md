# Design doc: Commercial Vault OIDC Adoption (GitHub dependency removal)

# Author/Date
Drew Welch / 2022-08-02

# Tracking JIRA
https://issues.redhat.com/browse/APPSRE-6072


# Problem Statement
[Vault](https://vault.devshift.net) is reliant on the coordination of two integration suites and a third-party identity provider for authentication and authorization:  
* Qontract Reconcile ([GitHub Org integration](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/github_org.py) in particular)
* [Vault Manager](https://github.com/app-sre/vault-manager)
* [AppSRE GitHub Org](https://github.com/orgs/app-sre/teams)

The usage of GitHub as an external data store for team and role relationships is redundant. App Interface stores all team -> role -> Vault permission relationships and is our primary data store. Duplicating these relationships to an external data store increases opportunity for misconfiguration, makes interactions with Vault dependent on a third party, and serves to complicate the relationships expressed in App Interface. Removal of the GitHub auth method will reduce our reliance on 3rd party solutions and simplify mapping of App Interface definitions to Vault permissions.


# Goals
**Overarching goal is replacement of [GitHub Auth Method](https://www.vaultproject.io/docs/auth/github) with [OIDC Auth Method](https://learn.hashicorp.com/tutorials/vault/oidc-auth?in=vault/auth-methods)**  

In order for this to be achieved, the following must be accomplished:
* Enable OIDC auth alongside GitHub auth
    * [Configure an oidc client for Vault within RH SSO](https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.3/html/server_administration_guide/clients)
    * Define [oidc permissions](https://github.com/app-sre/qontract-schemas/blob/main/schemas/access/oidc-permission-1.yml) to mirror existing GitHub permissions
    * Utilize [Vault Entities and Groups](https://learn.hashicorp.com/tutorials/vault/identity) to manage policy assignments for users (detailed below)
* Gather confidence that all parties currently utilizing GitHub auth can authenticate and obtain expected permissions with OIDC auth
    * Could be as innocuous as announcements within #sd-app-sre for users to attempt OIDC login and report back with result. Or could be more intense in the form of a "smoke test", during which time GitHub auth is entirely disabled.
* Removal of [github-auth config](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/auth-backends/github-auth.yml)


# Non-objectives
* Refactor policy defintions for tenants
    * Intent is to copy policies without evaluating "correctness" of permissions currently being granted


# Proposal
A stipulation for FedRamp compliance necessitated support of a new authentication method (OIDC) for Vault. Utilization of the OIDC method, coupled with leveraging Vault's Identity resources, offers numerous benefits over the existing GitHub auth method. The resources under <b>Supplemental Material</b> provide an in-depth comparison of the two approaches.  

## Red Hat SSO Vault client
By [configuring an oidc client](https://access.redhat.com/documentation/en-us/red_hat_single_sign-on/7.3/html/server_administration_guide/clients) for Vault within RH SSO, an [oidc auth config](https://github.com/app-sre/qontract-schemas/blob/main/schemas/vault-config/auth-1.yml#L55) can be defined that Vault Manager will reference in order to configure OIDC authentication.  
  
Considerations during client configuration:
* Vault Manager is not utilizing group/role metadata provided by RH SSO to map permissions within Vault ([example](https://learn.hashicorp.com/tutorials/vault/oidc-auth#create-an-auth0-group)) 
    * Users within RH SSO do not require specific role association to gain permission to Vault


## OIDC Permission Definitions
Vault Manager utilizes the App Interface relationships between user, role, and permission definitions to construct relationships within Vault via Identity resources. This relationship mapping is covered with the presentation but in short:
* `org_username` within a-i user file -> `entity` within Vault
* `roles` referenced within a-i user file -> `groups` within Vault 
    * note: role file must include reference to an `oidc_permission` file to be included in Vault Manager's `group` reconcile
* `oidc_permission` definitions in a-i reference `vault_policies` for desired permissions  
  
### Example
A new user file that references a valid oidc role is merged. Vault Manager will do the following:
* Create a Vault Entity to represent the user in Vault
* Associate the Entity with the Vault Group(s) corresponding to the roles referenced in the user file
    * If this is the first user to reference the role, a new group is first created to represent the role in Vault
        * Policies are attached to the group corresponding to the `oidc_permissions` referenced in the a-i role file
* An OIDC Entity Alias is created and associated with the new Entity
    * This defines that the Entity has an OIDC auth method associated with it
    * An Entity can be associated with numerous different auth method aliases


## Testing
With the [inclusion of vault.stage.devshift.net within App Interface management](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/44133), initial migration and validation can occur in isolated environment.

Announcements should be made before/after commercial cutover and request users to confirm access.


# Risks/Concerns
* Issues occur when OIDC/GitHub are deployed simultaneously 
    * Because GitHub auth is utilizing its own Entity mapping underneath, potential for Entity mapping issues is possible
    * This should be oncovered during staging validation
* Production cutover fails and users lose access to Vault until rollback is completed
* Permission/role mirroring is not completed properly and users gain/lose access


# Alternatives
Continue with existing GitHub authentication method.


# Supplemental Material
- [Presentation Slides](https://docs.google.com/presentation/d/1_7iB8Mo6aqeSxHCRKdIM2lQ-HmBibxr3aD-K4h6R46I/edit?usp=sharing)
- [Presentation Recording](https://drive.google.com/file/d/1f3gWCW-U8MUaE4avm6FmRuQfRRfuozMT/view)
