# Design doc: Dynatrace SSO

## Author/date

steahan / 2023-04-11

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-7440

## Problem Statement

The Dynatrace MVP for Hypershift is currently being worked on for Q2 ([SDE-2837](https://issues.redhat.com/browse/SDE-2837)). One of the requirements of this first milestone is SSO for user authentication.

## Goals

* Enable SSO on Red Hat Dynatrace accounts for authentication

## Non-objectives

* Enable authorization based on existing Red Hat groups (for now, still planned for Q2)
  * This will be covered in a separate doc

## Proposal

### SSO: auth.redhat.com

As per the [SSO docs](https://source.redhat.com/groups/public/ciams/docs/topic_external_sso_enablements):

> If you are only authenticating employees or are only behind the corporate firewall, and do not need to integrate with other services which are already using external SSO, you should be onboarding to internal SSO.

Based on this, it makes sense to authenticate Dynatrace users with **auth.redhat.com**. There is significant prior art here with the replacement of [GitHub IdP](/docs/app-sre/design-docs/identity-provider-replacement-for-github.md) and [Jenkins IDP](/docs/app-sre/design-docs/identity-provider-for-jenkins.md).

As per the Dynatrace docs, [SAML 2.0 is supported for a Dynatrace SaaS deployment](https://www.dynatrace.com/support/help/manage/access-control/user-management-and-sso) and is also [supported by auth.redhat.com](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/how_to_get_sso_for_your_application_or_vendor).

We'll proceed by following the [How to get SSO for your application or vendor](https://source.redhat.com/groups/public/identity-access-management/identity__access_management_wiki/how_to_get_sso_for_your_application_or_vendor) doc and follow-up with a ticket to work with the SSO team to ensure there aren't compatibility concerns with [Dynatrace's IdP requirements](https://www.dynatrace.com/support/help/manage/access-control/user-management-and-sso/manage-users-and-groups-with-saml#idp-requirements).

### Authorization

As stated earlier in the doc, the authorization aspects of this document will be covered in a separate doc.

## Alternatives considered

### SSO Alternatives

There weren't any other alternatives to consider for SSO. sso.redhat.com is for external use cases (customers) and we're largely moving away from GitHub IdP as previously stated in the document. Dynatrace only supports SAML 2.0, so there weren't additional protocols to choose from.

## Milestones

1. Enable SSO for redhat.com accounts at Dynatrace
