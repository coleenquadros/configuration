# Design doc: GitHub identity provider replacement on Jenkins

- [Design doc: GitHub identity provider replacement on Jenkins](#design-doc-github-identity-provider-replacement-on-jenkins)
  - [Author/date](#authordate)
  - [Tracking JIRA](#tracking-jira)
  - [Problem Statement](#problem-statement)
  - [Goals](#goals)
  - [Non-objectives](#non-objectives)
  - [Proposal](#proposal)
  - [Alternatives considered](#alternatives-considered)
  - [Milestones](#milestones)
    - [Rollback](#rollback)
  - [Additional information](#additional-information)
    - [Local users and token handling](#local-users-and-token-handling)
    - [Robotic accounts being used prior to the migration:](#robotic-accounts-being-used-prior-to-the-migration)


## Author/date
`Patrick Martin` / `January 2022`


## Tracking JIRA
[APPSRE-4033](https://issues.redhat.com/browse/APPSRE-4033)


## Problem Statement
As described in [this design  document](identity-provider-replacement-for-github.md) we need to get rid of GitHub as an identity provider for Jenkins.

For Jenkins specifically, this is a security requirement. The Red Hat internal/employee SSO `auth.redhat.com` will be used.


## Goals
The goal is to setup our Jenkins instances `ci.int` and `ci.ext` to authenticate users against auth.redhat.com.

We must have the possibility to grant different level of permissions to users, just as today. Permissions, Groups, Users must be managed in app-interface.

Current robotic access must keep on working (eg. JJB, web hooks).


## Non-objectives
- We do not seek at replacing our current instances of Jenkins. Bringing this topic up because it was mentioned in some discussion.


## Proposal
In a nutshell, we will use the Jenkins SAML v2 plugin as described in the [IAM doc](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/jenkins_saml_enablement_notes) and [here](https://docs.engineering.redhat.com/pages/viewpage.action?spaceKey=RHELPLAN&title=Jenkins+Maintenance#JenkinsMaintenance-Step4.JenkinsconfigurationtouseSAML)

- Request IAM setup for our Jenkins via a [SSO Enablement Request](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=7ab45993131c9380196f7e276144b054) in ServiceNow
- Install the [SAML v2](https://plugins.jenkins.io/saml/) plugin on Jenkins
- In the `Configure Global Security` section of the Jenkins configuration:
  - `Security Realm`
    - `SAML v2.0`
  - `IdP metadata URL`
    - stage:  https://auth.stage.redhat.com/auth/realms/EmployeeIDP/protocol/saml/descriptor
    - prod: https://auth.redhat.com/auth/realms/EmployeeIDP/protocol/saml/descriptor
  - `Display Name Attribute`
    - `urn:oid:2.5.4.3`
  - `Group Attribute`
    - `Role`
  - `Maximum Authentication Lifetime`
    - `43200`
  - `Username Attribute`
    - `uid` (we could also use `rhatUUID` which will never change, but it would be less convenient to relate to in `app-interface` configuration)
  - `Email Attribute`
    - `urn:oid:1.2.840.113549.1.9.1`
- Install the [Role based strategy](https://plugins.jenkins.io/role-strategy/) plugin for authorization

User assignments to roles is already taken care of by app-interface in the [jenkins-roles](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/jenkins_roles.py) integration, which will use the Jenkins role-based strategy. That works out of the box when creating a `permission-1` config with `service: jenkins-role` and the correct instance. As usual link from `user-1` to `permission-1` is done via `role-1`.

> :warning: the automation bot used to set those assignments must be referenced in app-interface and be linked to an admin permission or it will remove itself and we might all get locked out.

Using the Jenkins [role-based strategy](https://plugins.jenkins.io/role-strategy/), we will need to assign permissions to roles in the `Manage Roles` page. This could be done manually for now, as it is the case today with very few roles involved. The roles we will need to manage are:
- `admin`: full control on the Jenkins configuration. Will be granted to AppSRE team members and the Jenkins bot
  - all permissions checked
- `read-only`: read access to Jenkins:
  - Overall / Read
  - Job / Read
  - View / Read
- `job-control`: same as `read-only` + ability to start & cancel jobs:
  - Overall / Read
  - Job / Read
  - View / Read
  - Job / Build
  - Job / Cancel

We will reuse the two existing robotic account app-sre-bot. On ci.int, this is a local Jenkins account, with a token, so nothing needs to be changed. On ci.ext, this account is based on github authentication. We will need to set a local token on this account and update [Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-ext/jjb-ini) accordingly


## Alternatives considered
There are also some Jenkins OIDC plugins. We chose SAML simply because that's what is currently described in several docs at Red Hat and working fine for our purpose.

Permission management could be based on groups from Red Hat SSO. However, the SSO group management API is an ongoing project on the IAM team side. We will keep in touch with them to see if / how we can integrate this in the future.


## Milestones
Pre-requisites actions:
- Done as of 2022-01-10:
  - Test on our POC instance `sso-poc.int.devshift.net`
    - authentication
    - role-based strategy authorization via app-interface
    - robotic access
  - Request ci.int and ci.ext configuration on IAM side, similar to the POC environment.
    - ci.int: [RITM1040558](https://redhat.service-now.com/help?id=rh_ticket&table=sc_req_item&sys_id=ffb8dcac1b888510c57c3224cc4bcb4f)
    - ci.ext: [RITM1040559](https://redhat.service-now.com/help?id=rh_ticket&table=sc_req_item&sys_id=afc8d4ec1b888510c57c3224cc4bcbe7)
  - Install Jenkins plugins for SAML v2 and Role-Based authorization strategy
  - Ensure necessary robotic accounts and tokens are accessible (local to Jenkinses) and referenced in Vault ([APPSRE-4224](https://issues.redhat.com/browse/APPSRE-4224))
    - Backup users
    - Use the [script](#local-users-and-token-handling) to generate a token
    - Update [Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-ext/jjb-ini)
- TODO as of 2022-01-10:
  - Prepare a MR for each Jenkins ci.int and ci.ext to grant permissions to `org_username` and the bot.
    - ci.ext: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/31129/diffs
    - ci.int: TODO

Each Jenkins migration will follow those steps:
- Disable the `jenkins-roles` integration
- Backup/Tar Jenkins configuration and `users` folders from `/var/lib/jenkins`
- Configure SAMLv2 and Role-based strategy in the UI
- Ensure the main bot account `app-sre-bot`
  - has a token
  - is correctly updated in Vault and referenced in app-interface
  - is granted the admin role
- Merge the MR to update all permissions
- Re-enable the `jenkins-roles` integration
  - This should assign all app-interface users to a role

Verify everything runs fine:
- jenkins integrations
- builds

Post-migration cleanup (To be checked if that can really be done after, or if github users need to be cleaned up prior to switching to SAML SSO)
- Backup the Jenkins users
- Remove all GitHub users from the users folder
  - https://gitlab.cee.redhat.com/-/snippets/4635


### Rollback
If we face any issue, we can rollback by following those steps:
- `systemctl stop jenkins`
- restore the Jenkins config and users folder from the backup
- `systemctl start jenkins`


## Additional information

### Local users and token handling

*Note to be added in a SOP !*

as an admin, it is possible to create local users and generate tokens for that user. Go at `JENKINS_URL/script` and run the following groovy script (with correct `userName` and `tokenName` values)

```groovy
// shamelessly copied from https://mrdias.com/2020/06/03/creating-jenkins-users-and-tokens-programmatically.html
// Create a User in the Private Realm
import hudson.security.HudsonPrivateSecurityRealm;
HudsonPrivateSecurityRealm securityRealm = new HudsonPrivateSecurityRealm(true, false, null);
securityRealm.createAccount("USERNAME", "PASSWORD")
```

```groovy
// Create a new token for a user
// import hudson.model.*
// import jenkins.model.*
// import jenkins.security.*
// import jenkins.security.apitoken.*

import hudson.model.User
import jenkins.security.ApiTokenProperty

// script parameters
def userName = 'USERNAME'
def tokenName = 'kb-token'

def user = User.get(userName, false)
def apiTokenProperty = user.getProperty(ApiTokenProperty.class)
def result = apiTokenProperty.tokenStore.generateNewToken(tokenName)
user.save()

return result.plainValue
```

### Robotic accounts being used prior to the migration:
Those Jenkins automation accounts were found. We're listing them and defining what to do with them here.

- `app-sre-bot`
  - Used for most automations (app-sre integrations, JJB)
  - defined in [GitHub](https://github.com/orgs/app-sre/people/app-sre-bot). ci-int actually uses a local user and not the github one
  - ci-ext needs a new local token for that user ([APPSRE-4224](https://issues.redhat.com/browse/APPSRE-4224))
- `iqe-bot`
  - Found in ci-ext with a relatively high `useCounter` in `/var/lib/jenkins/users/iqebot_5597982201466808634/apiTokenStats.xml`
  - ci-ext link: https://ci.ext.devshift.net/user/iqe-bot/
  - Referenced in app-interface in `/data/teams/insights/bots/iqe-sitreps-bot.yml`
  - :warning: No idea where the token is referenced in Vault nor where it is used. Andreu is awaiting confirmation that this bot is actually obsolete and can be removed.

Those accounts have also been found but don't seem to be used. To be confirmed !
- `app-sre-ci-trigger-jobs-bot`
  - Referenced in `app-interface` here: https://gitlab.cee.redhat.com/search?search=app_sre_ci_trigger_jobs_bot&group_id=5301&project_id=13582&scope=&search_code=true&snippets=false&repository_ref=master&nav_source=navbar
  - Referenced in [osde2e](/resources/jenkins/osde2e/job-templates.yaml) (but does not seem used in [the GitHub repo](https://github.com/openshift/osde2e/search?q=JENKINS_TOKEN&type=code)) and [insights](/resources/jenkins/insights/ci-int/job-templates.yaml) (but does not seem to be used in the [Gitlab repo](https://gitlab.cee.redhat.com/insights-platform/cicd-common/-/tree/master)) jobs definitions
  - Defined in [GitHub](https://github.com/orgs/app-sre/people/app-sre-ci-trigger-jobs-bot)
  - Referenced in [Vault](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-ci-trigger-jobs-bot)
    - Bot GitHub account seems 2FA-linked to Jaime's mobile phone. But Jaime does not remember this bot setup.
  - To be replaced by a Jenkins local bot + token
    - Then update Vault data in https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-sre-ci-trigger-jobs-bot
- `&ci_jenkins_token` reference
  - Referenced in `app-interface` in `resources/jenkins/managed-services/secrets.yaml`
  - Related to cpaas, **not** to ci-int / ci-ext.
