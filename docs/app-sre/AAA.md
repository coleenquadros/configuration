# Anthology of AppSRE Axioms

* Anthology: *a published collection of poems or other pieces of writing*
* Axiom: *a statement or proposition which is regarded as being established, accepted, or self-evidently true.*

## Index

<!-- TOC -->

- [Anthology of AppSRE Axioms](#anthology-of-appsre-axioms)
    - [Index](#index)
    - [Preface](#preface)
    - [Complementary Documentation and Resources](#complementary-documentation-and-resources)
    - [AppSRE Engineer Setup](#appsre-engineer-setup)
        - [Registering the user in App-Interface](#registering-the-user-in-app-interface)
    - [Access and Surfaces list](#access-and-surfaces-list)
        - [Surfaces](#surfaces)
        - [Returning Red Hat Employee Gotchas](#returning-red-hat-employee-gotchas)
    - [On call](#on-call)
        - [Pagerduty set up](#pagerduty-set-up)
        - [Follow the sun](#follow-the-sun)
        - [Primary on-call](#primary-on-call)
        - [Secondary on-call](#secondary-on-call)
    - [Incident Process](#incident-process)
    - [Service Onboarding](#service-onboarding)
    - [Contract](#contract)
    - [External Teams](#external-teams)
        - [Generic Resources](#generic-resources)
        - [Reporting an Issue](#reporting-an-issue)
        - [EXD Infra](#exd-infra)
        - [IT Platform Team](#it-platform-team)
    - [Knowledge Sharing](#knowledge-sharing)
        - [Introduction](#introduction)
        - [Maintaining access pieces](#maintaining-access-pieces)
        - [Maintaining escalation channels](#maintaining-escalation-channels)
        - [Following Incident Procedure](#following-incident-procedure)
        - [SRE Checkpoints](#sre-checkpoints)
        - [Training Resources](#training-resources)
        - [Deep Dive sessions](#deep-dive-sessions)

<!-- /TOC -->

## Preface

This documents is for AppSRE engineer consumption.

It aims to ensure agreement and govern the AppSRE continuity and readiness plan.
Information within this document aims to be the authoritative source for access,
surfaces and processes, including incident management.

## Complementary Documentation and Resources

* [AppSRE Resources](https://source.redhat.com/groups/public/sre-services/sre_services_wiki/appsre_introduction)
* [App-Interface](https://gitlab.cee.redhat.com/service/app-interface)
* [AppSRE Contract](https://gitlab.cee.redhat.com/app-sre/contract)
* [Developer's Guide](https://service.pages.redhat.com/dev-guidelines/)
* [Service Delivery / AppSRE shared
  drive](https://drive.google.com/drive/u/0/folders/1sQGfo57eU7UAKfbBy8LgwxhMdnzXc0KZ).
  Shared with Service Delivery.
* [AppSRE Team
  Drive](https://drive.google.com/drive/u/0/folders/0B9akCOYRTJW_TFAxOUtEaWtRZWs).
  Viewable and editable by AppSRE members only.

## AppSRE Engineer Setup

### Registering the user in App-Interface

Most of the resources required as an AppSRE will be obtained via a user definition with AppSRE specific roles in App-Interface.

* Developer's guide: [How to add a user to
  App-Interface](https://service.pages.redhat.com/dev-guidelines/docs/appsre/onboarding/team/).
  [How to add
  roles](https://service.pages.redhat.com/dev-guidelines/docs/appsre/onboarding/roles/).
* AppSRE engineers are located here:
  https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/data/teams/app-sre/users.
* [Generic documentation on how to add a
  user](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#add-or-modify-a-user-accessusers-1yml).
* Make sure your user file includes the `public_gpg_key` field.
  [Instructions](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master#adding-your-public-gpg-key).

## Access and Surfaces list

### Surfaces

Every AppSRE/MT-SRE engineer should have access to the following:

* LDAP
  * If needed can reset KRB password
    [here](https://password.corp.redhat.com/changepassword).
  * https://gitlab.cee.redhat.com/app-sre/infra: keeps our Ansible and Terraform bits and bobs.
* Slack: coreos.slack.com
  * #sd-app-sre-teamchat (private channel): speak to any team member to get an
    invitation.
  * User groups: @app-sre-team: obtained via this
    [permission](/data/teams/app-sre/permissions/app-sre-team-coreos-slack.yml).
* Internal IRC (irc.devel.redhat.com):
  * **#appsre**: backup channel if Slack is down or if sensitive content must be addressed.
  * **#servicedelivery**: backup channel for service delivery org if Slack is down.
  * **#MIM**: Major incident management.
  * **#aos**: Openshift channel.
* Calendar:
  * [AppSRE calendar](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV9iZ2VzaW1tYThyMTdndHJ2amxkaXU5Ym9ub0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    AppSRE engineers are encourage to create all meetings in this calendar for team awareness.
  * [SD-org PTO / OOO](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV8xN2piaHNtYmR2MTdhMTJhaHBvcDc5cWJ0a0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    Any PTO must be reported here.
  * [SD-org calendar](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV9hZzdoNG5kMnIydGlrM2dqZWxhaGRmbGhkOEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    AppSRE doesn't use this calendar usually.
* Google Meet:
  * App SRE bridge: https://meet.google.com/zti-gkvy-pvn. We refer to this room as [zti](https://meet.google.com/zti-gkvy-pvn).
* BlueJeans
  * To be used only if Google Meet is not available.
  * (Optional) Install BlueJeans client.
  * App SRE bridge: https://bluejeans.com/994349364/8531
* Mailing lists:
  * http://groups.google.com/: new mailing list manager
    * [sd-app-sre-announce](https://groups.google.com/u/0/a/redhat.com/g/sd-app-sre-announce)
  * https://post-office.corp.redhat.com/mailman/listinfo: old mailing list central
    * ACCESS: sd-app-sre. Speak to @jonathan beakley.
    * ACCESS: sd-notifications. Subscribe from UI.
    * ACCESS: sd-org. Subscribe from UI.
    * ACCESS: sres. Subscribe from UI.
    * ACCESS: outage-list. Subscribe from UI.
    * ACCESS: it-iam-announce-list. Subscribe from UI.
    * ACCESS: it-platform-community-list (useful for SSO). Subscribe from UI.
  * Optional - Additional information surfaces, subscription not mandatory
    * ACCESS: aos-devel: very high volume (useful to get the latest news about OpenShift development). Subscribe from UI.
* Sd-org onboarding
  * ACCESS Contact Meghna Gala (mgala@redhat.com) re Sd-org onboarding (may not be needed)
    * Added to sd-org mailing list
  * ACCESS: [Jira](https://issues.redhat.com)
    * Email openshift-jira-admin@redhat.com for any issues
    * Jira boards [Sprint Board](https://issues.redhat.com/secure/RapidBoard.jspa?rapidView=5536) & [SD Epics](https://issues.redhat.com/projects/SDE)
* github.com/openshift
  * ACCESS: https://source.redhat.com/groups/public/atomicopenshift/atomicopenshift_wiki/openshift_onboarding_checklist_for_github
  * Ping [Bill Dettelback](https://rover.redhat.com/people/profile/bdettelb) on slack or mail for access to [quay github org](https://github.com/quay)
* Bugzilla
  * ACCESS: Ensure you have access to [bugzilla](https://bugzilla.redhat.com)
    * Login as Red Hat Associate with kerberos credentials
  * Verify you have permissions to view private and private_comment. This should be provided as part of the redhat group. See [here](https://docs.engineering.redhat.com/pages/viewpage.action?spaceKey=OMEGA&title=Group+Membership+Policy) for group information.
* Pagerduty
  * ACCESS: Create a [Jira ticket](https://issues.redhat.com/) in the OHSS board to request access to PagerDuty, and assign it to [Meghna Gala](https://rover.redhat.com/people/profile/mgala)
  * you can check this [example ticket](https://issues.redhat.com/browse/OHSS-2547), but double check the assignee before commiting.
* AppSRE shared folders
  * ACCESS: Go to the following folders and request access with your Red Hat Gsuite account
    * [Public Top Level Directory](https://drive.google.com/drive/u/1/folders/1sQGfo57eU7UAKfbBy8LgwxhMdnzXc0KZ) (contains RCAs, etc)
    * [Private](https://drive.google.com/drive/u/1/folders/0B9akCOYRTJW_TFAxOUtEaWtRZWs) (for AppSRE Team members only)
* Vault
  * Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
    * [setup instructions](https://service.pages.redhat.com/dev-guidelines/docs/appsre/onboarding/adding-sensitive-data/#getting-access-to-vault)
* Quay
  * Login to/Create account at https://quay.io
    * Attach with Red Hat SSO.
  * Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  * Add `quay_username` in the [user file](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/teams/app-sre/users) and populate with quay user.
* ssh access to jenkins related instances
  * Via MR to [app-sre/infra repo](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all)
    * add username and public part of your ssh key like [here](https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/144)

Every AppSRE engineer should have access to the following:

* GitHub
  * GitHub profile must include `Company: Red Hat`.
  * Verify inclusion in all github orgs listed
    [here](https://visual-app-interface.devshift.net/githuborgs).
* Gitlab:
  * https://gitlab.cee.redhat.com/app-sre
    * Access to all repositories is managed via this group.
    * Obtained via this [role](/data/teams/app-sre/roles/app-sre.yml).
  * https://gitlab.cee.redhat.com/service/app-interface
* AppSRE OCM org (https://console.redhat.com/openshift)
  * Access is [configured manually by an org administrator](/docs/app-sre/sop/ocm-appsre-org-access.md)
* AWS
  * Nothing to do. Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  * Make sure you enable MFA in **all** your AWS accounts.
* App SRE infrastructure managed by ansible
  * Access is managed by adding ssh keys to the [admin-list](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/hosts/group_vars/all#L4) and applying the `baseline` role to all hosts. It is recommended that ssh key is RSA, 4096-sized and password-protected as those are the [requirements for Tier 1 Bastion keys](https://source.redhat.com/groups/public/openshiftplatformsre/wiki/faq_openshift_tiered_access_overview_for_osd3#jive_content_id_Tier_1)
* OpenStack Project infrastructure
  * We have our ci-int infrastructure deployed [here](https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project)
    * Domain: redhat.com
    * Kerberos login and password
  * Detailed info [here](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/openstack-ci-int.md)
* Tier 1 Bastion access for OSD3 (optional - mostly not needed):
  * This is necessary to access some clusters that are not publicly exposed (for example hive shards still in OSDv3)
  * Access process is documented [here](https://source.redhat.com/groups/public/openshiftplatformsre/wiki/faq_openshift_tiered_access_overview_for_osd3)
    * You should request Tier1
* Pendo:
  * This is necessary to post maintenance and outage messages in https://console.redhat.com/openshift
  * Access is provided via email to Allie Higgins <ahiggins@redhat.com>.
  * [Logging](https://app.pendo.io/login) in is done using the full Red Hat email.
* Unleash:
  * Feature toggle service to enable/disable features in runtime.
  * AppSRE unleash instance is here: https://app-interface.unleash.devshift.net/
  * More details available [here](https://gitlab.cee.redhat.com/service/dev-guidelines/blob/master/unleash.md)
* SendGrid
  * Nothing to do, granted by `sendgrid_accounts` in the [AppSRE role](data/teams/app-sre/roles/app-sre.yml).
* Deadman's snitch
  * Ask somebody in the team to invite you to the organization. You'll receive an e-mail with a link to the invite. Create a new account then, it will be added automatically to the organization and you'll see all the heartbeats we have configured. You'll also be able to create even more.

### Returning Red Hat Employee Gotchas

* Accounts need to be re-enabled
  * Bugzilla
    * Send e-mail to bugzilla-owner@redhat.com or create ticket at the [Help
      Portal](https://help.redhat.com/)
    * It is likely the re-activated account will not have the needed
      permissions. Request access to the devel group by following the directions
      [here](https://docs.engineering.redhat.com/display/OMEGA/Group+Membership+Policy)
  * Bluejeans
    * Create an IT ticket

## On call

The AppSRE on call schedule is a rotation to ensure handling of service outages
and incidents for our application owners. Schedule of past, current and future
on call rotation can be viewed @ pagerduty: https://redhat.pagerduty.com/

### Pagerduty set up

Ensure you are listed with the appropriate contact detail in your Pagerduty profile.
The recommended setup includes the pagerduty app on your mobile phone. From the website you can test notifications to ensure that you have correctly set up the application to override any do not disturb settings.

For notification troubleshooting see: https://support.pagerduty.com/docs/notification-troubleshooting

### Follow the sun

The follow the sun cycle (FTS) is an on-call rotation to ensure that the first page triggered by an alert goes to an engineer who, at the time, is within regular working hours. This is to prevent direct pages to the primary on-call within the regular hours of others. If there is no engineer available within their regular hours the page will go directly to the primary on-call.

Schedule: https://redhat.pagerduty.com/schedules#PQ022DV

Any person currently active as the FTS, will also be the IC (Interrupt Catcher), documented [here](/docs/app-sre/interrupt-catching.md).

### Primary on-call

The primary on-call is a 24/7 on-call rotation assigned on a weekly basis. The engineer assigned is required to be available for the initial response within 30 minutes of the page.

Pages for primary on-calls should be be kept at a minimum and are reserved for critical issues in production environments which need immediate attention.

The primary on-call also acts as the interrupt-catcher during their work hours that cycle.

Schedule: https://redhat.pagerduty.com/schedules#PHS3079

### Secondary on-call

The secondary on-call is a 24/7 on-call rotation that serves as backup and support function for the primary on-call. The secondary on-call will be paged if the primary on-call does not aknowledge the incident via Pagerduty (via app, slack integration or other means). The engineer assigned is required to be available for the initial response within 30 minutes of the page.

Schedule: https://redhat.pagerduty.com/schedules#PSTVSQD

## Incident Process

Documented in the [Incident Process](./incident-process.md) SOP.

## Service Onboarding

The process for Service Onboarding is documented here:
https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/service/service_onboarding_flow.md

## Contract

AppSRE establishes a contract with the tenants. The contract is live here:
https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/README.md

All Services must satisfy the list of ACs (Acceptance Criteria): [acs.html](https://app-sre.pages.redhat.com/contract/acs.html) and [acs.txt](https://app-sre.pages.redhat.com/contract/acs.txt)

## External Teams

### Generic Resources

* [PnT DevOps - Issue Escalation Procedure](https://docs.engineering.redhat.com/pages/viewpage.action?pageId=140541042)
* [Red Hat Major Incident Management (MIM)](https://source.redhat.com/groups/public/it-major-incident-management)
* [IT ISO (IT Operations)](https://source.redhat.com/groups/public/iso/it_operations_iso_wiki/welcome_to_it_iso_it_operations)

### Reporting an Issue

1. Create a case: [Service Now (snow) - PnT General Request](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=4c66fd3a1bfbc4d0ebbe43f8bc4bcb6a)

    1.1. For CEE GitLab:

       - Impact: 2 - Affects all of Red Hat
       - Urgency: 2 - No workaround; blocks business-critical processes
       - Application: DevOps - GitLab
       - Assign to this group - CI/CD PNT (Should auto-fill)
       - Mention `https://gitlab.cee.redhat.com` is inaccessible in the description

    1.2. For CentralCI Jenkins:

       - Category: `Virtualization/Cloud`
       - Item: `CI-RHOS`
       - Hostname Affected: `https://ci.int.devshift.net`

2. If this is a weekend (Saturday / Sunday), escalate issue following the [PnT DevOps - Issue Escalation Procedure](https://docs.engineering.redhat.com/pages/viewpage.action?pageId=140541042).
3. Join the PnT DevOps Google Chat room https://chat.google.com/u/0/room/AAAA6BChWkY
4. Join the Red Hat IT Ops Google Chat room https://chat.google.com/u/0/room/AAAAiUsrxXk
5. Join the Red Hat IT Outage Google Chat room https://chat.google.com/u/0/room/AAAA5dCEP_Q

### EXD Infra

They run GitLab. They can be found in the [exd-infra-escalation](https://chat.google.com/u/0/room/AAAA6BChWkY) channel. Contact: [Savitoj Singh](mailto:savsingh@redhat.com).

### IT Platform Team

Manager: https://mojo.redhat.com/people/aowens
TL: https://mojo.redhat.com/people/jblashka

The IT Platform team runs components like:

* `sso.redhat.com`
  * C1 SLA (see resources below)
  * Quick link to [blackbox poll Prometheus data](https://prometheus.app-sre-prod-01.devshift.net/graph?g0.range_input=2h&g0.stacked=1&g0.expr=probe_success%7Binstance%3D~%22.*sso.redhat.com.*%22%7D&g0.tab=0) for sso.redhat.com
  * In order to escalate a production incident this email can be used: `it-es-platform-page@redhat.com`.
  * To get ahold of a person directly to follow up on an escalation or incident connect to the [IT/ISO Google chat](https://chat.google.com/u/0/room/AAAAiUsrxXk)

## Knowledge Sharing

This section documents the specific processes related to knowledge sharing by
the AppSRE team in order to maintain a high level of accuracy and coverage of
all the knowledge within AppSRE.

### Introduction

The purpose of this section is to document how knowledge is shared by the
AppSRE, both internally and externally.

Before diving into specific processes, it is important to state that the team
has a very clear mission with regard to knowledge sharing:

* There are no single owners or SMEs for any of the components and processes
  owned or implemented by the AppSRE team.
* It is the responsibility of every AppSRE member to make sure no knowledge is
  siloed, and to share any new knowledge piece with the rest of the team using
  the implemented processes and channels.
* Each AppSRE member has the right to raise any concerns about any knowledge
  gaps and the team will prioritize filling in those gaps.

### Maintaining access pieces

Access pieces are a very quickly moving target, and they change very frequently. In order to maintain an accurate list of access pieces these actions must be followed by the each AppSRE team member:

* All access pieces are documented in the [Access and surfaces list](#access-and-surfaces-list) section.
* If an AppSRE team member gains access to something and it's not linked from in this list, it's their responsibility to add it there.
* This list is actively reviewed by onboarding AppSRE members.

### Maintaining escalation channels

Similarly as with the access pieces:

* All escalation channels are referenced from the specific `app-1.yml` file of the service in App-Interface.

### Following Incident Process

All AppSRE team members will follow the [Incident Process](./incident-process.md) as accurately as possible, raise any concers and keep it up to date.

### SRE Checkpoints

All Services will receive an SRE Checkpoint periodically. Each SRE Checkpoint will take 1 day, and each AppSRE engineer will conduct one per sprint. [Further information](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/process/sre_checkpoints.md).

### Training Resources

The AppSRE team will maintains an index of training resources. All AppSRE members must go through those training documents:
https://source.redhat.com/groups/public/sre-services/sre_services_wiki/appsre_introduction#jive_content_id_AppSRE_Training

### Deep Dive sessions

On a periodical basis, the AppSRE team will hold "Deep Dive sessions". These sessions have the following characteristics:

* The main goal is to share knowledge within the AppSRE team.
* Periodicity: every 6 weeks.
* 1h sessions.
* Presentations should have an accompanying slide deck and must be well prepared.
* Any topics that are directly related to the AppSRE day-to-day will be prioritized over general knowledge ones.
* Attendance from all the team members is strongly encouraged, as well as participation and making the sessions dynamic.

Those sessions are tracked in this document: [AppSRE Deep Dives](https://docs.google.com/document/d/1T4QNO2qQYpBl4uhiNdr2iP7LO1pfmCVkzyWHgHDIIJA/edit).

Every AppSRE member that identifies any knowledge gaps in our documentation / resources has the responsibility of adding new proposals to the Deep Dives list of proposals.
