# 1. Anthology of App-SRE Axioms

Anthology: *a published collection of poems or other pieces of writing*
---
Axiom: *a statement or proposition which is regarded as being established, accepted, or self-evidently true.*
---

## 1.1. Index

<!-- TOC -->

- [1. Anthology of App-SRE Axioms](#1-anthology-of-app-sre-axioms)
  - [Anthology: *a published collection of poems or other pieces of writing*](#anthology-a-published-collection-of-poems-or-other-pieces-of-writing)
  - [Axiom: *a statement or proposition which is regarded as being established, accepted, or self-evidently true.*](#axiom-a-statement-or-proposition-which-is-regarded-as-being-established-accepted-or-self-evidently-true)
  - [1.1. Index](#11-index)
  - [1.2. Preface](#12-preface)
  - [1.3. Changes](#13-changes)
  - [1.4. Other sources of documentation you might be looking for:](#14-other-sources-of-documentation-you-might-be-looking-for)
  - [1.5. Access and surfaces list](#15-access-and-surfaces-list)
    - [1.5.1 Returning Red Hat Employee Gotchas](#151-returning-red-hat-employee-gotchas)
  - [1.6 On call](#16-on-call)
    - [1.6.1 Primary on-call + interrupt catching](#161-primary-on-call--interrupt-catching)
    - [1.6.2. Pagerduty set up](#162-pagerduty-set-up)
    - [1.6.3. Follow the sun](#163-follow-the-sun)
    - [1.6.4. Primary on-call](#164-primary-on-call)
    - [1.6.5. Secondary on-call](#165-secondary-on-call)
    - [1.5.6. Escalation](#156-escalation)
    - [1.6.7. Notification](#167-notification)
    - [1.6.8. Incident procedure](#168-incident-procedure)
  - [1.7. Standard operating procedures](#17-standard-operating-procedures)
  - [1.8. App oboarding / app acceptance criteria](#18-app-oboarding--app-acceptance-criteria)
    - [1.8.1. In the app-interface](#181-in-the-app-interface)
  - [1.9. Additional team process](#19-additional-team-process)
    - [1.9.1 Git Process](#19-git-process)
    - [1.9.2 Sprint Process](#19-sprint-process)
  - [1.10. App-sre escalation to external teams](#110-app-sre-escalation-to-external-teams)
    - [1.10.1 PnT Devops](#1101-pnt-devops)
  - [1.11. Escalation procedures](#111-escalation-procedures)
  - [1.12. Contacts](#112-contacts)
    - [1.12.1. Acknowledgements](#1121-acknowledgements)
  - [1.13. Services](#113-services)
- [2. Glossary](#2-glossary)
  - [2.1. PnT](#21-pnt)
  - [2.2. PnT Ops](#22-pnt-ops)
  - [2.3. PnT DevOps](#23-pnt-devops)

<!-- /TOC -->

## 1.2. Preface

This documents is for App-sre engineer consumption and aims to ensure agreement around and govern the App-sre continuity and readiness plan.
It serves as the top node and authorative source for documentation around App-sre process.

The document itself consists of two main sections, the first details prerequisites and process pieces that every App-sre engineer needs to have in place.  This serves as a checklist for access and details contact points on how to aquire any lacking access.

The second section consists of operational procedures and documentation that serves as references during incident work.

Information within this document aims to be he authorative source for process and (until further notice) contacts.  For details on the specifics of the operational environment the app-interface supercedes this document - hence this should be viewed as complementary and authorative only concerning process.  Content in this document should aim to reference the app-interface schemas as opposed to duplicating it, where possible.

Additionally there is a contact section near the end which details the escalations and contact for external groups and dependencies.
The goal is to move this to the app-interface itself as it matures.

## 1.3. Changes

- This document was created and maintained using vscode, using Markdown ToC plugin
- Merge requests are accepted but require team lead signoff
- As it is important to communicate and gain common aknowledgement of process captured within, this document will be reviewed every sprint retro when there are changes.  If you can not attend a sprint retro, make sure you review this document before going on call.
- Prior to each

## 1.4. Other sources of documentation you might be looking for:

- The app-interface: https://gitlab.cee.redhat.com/service/app-interface
- The developers guide: https://gitlab.cee.redhat.com/service/dev-guidelines
- App-sre team drive: https://drive.google.com/drive/u/0/folders/0B9akCOYRTJW_TFAxOUtEaWtRZWs

## 1.5. Access and surfaces list

Every app-sre engineer should have access to the following

- Github / LDAP username
  - If needed can reset KRB password [here](https://password.corp.redhat.com/changepassword)
  - Verify inclusion in all github orgs listed [here](https://visual-app-interface.devshift.net/githuborgs)

- Gitlab:
  - https://gitlab.cee.redhat.com/service/app-interface
    - create a user file under the [app-sre team](/data/teams/app-sre/users) directory via a merge request off a fork of app-interface
      - Pro tip: Copy the user file of the newest team member
  - https://gitlab.cee.redhat.com/dtsd/housekeeping
    - Keeps all our bits and bobs, Ansible, terraform, python, scripts etc
    - Issue tracker tracks incoming interrupt catching requests
  - https://gitlab.cee.redhat.com/app-sre
    - Access to all repositories is managed via this group
    - Obtained via a [role](/data/teams/app-sre/roles/app-sre-gitlab-member.yml)

- Slack: coreos.slack.com
  - Private channels: sd-app-sre-teamchat -> speak to any team member to get an invitation
  - User groups: @app-sre-team -> obtained via a [role](/data/teams/app-sre/roles/app-sre-slack.yml)
  - Channels: as stated [here](/data/teams/app-sre/permissions/app-sre-team-coreos-slack.yml) -> obtained via the @app-sre-team user group membership

- Internal IRC (irc.devel.redhat.com):
  - #MIM: Major incident management
  - #aos: Openshift
  - #libra-ops: Openshift SD SRE-ops
  - #libra-noc: Openshift SD SRE

- Calendar:

  - [SD-org calendar](https://calendar.google.com/calendar?cid=cmVkaGF0LmNvbV9hZzdoNG5kMnIydGlrM2dqZWxhaGRmbGhkOEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t)
  - [SD-org PTO / OOO](https://calendar.google.com/calendar?cid=cmVkaGF0LmNvbV8xN2piaHNtYmR2MTdhMTJhaHBvcDc5cWJ0a0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t)

- BlueJeans:

  - Install bluejeans client
  - App SRE bridge: https://bluejeans.com/994349364/8531

- Invite to sprint kickoffs, coordination sessions
- Mailing lists:
  - Many people just use the web email client, other thunderbird.
  - Recommended to sort into folders
  - https://post-office.corp.redhat.com/mailman/listinfo is the mailing list central
    - ACCESS: sd-app-sre -> speak to @jake, @jonathan beakley or @paul on slack
    - ACCESS: sd-org -> subscribe from UI
    - ACCESS: sd-sre -> subscribe from UI 
    - ACCESS: sres -> subscribe from UI
    - ACCESS: devtools-saas -> subscribe from UI
    - ACCESS: devtools-team -> subscribe from UI
    - ACCESS: outage-list -> subscribe from UI
    - ACCESS: aos-devel -> subscribe from UI
    - ACCESS: it-iam-announce-list -> subscribe from UI

- GPG key:
  - Generate one and put in:
    - ascii armored in [housekeeping repo](https://gitlab.cee.redhat.com/dtsd/housekeeping/tree/master/gpg/SD)
    - base64 encoded binary in your app-interface user file -> [instructions](/README#adding-your-public-gpg-key)
      - User file located in [app-interface repo](/data/teams/app-sre/users)
  - Use a passphrase!
  - External reference for [generating](https://www.gnupg.org/gph/en/manual/c14.html) and [exporting](https://www.gnupg.org/gph/en/manual/x56.html)

- Sd-org onboarding
  - ACCESS Contact Meghna Gala (mgala@redhat.com) re Sd-org onboarding (may not be needed)
    - Added to sd-org mailing list
    - Added to team tracking sheets (?)
  - ACCESS: [Jira](https://jira.coreos.com)
    - Email openshift-jira-admin@redhat.com for any issues
    - Jira boards [Incidents Board](https://jira.coreos.com/secure/RapidBoard.jspa?rapidView=92&projectKey=HSD) & [SD Epics](https://jira.coreos.com/secure/RapidBoard.jspa?rapidView=140)

- Openshift github onboarding (access to private repositories in openshift github org):
  - ACCESS: https://mojo.redhat.com/docs/DOC-1081313#jive_content_id_Github_Access
  - Submit PRs to be added to OWNERS once access is granted:
    - https://github.com/openshift/telemeter/blob/master/OWNERS
    - https://github.com/openshift/cincinnati/blob/master/OWNERS_ALIASES
  - e-mail Jake Moshenko or ping on slack for access to quay github group

- AWS
  - Nothing to do. Access obtained via a [role](/data/teams/app-sre/roles/sre-aws.yml)

- Vault
  - Access obtained via a [role](/data/teams/app-sre/roles/sre.yml)
    - [setup instructions](https://gitlab.cee.redhat.com/service/dev-guidelines/blob/master/vault.md)

- Quay
  - Login to/Create account at https://quay.io
    - Can use github account for simplicity
  - Access obtained via a [role](/data/teams/app-sre/roles/sre.yml)
  - Create `quay_username` in the [user file](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/teams/app-sre/users) and populate with quay user

- Bugzilla
  - ACCESS: Ensure you have access to [bugzilla](https://bugzilla.redhat.com)
    - Login as Red Hat Associate with kerberos credentials
  - Verify you have permissions to view private and private_comment.  This should be provided as part of the redhat group.  See [here](https://mojo.redhat.com/docs/DOC-1197751) for group information.

- Zabbix (Being deprecated by 31 Dec 2019):
  - ACCESS: Ask an app-sre member to create an account with Admin access
  - Once account is created login [here](https://zabbix.devshift.net:9443/zabbix/zabbix.php?action=dashboard.view)

- Dedicated admin on openshift clusters
  - Nothing to do. Obtained via a [role](data/teams/app-sre/roles/app-sre-dedicated-admins.yml)

- Pagerduty
  - ACCESS: Create a [SNOW ticket](https://redhat.service-now.com) to request access to PagerDuty and then reach out to [Bill Montgomery](mailto:bmontgom@redhat.com) with the ticket number

- App-sre shared folder
  - ACCESS: Reach out to [Paul Bargene](mailto:pbergene@redhat.com)

- App SRE infrastructure managed by ansible
  - Access is managed by adding ssh keys to the [admin-list](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/ansible/hosts/group_vars/all#L4) and applying the `baseline` role to all hosts.

- OpenStack Project infrastructure
  - We have our ci-int infrastructure deployed [here](https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project)
    - Domain: redhat.com
    - Kerberos login and password
  - Detailed info [here](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/openstack-ci-int.md)

- Tier 1 Bastion access:
  - This is necessary to access some clusters that are not publicly exposed (for example hive-production)
  - Access process is documented [here](https://mojo.redhat.com/docs/DOC-1144200)
    - You should request Tier1

### 1.5.1 Returning Red Hat Employee Gotchas

- Accounts need to be re-enabled
  - Bugzilla
    - Send e-mail to bugzilla-owner@redhat.com or create ticket at the [Help Portal](https://help.redhat.com/)
    - It is likely the re-activated account will not have the needed permissions.  Request access to the devel group by following the directions [here](https://mojo.redhat.com/docs/DOC-1197751)
  - Bluejeans
    - Create an IT ticket

## 1.6 On call

The App-sre on call schedule is a rotation to ensure handling of service outages and incidents for our application owners.
Schedule of past, current and future on call rotation can be viewed @ pagerduty: https://redhat.pagerduty.com/

The on call includes three tiers of response, detailed below.

### 1.6.1 Primary on-call + interrupt catching

- Interrupt catching is detailed in this [document](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/interrupt-catching.md)
  - include on-call specifics

### 1.6.2. Pagerduty set up

Ensure you are listed with the appropriate contact detail in your Pagerduty profile.
The recommended setup includes the pagerduty app on your mobile phone.  From the website you can test notifications to ensure that you have correctly set up the application to override any do not disturb settings.

For notification troubleshooting see: https://support.pagerduty.com/docs/notification-troubleshooting

### 1.6.3. Follow the sun

The follow the sun cycle (FTS) is an on-call rotation to ensure that the first page triggered by an alert goes to an engineer who, at the time, is within regular working hours. This is to prevent direct pages to the primary on-call within the regular hours of others. If there is no engineer available within their regular hours the page will go directly to the primary on-call.

### 1.6.4. Primary on-call

The primary on-call is a 24/7 on-call rotation assigned on a weekly basis.  The engineer assigned is required to be available for the initial response within 30 minutes of the page.

Pages for primary on-calls should be be kept at a minimum and are reserved for critical issues in production environments which need immediate attention.

The primary on-call also acts as the interrupt-catcher during their work hours that cycle.

### 1.6.5. Secondary on-call

The secondary on-call is a 24/7 on-call rotation that serves as backup and support function for the primary on-call. The secondary on-call will be paged if the primary on-call does not aknowledge the incident via Pagerduty (via app, slack integration or other means).

### 1.5.6. Escalation

### 1.6.7. Notification

### 1.6.8. Incident procedure

What constitutes an incident:

If any of the following is true, the event is an incident:

- Is the outage visible to customers (internal or external)?
- Do you need to involve a second team in fixing the problem?
- Does the outage result in breach of Service SLO's?

Incident Response:

Tracking:

- Start off by creating a JIRA issue for the incident on the [incidents board](https://jira.coreos.com/secure/RapidBoard.jspa?rapidView=145)
  - Issue type: `Task`
  - Labels: `type/incident`

- Create a Google doc for live incident status and RCA:
  - Clone the [incident RCA template](https://docs.google.com/document/d/12ZVT35yApp7D-uT4p29cEhS9mpzin4Z-Ufh9eOiiaKU/edit)
  - Add Incident title and JIRA link
  - Post the doc link back into the JIRA ticket
  - Guidelines on how to write the incident report are available in the [Google Doc](https://docs.google.com/document/d/165eDunz6yy9uIi2XXxWaEpODCVFp9tYhnBF607qVexg/edit)

Initiate incident communications:

> It is crucial to involve all the stakeholders on the initial email communications. When in doubt, include a wider audience rather than a narrow list

- Send an email to the service owners and in case of major outage, send an email to the sd-org@redhat.com mailing list

Please use the following Email template for consistency:

Subject: `<YYYY-MM-DD> Incident: <ServiceName> <Optional highlights>`

Body:

```text

Hello team,

We are investigating an ongoing incident affecting <ServiceName>.

Impacted users: <Internal/External>

App-SRE tracking JIRA: <Link for JIRA ticket created above>

A live RCA is available at: <Google Doc link>

We will provide updates via this email thread as the incident progresses.

```

During the incident:


- Join the [App-SRE Bluejeans Bridge](https://bluejeans.com/994349364/8531)
  - If the incident investigation needs assistance from the developer teams, also send them the link and ask to join in



Post incident comms, followups:

- After the incident has been confirmed as resolved, send an email to the original mail thread with the content:

```text
This incident has now been resolved and the service functionality has been restored. We will send out a detailed RCA once we've finished the post-incident documentation.
```

- Create issues from the action items on the respective team JIRA boards, link them back to the incident tracker
- Send a PDF snapshot of the completed RCA to the mail thread


## 1.7. Standard operating procedures

- SOPs related to engineering tasks are to be stored in the app-interface/docs/app-sre/docs folder.
- A SOP should have the following filename format: [CATEGORY]-[SHORT_DESCRIPTION].md
    - Where category is 'OSD', [servicename] or other relevant category
- A SOP should contain the following information:
    - Author
    - Date last modified
    - Access required
    - Detailed procedure

## 1.8. App oboarding / app acceptance criteria

### 1.8.1. In the app-interface

* Must contain the following fields
    * Service owner
    * Incident contact
    * Continuity plan reference

## 1.9. Additional team process

### 1.9.1 Git process

### 1.9.2 Sprint process
* [see process/sprint.md](process/sprint.md)

## 1.10. App-sre escalation to external teams

### 1.10.1 PnT Devops

* [PnT DevOps - Issue Escalation Procedure](https://mojo.redhat.com/docs/DOC-1049381) - Mojo

1. Create a case: https://redhat.service-now.com/help?id=sc_cat_item&sys_id=b86bfc10133ce200dce03ff18144b028

    1.1 For CEE GitLab:

        * Category: `Application`

        * Item: `Gerrit/Git`

        * Hostname Affected: `https://gitlab.cee.redhat.com`

    1.2 For CentralCI Jenkins:

        * Category: `Virtualization/Cloud`

        * Item: `CI-RHOS`

        * Hostname Affected: `https://ci-int-jenkins.rhev-ci-vms.eng.rdu2.redhat.com`

2. If this is a weekend (Saturday / Sunday), find the `PNQ On Call` from the [SysOps On Call calendar](https://calendar.google.com/calendar?cid=cmVkaGF0LmNvbV84ajE4YzFkOTFkZHFkYXQ4bDlxdDk0djFoY0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t).

3. Ping the On Call in #ops-escalation in the Red Hat Internal IRC Server - irc.devel.redhat.com.

## 1.11. Escalation procedures

## 1.12. Contacts

- OSD SRE
    - #libra-ops on irc.devel.redhat.com - Shift lead and on-call listed in /topic
    - #sd-osd-sre on slack.coreos.org
    - Openshift SRE Servicenow direct form: https://url.corp.redhat.com/OpenShift-SRE-Service-Request-Form

- BLR infrastructure -> PnT Devops irc -> Mattermost: sureshn, snandago@redhat.com -> PnT Devops
- RDU infrastructure ->
- OpenStack project -> Pnt Devops https://mojo.redhat.com/docs/DOC-1049381

<!- ## 1.13. Query app-interface
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface-basic-auth-prod ->

### 1.12.1. Acknowledgements

## 1.13. Services

# 2. Glossary

## 2.1. PnT

Products & Technolgies, essentially Paul Cormier’s entire 7000 person org.

## 2.2. PnT Ops

Product & Technologies Business Operations lead by VP Katrinka McCallum (non-technical team).  This is where all the Program Managers and metrics people hangout.

## 2.3. PnT DevOps

Old Jay Ferrandini's team, made up of 5 pillars (SysOps, Labs, RCM, DevTools, AutomationQE).  This team handles hundreds of tools ranging from Jira & Bugzilla to platforms like CentralCI and UpShift. The SysOps pillar is most likely working on whatever is happening as they also maintain a huge pile of Jenkins boxes.  That team is lead by David Mair.
