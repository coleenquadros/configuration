# Design doc: <feature>

> :warning: DRAFT: working document. People are welcomed / encouraged to comment and propose changes

## Author/date
`Patrick Martin` / `October 2021`

## Tracking JIRA
[APPSRE-3929](https://issues.redhat.com/browse/APPSRE-3929)

## Problem Statement
We currently use GitHub as an identity provider for a number of our services. See [this document](https://docs.google.com/document/d/1kOtBius6vrW55xTx1mPFv8uYYW0d47zTdVgMnnqeXyY) for a description of this use.

This creates some security concerns in some cases, especially for Jenkins and Vault which may handle sensitive data. We have been tasked to switch to an other provider for Vault and Jenkins.

## Goals
A new provider must be put in place, fulfilling our needs in terms of usage and in terms of security, for Vault and Jenkins. It would be best to use a single provider for all or use cases in order to homogenize the setup and usage.

### Vault
- authentication
  - The list of supported authentication provider is available on [Vault's site](https://www.vaultproject.io/docs/auth)
  - we can keep the current vault setup for robotic access, using an [AppRole](https://www.vaultproject.io/docs/auth/approle) auth method.
- authorization
  - We need to grant fine-grained permissions in vault (aka policies), based on user groups. Note that not all providers allow that.
  - Groups must be managed in app-interface (as today for GitHub), with a read/write robotic access.
- access
  - Vault does not have access to the internal network of Red Hat. We need a solution that can be reached on the network
- bot
  - Our current bot access to Vault is based on the [AppRole auth](https://www.vaultproject.io/docs/auth/approle). This does not need to move to the new authentication solution.

### Jenkins
- authentication
  - The list of supported authentication provider is available on [Jenkins' configuration page](https://ci.int.devshift.net/configureSecurity/). Other plugins are available as described in [the documentation](https://www.jenkins.io/doc/book/security/managing-security/)
- authorization
  - We can keep the current kind of setup (Matrix-based security) where Jenkins is manually configured to grand permissions to a reduced set of groups (basically `read-only`, `job start/cancel` and `admin`). So the new provider needs to support groups
  - Groups must be managed in app-interface (as today for GitHub), with a read/write robotic access.
- access
  - Jenkins ci-ext does not have access to the internal network of Red Hat. We need a solution that can be reached from the outside.
- bot
  - we currently have a bot taking actions on Jenkins. This could be replaced by a local token bot and does not need to be part of the new authentication solution.

### Jenkins Configuration

Sources of information:
* https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/jenkins_saml_enablement_notes
* https://docs.engineering.redhat.com/pages/viewpage.action?spaceKey=RHELPLAN&title=Jenkins+Maintenance#JenkinsMaintenance-Step4.JenkinsconfigurationtouseSAML

Install the SAML v2 plugin on Jenkins

Then in the `Configure Global Security` section of the Jenkins configuration:
* Set `Security Realm` to `SAML v2.0`
* Set `IdP metadata URL` to
  * stage:  https://auth.stage.redhat.com/auth/realms/EmployeeIDP/protocol/saml/descriptor
  * prod: 
* `Display Name Attribute`
  * `urn:oid:2.5.4.3`
* `Group Attribute`
  * `Role`
* `Maximum Authentication Lifetime`
  * `43200`
* `Username Attribute`
  * `rhatUUID` or `uid` ? 
* `Email Attribute`
  * `urn:oid:1.2.840.113549.1.9.1`

Test

## Non-objectives
- We do not seek at replacing our current setup of Jenkins or Vault. Bringing this topic up because it was mentioned in some discussion.

## Proposal
*TODO*

## Alternatives considered
> :warning: *Note*: this is a working document. Using this section as a way to show current status and progress in the investigation of alternatives

Current options being analyzed and one to be selected:
- Internal SSO (auth.redhat.com)
  - Currently backed by LDAP (so all redhat users exist in there) and planned to move to IPA
  - Offers OIDC (OpenID Connect) and SAML standards
  - MFA in place
  - group management (in an automated way):
    - It is *not* wished to manage groups as it is done in [sre-posix-management](https://gitlab.cee.redhat.com/service/sre-posix-management):
      - could cause name conflicts
      - LDAP planned to be replaced by IPA (which does not support hierarchical group management with something like LDAP OU)
    - The options could be (to be checked):
      - Use Rover group management if an API exist. Contact point: Nicholas Forrer, and Philip Meilleur
        - Quote from Nicholas on 27OCT: "we do have an api that allows that, although i'm not sure if we've opened that up for other teams to hit"
        - 28OCT Contacting Philip Meilleur on that topic
      - Dustin Minnich (IAM) also reported that an API managed by his group directly would be soon available, and used by Rover group management. So we could end up using that as well:
        > I talked to Matthew Carpenter on my team about the group API he is writing.  One of the goals of the API is to
        > "Allow serviceaccounts to be the sole thing that can create/modify groups with specific prefixes".
        > 
        > So you'd get say an Foo-SRE service account and only it could create/modify foosre-group1  and foosre-group2, etc.  
        > 
        > This code is in the API now but we can't allow it to be used at this point in time.
        > From my understanding, this is due to the fact that Rover Groups is self-service and writes directly to LDAP right now.
        > Meaning somebody could go into it and create foosre-group3 that wasn't the service account.
        > We have tasks open with their team to do some testing and to move Rover off of writing directly to LDAP and to using the API
        > instead that would provide the needed protection.
  - some docs & links:
    - [configuration of the internal SSO OIDC in Hashicorp Vault](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/vault_oidc_auth_method)
    - Example of [Jenkins configuration using SAML](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/jenkins_saml_enablement_notes)
    - Vault official doc on OIDC: https://www.vaultproject.io/docs/auth/jwt
    - Jenkins OIDC: https://plugins.jenkins.io/oic-auth/
  - To start working on a POC with the IAM team, a ServiceNow form needs to be filled: https://redhat.service-now.com/help?id=sc_cat_item&sys_id=7ab45993131c9380196f7e276144b054
- Self-hosted Keycloak
  - authentication backed with Internal SSO ? self-hosted user DB (needs high security, ... would imply new user/password for everyone)
  - group management in Keycloak itself ? Relying on SSO backend groups would make Keycloak pretty useless.
  - if we delegate authentication and group management to SSO, is there any added value using Keycloak ?

Discarded alternatives:
- Internal LDAP
  - example of automated group management: https://gitlab.cee.redhat.com/service/sre-posix-management. However, the IAM group would prefer to not have groups managed directly in LDAP: risk of name conflicts + upcoming migration to IPA
  - this is not reachable from outside, so not usable for some of our use cases (external vault, external Jenkins)
- External/Customer SSO (sso.redhat.com)
  - Should be used for services that are also accessed by Red Hat customers, which is not our case: our users are *only* Red Hat employees.

## Milestones
*TODO*
