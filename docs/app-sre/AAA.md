# Anthology of App-SRE Axioms

Anthology: *a published collection of poems or other pieces of writing*
---
Axiom: *a statement or proposition which is regarded as being established, accepted, or self-evidently true.*
---

## Index

<!-- TOC -->

- [Anthology of App-SRE Axioms](#anthology-of-app-sre-axioms)
    - [Index](#index)
    - [Preface](#preface)
    - [Changes](#changes)
    - [Other sources of documentation you might be looking for:](#other-sources-of-documentation-you-might-be-looking-for)
    - [Access and surfaces list](#access-and-surfaces-list)
        - [Returning Red Hat Employee Gotchas](#returning-red-hat-employee-gotchas)
    - [On call](#on-call)
        - [Primary on-call + interrupt catching](#primary-on-call--interrupt-catching)
        - [Pagerduty set up](#pagerduty-set-up)
        - [Follow the sun](#follow-the-sun)
        - [Primary on-call](#primary-on-call)
        - [Secondary on-call](#secondary-on-call)
        - [Escalation](#escalation)
        - [Notification](#notification)
        - [Incident procedure](#incident-procedure)
    - [Standard operating procedures](#standard-operating-procedures)
    - [App oboarding / app acceptance criteria](#app-oboarding--app-acceptance-criteria)
        - [In the app-interface](#in-the-app-interface)
    - [Additional team process](#additional-team-process)
        - [Git process](#git-process)
        - [Sprint process](#sprint-process)
    - [App-sre escalation to external teams](#app-sre-escalation-to-external-teams)
        - [PnT Devops](#pnt-devops)
- [Knowledge Sharing](#knowledge-sharing)
    - [Processes](#processes)
        - [Maintaining access pieces](#maintaining-access-pieces)
        - [Maintaining escalation channels](#maintaining-escalation-channels)
        - [Alerting coverage](#alerting-coverage)
        - [Following Incident Procedure](#following-incident-procedure)
        - [On-call pairings](#on-call-pairings)
        - [Periodically reviewed service docs](#periodically-reviewed-service-docs)
        - [Training Sessions at onboarding](#training-sessions-at-onboarding)
        - [Deep Dive sessions](#deep-dive-sessions)
- [IT Platform Team](#it-platform-team)
    - [Escalation procedures](#escalation-procedures)
        - [Telemeter incidents](#telemeter-incidents)
    - [Contacts](#contacts)
        - [Acknowledgements](#acknowledgements)
    - [Services](#services)
- [Glossary](#glossary)
    - [PnT](#pnt)
    - [PnT Ops](#pnt-ops)
    - [PnT DevOps](#pnt-devops)

<!-- /TOC -->

## Preface

This documents is for App-sre engineer consumption and aims to ensure agreement around and govern the App-sre continuity and readiness plan.
It serves as the top node and authorative source for documentation around App-sre process.

The document itself consists of two main sections, the first details prerequisites and process pieces that every App-sre engineer needs to have in place.  This serves as a checklist for access and details contact points on how to aquire any lacking access.

The second section consists of operational procedures and documentation that serves as references during incident work.

Information within this document aims to be he authorative source for process and (until further notice) contacts.  For details on the specifics of the operational environment the app-interface supercedes this document - hence this should be viewed as complementary and authorative only concerning process.  Content in this document should aim to reference the app-interface schemas as opposed to duplicating it, where possible.

Additionally there is a contact section near the end which details the escalations and contact for external groups and dependencies.
The goal is to move this to the app-interface itself as it matures.

## Changes

- This document was created and maintained using vscode, using Markdown ToC plugin
- Merge requests are accepted but require team lead signoff
- As it is important to communicate and gain common aknowledgement of process captured within, this document will be reviewed every sprint retro when there are changes.  If you can not attend a sprint retro, make sure you review this document before going on call.
- Prior to each

## Other sources of documentation you might be looking for:

- The app-interface: https://gitlab.cee.redhat.com/service/app-interface
- The developers guide: https://gitlab.cee.redhat.com/service/dev-guidelines
- App-sre team drive: https://drive.google.com/drive/u/0/folders/0B9akCOYRTJW_TFAxOUtEaWtRZWs

## Access and surfaces list

Every app-sre engineer should have access to the following

- Github / LDAP username
  - If needed can reset KRB password [here](https://password.corp.redhat.com/changepassword)
  - Verify inclusion in all github orgs listed [here](https://visual-app-interface.devshift.net/githuborgs)

- Gitlab:
  - https://gitlab.cee.redhat.com/app-sre
    - Access to all repositories is managed via this group
    - Obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  - https://gitlab.cee.redhat.com/service/app-interface
    - create a user file under the [app-sre team](/data/teams/app-sre/users) directory via a merge request off a fork of app-interface
  - https://gitlab.cee.redhat.com/app-sre/infra
    - Keeps our Ansible and Terraform bits and bobs
  - https://gitlab.cee.redhat.com/dtsd/housekeeping
    - Used to keep all our bits and bobs - Ansible, terraform, python, scripts etc
    - Currently being deprecated as part of https://issues.redhat.com/browse/APPSRE-1495

- Slack: coreos.slack.com
  - Private channels: sd-app-sre-teamchat -> speak to any team member to get an invitation
  - User groups: @app-sre-team -> obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  - Channels: as stated [here](/data/teams/app-sre/permissions/app-sre-team-coreos-slack.yml) -> obtained via the @app-sre-team user group membership

- Internal IRC (irc.devel.redhat.com):
  - __#appsre__: backup channel if Slack is down or if sensitive content must be addressed.
  - __#servicedelivery__: backup channel for service delivery org if Slack is down.
  - __#MIM__: Major incident management
  - __#aos__: Openshift
  - __#libra-ops__: Openshift SD SRE-ops
  - __#libra-noc__: Openshift SD SRE

- Calendar:

  - [SD-org calendar](https://calendar.google.com/calendar?cid=cmVkaGF0LmNvbV9hZzdoNG5kMnIydGlrM2dqZWxhaGRmbGhkOEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t)
  - [SD-org PTO / OOO](https://calendar.google.com/calendar?cid=cmVkaGF0LmNvbV8xN2piaHNtYmR2MTdhMTJhaHBvcDc5cWJ0a0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t)

- Google Meet:

  - App SRE bridge: https://meet.google.com/zti-gkvy-pvn

- BlueJeans (still used for communications with teams not migrated to Google Meet and as backup solution when Meet is down):

  - Install bluejeans client
  - App SRE bridge: https://bluejeans.com/994349364/8531

- Invite to sprint kickoffs, coordination sessions
- Mailing lists:
  - Many people just use the web email client, others use thunderbird.
  - Recommended to sort into folders
  - https://post-office.corp.redhat.com/mailman/listinfo is the mailing list central
    - ACCESS: sd-app-sre -> speak to @jonathan beakley or @paul on slack
    - ACCESS: sd-notifications -> subscribe from UI
    - ACCESS: sd-org -> subscribe from UI
    - ACCESS: sres -> subscribe from UI
    - ACCESS: devtools-saas -> subscribe from UI
    - ACCESS: devtools-team -> subscribe from UI
    - ACCESS: outage-list -> subscribe from UI
    - ACCESS: aos-devel -> subscribe from UI
    - ACCESS: it-iam-announce-list -> subscribe from UI
    - ACCESS: it-platform-community-list (useful for SSO) -> subscribe from UI

- GPG key:
  - Generate one and put in:
    - base64 encoded binary in your app-interface user file -> [instructions](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master#adding-your-public-gpg-key)
      - User file located in [app-interface repo](/data/teams/app-sre/users)
  - Use a passphrase!
  - External reference for [generating](https://www.gnupg.org/gph/en/manual/c14.html) and [exporting](https://www.gnupg.org/gph/en/manual/x56.html)

- Sd-org onboarding
  - ACCESS Contact Meghna Gala (mgala@redhat.com) re Sd-org onboarding (may not be needed)
    - Added to sd-org mailing list
    - Added to team tracking sheets (?)
  - ACCESS: [Jira](https://issues.redhat.com)
    - Email openshift-jira-admin@redhat.com for any issues
    - Jira boards [Sprint Board](https://issues.redhat.com/secure/RapidBoard.jspa?rapidView=5536) & [SD Epics](https://issues.redhat.com/projects/SDE)

- Openshift github onboarding (access to private repositories in openshift github org):
  - ACCESS: https://mojo.redhat.com/docs/DOC-1081313#jive_content_id_Github_Access
  - Submit PRs to be added to OWNERS once access is granted:
    - https://github.com/openshift/telemeter/blob/master/OWNERS
    - https://github.com/openshift/cincinnati/blob/master/OWNERS_ALIASES
  - Ping on slack for access to quay github group

- App-SRE OCM org (https://cloud.redhat.com/openshift)
  - Access is [configured manually by an org administrator](/docs/app-sre/sop/ocm-appsre-org-access.md)

- AWS
  - Nothing to do. Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)

- Vault
  - Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
    - [setup instructions](https://gitlab.cee.redhat.com/service/dev-guidelines/blob/master/vault.md)

- Quay
  - Login to/Create account at https://quay.io
    - Can use github account for simplicity
  - Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  - Create `quay_username` in the [user file](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/teams/app-sre/users) and populate with quay user

- Bugzilla
  - ACCESS: Ensure you have access to [bugzilla](https://bugzilla.redhat.com)
    - Login as Red Hat Associate with kerberos credentials
  - Verify you have permissions to view private and private_comment.  This should be provided as part of the redhat group.  See [here](https://mojo.redhat.com/docs/DOC-1197751) for group information.

- Dedicated admin on openshift clusters
  - Nothing to do. Obtained via a [role](data/teams/app-sre/roles/app-sre.yml)

- Pagerduty
  - ACCESS: Create a [Jira ticket](https://issues.redhat.com/) to request access to PagerDuty and then reach out to [Bill Montgomery](mailto:bmontgom@redhat.com) with the ticket number<br/>
   [Example ticket](https://issues.redhat.com/browse/OHSS-1078)

- App-sre shared folders
  - ACCESS: Go to the following folders and request access with your Red Hat Gsuite account
    * [Public Top Level Directory](https://drive.google.com/drive/u/1/folders/1sQGfo57eU7UAKfbBy8LgwxhMdnzXc0KZ) (contains RCAs, etc)
    * [Private](https://drive.google.com/drive/u/1/folders/0B9akCOYRTJW_TFAxOUtEaWtRZWs) (for AppSRE Team members only)
    
- App SRE infrastructure managed by ansible
  - Access is managed by adding ssh keys to the [admin-list](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/hosts/group_vars/all#L4) and applying the `baseline` role to all hosts. It is recommended that ssh key is RSA, 4096-sized and password-protected as those are the [requirements for Tier 1 Bastion keys](https://mojo.redhat.com/docs/DOC-1144200#jive_content_id_Tier_1)

- OpenStack Project infrastructure
  - We have our ci-int infrastructure deployed [here](https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project)
    - Domain: redhat.com
    - Kerberos login and password
  - Detailed info [here](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/openstack-ci-int.md)

- Tier 1 Bastion access:
  - This is necessary to access some clusters that are not publicly exposed (for example hive-production)
  - Access process is documented [here](https://mojo.redhat.com/docs/DOC-1144200)
    - You should request Tier1

- Tier 2 access for OSIO starter clusters.
  - This is necessary to be able to the OSIO starter cluster consoles and execute `oc` locally.
  - Access process is documented [here](https://mojo.redhat.com/docs/DOC-1144200)
    - You should request Tier2
    - You can find an example of a request [here](https://redhat.service-now.com/help?id=rh_ticket&table=incident&sys_id=50c9c5f51b9098d0839e32a3cc4bcbc2)

- Pendo:
  - This is necessary to post maintenance and outage messages in https://cloud.redhat.com/openshift
  - Access is provided via email to Cameron Britt <cbritt@redhat.com> and Jeremy Perry <jeperry@redhat.com>.
  - [Logging](https://app.pendo.io/login) in is done using the full Red Hat email.

- Unleash:
  - Feature toggle service to enable/disable features in runtime.
  - More details available [here](https://gitlab.cee.redhat.com/service/dev-guidelines/blob/master/unleash.md)

### Returning Red Hat Employee Gotchas

- Accounts need to be re-enabled
  - Bugzilla
    - Send e-mail to bugzilla-owner@redhat.com or create ticket at the [Help Portal](https://help.redhat.com/)
    - It is likely the re-activated account will not have the needed permissions.  Request access to the devel group by following the directions [here](https://mojo.redhat.com/docs/DOC-1197751)
  - Bluejeans
    - Create an IT ticket

## On call

The App-sre on call schedule is a rotation to ensure handling of service outages and incidents for our application owners.
Schedule of past, current and future on call rotation can be viewed @ pagerduty: https://redhat.pagerduty.com/

The on call includes three tiers of response, detailed below.

### Primary on-call + interrupt catching

- Interrupt catching is detailed in this [document](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/interrupt-catching.md)
  - include on-call specifics

### Pagerduty set up

Ensure you are listed with the appropriate contact detail in your Pagerduty profile.
The recommended setup includes the pagerduty app on your mobile phone.  From the website you can test notifications to ensure that you have correctly set up the application to override any do not disturb settings.

For notification troubleshooting see: https://support.pagerduty.com/docs/notification-troubleshooting

### Follow the sun

The follow the sun cycle (FTS) is an on-call rotation to ensure that the first page triggered by an alert goes to an engineer who, at the time, is within regular working hours. This is to prevent direct pages to the primary on-call within the regular hours of others. If there is no engineer available within their regular hours the page will go directly to the primary on-call.

### Primary on-call

The primary on-call is a 24/7 on-call rotation assigned on a weekly basis.  The engineer assigned is required to be available for the initial response within 30 minutes of the page.

Pages for primary on-calls should be be kept at a minimum and are reserved for critical issues in production environments which need immediate attention.

The primary on-call also acts as the interrupt-catcher during their work hours that cycle.

### Secondary on-call

The secondary on-call is a 24/7 on-call rotation that serves as backup and support function for the primary on-call. The secondary on-call will be paged if the primary on-call does not aknowledge the incident via Pagerduty (via app, slack integration or other means).

### Escalation

### Notification

### Incident procedure

What constitutes an incident:

If any of the following is true, the event is an incident:

- Is the outage visible to customers (internal or external)?
- Do you need to involve a second team in fixing the problem?
- Does the outage result in breach of Service SLO's?

Tracking:

- Start off by creating a JIRA issue for the incident on the [Incident board](https://issues.redhat.com/secure/RapidBoard.jspa?rapidView=5146)
  - Issue type: `Task`
  - Labels: `type/incident`

- Create a Google doc for live incident status and RCA:
  - Clone the [incident RCA template](https://docs.google.com/document/d/12ZVT35yApp7D-uT4p29cEhS9mpzin4Z-Ufh9eOiiaKU/edit)
  - Add Incident title and JIRA link
  - Post the doc link back into the JIRA ticket
  - Guidelines on how to write the incident report are available in the [Google Doc](https://docs.google.com/document/d/165eDunz6yy9uIi2XXxWaEpODCVFp9tYhnBF607qVexg/edit)

Initiate incident communications:

- Send message to the #sd-org slack channel. Keep it updated with the incident progress.
- If deemed appropriate, a new channel can be created in slack: #incident-app-sre-<JIRAID>. This channel should be linked from #sd-org.
- If applicable, update the service statuspage following the available SOP:
  - [Updating status.quay.io](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/quay/statuspage.md)
  - [Updating status.redhat.com](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/statuspage.md)
- Send email to:
  - [serviceOwners](https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/app-sre/app-1.yml)
  - [serviceNotifications](https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/app-sre/app-1.yml). This list may include `outage-list@redhat.com`, make sure an email is sent to that list if it's a major outage and if that list includes the outage list.
  - sd-notifications@redhat.com
  - sd-org@redhat.com (major outage)

Email template:

```text
Subject: `<YYYY-MM-DD> Incident: <ServiceName> <Optional highlights>`

Hello team,

We are investigating an ongoing incident affecting <ServiceName>.

Impacted users: <Internal/External>

App-SRE tracking JIRA: <Link for JIRA ticket created above>

We will provide updates in the #sd-org slack channel as the incident progresses.
```

During the incident:

- Join the [App-SRE Meet Bridge](https://meet.google.com/zti-gkvy-pvn) or [App-SRE Bluejeans Bridge](https://bluejeans.com/994349364/8531) in case Meet is down
  - If the incident investigation needs assistance from the developer teams, also send them the link and ask to join in

Post incident comms, followups:

- After the incident has been confirmed as resolved, send an email indicating that the incident has been resolved / mitigated
- Create issues from the action items on the respective team JIRA boards, link them back to the incident tracker

Post RCA comms, followups:

- After the RCA is finished, post a link to it in #sd-org, and emails to the `serviceOwners` (and to `sd-org` in case of a major outage).

## Standard operating procedures

- SOPs related to engineering tasks are to be stored in the app-interface/docs/app-sre/docs folder.
- A SOP should have the following filename format: [CATEGORY]-[SHORT_DESCRIPTION].md
    - Where category is 'OSD', [servicename] or other relevant category
- A SOP should contain the following information:
    - Author
    - Date last modified
    - Access required
    - Detailed procedure

## App oboarding / app acceptance criteria

### In the app-interface

* Must contain the following fields
    * Service owner
    * Incident contact
    * Continuity plan reference

## Additional team process

### Git process

### Sprint process
* [see process/sprint.md](process/sprint.md)

## App-sre escalation to external teams

### PnT Devops

* [PnT DevOps - Issue Escalation Procedure](https://mojo.redhat.com/docs/DOC-1049381) - Mojo
  * NA Escalation manager - https://rover.redhat.com/people/profile/akrawczy
* [Red Hat Major Incident Management (MIM)](https://mojo.redhat.com/groups/it-major-incident-management)
* [IT ISO (IT Operations)](https://mojo.redhat.com/docs/DOC-1071493)

1. Create a case: https://redhat.service-now.com/help?id=sc_cat_item&sys_id=4c66fd3a1bfbc4d0ebbe43f8bc4bcb6a

    1.1 For CEE GitLab:

        * Impact: 2 - Affects all of Red Hat

        * Urgency: 2 - No workaround; blocks business-critical processes

        * Application: DevOps - GitLab

        * Assign to this group - CI/CD PNT (Should auto-fill)

        * Mention `https://gitlab.cee.redhat.com` is inaccessible in the description

    1.2 For CentralCI Jenkins:

        * Category: `Virtualization/Cloud`

        * Item: `CI-RHOS`

        * Hostname Affected: `https://ci.int.devshift.net`

2. If this is a weekend (Saturday / Sunday), escalate issue following the [PnT DevOps - Issue Escalation Procedure](https://mojo.redhat.com/docs/DOC-1049381#jive_content_id_Business_Critical_Issues).

3. Join the PnT DevOps Google Chat room https://chat.google.com/room/AAAA6BChWkY

4. Join the Red Hat IT Ops Google Chat room https://chat.google.com/room/AAAAiUsrxXk

# Knowledge Sharing

The purpose of this section is to document how knowledge is shared by the AppSRE, both internally and externally.

Before diving into specific processes, it is important to state that the team has a very clear mission with regard to knowledge sharing:

- There are no single owners or SMEs for any of the components and processes owned or implemented by the AppSRE team.
- It is the responsibility of every AppSRE member to make sure no knowledge is siloed, and to share any new knowledge piece with the rest of the team using the implemented processes and channels.
- Each AppSRE member has the right to raise any concerns about any knowledge gaps and the team will prioritize filling in those gaps.
- Equally important as internal knowledge

## Processes

This section documents the specific processes implemented by the AppSRE team in order to maintain a high level of accuracy and coverage of all the knowledge within AppSRE.

### Maintaining access pieces

Access pieces are a very quickly moving target, and they change very frequently. In order to maintain an accurate list of access pieces these actions must be followed by the each AppSRE team member:

- All access pieces are documented in the [Access and surfaces list](#access-and-surfaces-list) section.
- If an AppSRE team member gains access to something and it's not linked from in this list, it's their responsibility to add it there.
- This list is actively reviewed by onboarding AppSRE members.

### Maintaining escalation channels

Similarly as with the access pieces:

- All escalation channels are referenced from the AAA.md doc.

### Alerting coverage

- All alerts have a corresponding document in the [sop/alerts](./sop/alerts) folder with the name `<AlertName>.md`.

### Following Incident Procedure

All AppSRE team members will follow the [Incident procedure](#incident-procedure) documented in this file as accurately as possible, raise any concers and keep it up to date.

### On-call pairings

New AppSRE team members will be paired up with more experienced team members in order to ease first incidents:

The goal of this initiative is to get SREs:

- acquainted with the services
- to understand the process on how to find information and docs about any service
- to understand the process to deal with an incident (comms, etc)

### Periodically reviewed service docs

Each service has a service intro, high level, but technically oriented description. Linked from app-1.yml / serviceDocs. This document will be periodically reviewed and signed-off by an AppSRE team member.

### Training Resources

The AppSRE team will maintains an index of training resources. All AppSRE members must go through those training documents:
https://mojo.redhat.com/docs/DOC-1211223#jive_content_id_AppSRE_Training

### Deep Dive sessions

On a periodical basis, the AppSRE team will hold "Deep Dive sessions". These sessions have the following characteristics:

- The main goal is to share knowledge within the AppSRE team.
- Periodicity: every 6 weeks.
- 1h sessions.
- Presentations should have an accompanying slide deck and must be well prepared.
- Any topics that are directly related to the AppSRE day-to-day will be prioritized over general knowledge ones.
- Attendance from all the team members is strongly encouraged, as well as participation and making the sessions dynamic.

Those sessions are tracked in this document: [AppSRE Deep Dives](https://docs.google.com/document/d/1T4QNO2qQYpBl4uhiNdr2iP7LO1pfmCVkzyWHgHDIIJA/edit).

Every AppSRE member that identifies any knowledge gaps in our documentation / resources has the responsibility of adding new proposals to the Deep Dives list of proposals.

# IT Platform Team

Manager: https://mojo.redhat.com/people/aowens
TL: https://mojo.redhat.com/people/jblashka

The IT Platform team runs components like:

- `sso.redhat.com`
  - C1 SLA (see resources below)
  - Quick link to [blackbox poll Prometheus data](https://prometheus.app-sre-prod-01.devshift.net/graph?g0.range_input=2h&g0.stacked=1&g0.expr=probe_success%7Binstance%3D~%22.*sso.redhat.com.*%22%7D&g0.tab=0) for sso.redhat.com 
  - In order to escalate a production incident this email can be used: `it-es-platform-page@redhat.com`.
  - To get ahold of a person directly to follow up on an escalation or incident connect to the [IT/ISO Google chat](https://chat.google.com/room/AAAAiUsrxXk)
  - Resources: [Applications and Systems Criticality Classification](https://mojo.redhat.com/docs/DOC-1171238) and [Business Resilience Glossary](https://mojo.redhat.com/docs/DOC-1136493).

## Escalation procedures
### Telemeter incidents

The telemetry-dev team has an oncall rotation that must be used to escalate incidents to the development team under the following conditions:

- App-SRE will remain the first responder for telemetry incidents
- Every alert with severity `critical` on telemetry will engage both the App-SRE and telemeter-dev escalation policies
- The telemeter-dev escalation policy only pages a developer on call after *30 min* since the incident was triggered
- If determined by the app-sre oncall, the telemeter-dev can be engaged earlier than 30 minutes into the incident with a manual page to the telemeter-dev oncall *via pagerduty*
- The app-sre oncall should continue to work on the incident and peer with the oncall developer.

Note: This escalation policy is a temporary status with the short term goal to improve incident-runbooks, stability and availability.

AppSRE on-call may be assigned PagerDuty incidents that were triggered by our tenants from Slack using the steps documented [here](paging-appsre-oncall.md). As these incidents are manually triggered, they may not be very detailed. Oncall should check slack messages for incident details.

## Contacts

- OSD SRE
    - #sd-sre-platform on slack.coreos.org
    - Create a JIRA: [task](https://issues.redhat.com/secure/CreateIssueDetails!init.jspa?pid=12323823&issuetype=3&customfield_12316441=14554&priority=10000) or [incident](https://issues.redhat.com/secure/CreateIssueDetails!init.jspa?pid=12323823&issuetype=10901&customfield_12316441=14554&priority=10000). [More info](https://mojo.redhat.com/docs/DOC-1223261).

- OpenStack project -> Pnt Devops https://docs.engineering.redhat.com/pages/viewpage.action?pageId=140541042


### Acknowledgements

## Services

# Glossary

## PnT

Products & Technolgies, essentially Paul Cormier’s entire 7000 person org.

## PnT Ops

Product & Technologies Business Operations lead by VP Katrinka McCallum (non-technical team).  This is where all the Program Managers and metrics people hangout.

## PnT DevOps

Old Jay Ferrandini's team, made up of 5 pillars (SysOps, Labs, RCM, DevTools, AutomationQE).  This team handles hundreds of tools ranging from Jira & Bugzilla to platforms like CentralCI and UpShift. The SysOps pillar is most likely working on whatever is happening as they also maintain a huge pile of Jenkins boxes.  That team is lead by David Mair.
