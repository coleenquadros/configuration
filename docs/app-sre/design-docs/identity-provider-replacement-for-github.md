# Design doc: <feature>

## Author/date
`Patrick Martin` / `October 2021`

## Tracking JIRA
[APPSRE-3929](https://issues.redhat.com/browse/APPSRE-3929)

## Problem Statement
We currently use GitHub as an identity provider for a number of our services. See [this document](https://docs.google.com/document/d/1kOtBius6vrW55xTx1mPFv8uYYW0d47zTdVgMnnqeXyY) for a description of this use.

This creates some security concerns in some cases, especially for Jenkins and Vault which may handle sensitive data. We have been tasked to switch to an other provider for Vault and Jenkins.

## Goals
A new provider must be put in place, fulfilling our needs in terms of usage and in terms of security, for Vault and Jenkins.

### Vault
- authentication
  - The list of supported authentication provider is available on [Vault's site](https://www.vaultproject.io/docs/auth)
- authorization
  - We need to grant fine-grained permissions in vault (aka policies), based on user groups. Note that not all providers allow that.
  - Groups must be managed in app-interface (as today for GitHub)
- access
  - Vault does not have access to the internal network of Red Hat. We need a solution that can be reached on the network

### Jenkins
- authentication
  - The list of supported authentication provider is available on [Jenkins' configuration page](https://ci.int.devshift.net/configureSecurity/). Other pluging are available as described in [the documentation](https://www.jenkins.io/doc/book/security/managing-security/)
- authorization
  - We can keep the current kind of setup (Matrix-based security) where Jenkins is manually configured to grand permissions to a reduced set of groups (basically `read-only`, `job start/cancel` and `admin`). So the new provider needs to support groups
  - Groups must be managed in app-interface (as today for GitHub)
- access
  - Jenkins ci-ext does not have access to the internal network of Red Hat. We need a solution that can be reached on the network

## Non-objectives
* Describe technically what it is not going to be delivered
* This is especially important to focus the conversations around the design doc

*TODO* : I don't see anything to put in there for now

## Proposal
* Ideally, it should be detailed enough that somebody who already understands the problem could go out and code the project without having to make any significant decisions.
* The design doc should only include one proposal. If alternatives considered are worth mentioning, do it in the appropriate section.

*TODO*

Current options to be analyzed and one to be selected:
- internal LDAP
  - exampel of automated group management: https://gitlab.cee.redhat.com/service/sre-posix-management.
  - but is probably not reachable from outside.
- SSO
  - need to see how group management can be done in an automated way.

## Alternatives considered
* Add this section only if there are alternatives and if they are relevant
  * Highlight why they were discarded in favor of the proposal

*TODO*

## Milestones
* List all the different steps that will take to get the proposal running in production
* This is not meant to replace any project plan, JIRA or whatever tool we use for planning, so don't commit to any particular date. These are technical milestones.

*TODO*
