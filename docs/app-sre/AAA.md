# 1. Anthology of App-SRE Axioms

Anthology: *a published collection of poems or other pieces of writing*
---
Axiom: *a statement or proposition which is regarded as being established, accepted, or self-evidently true.*
---

## 1.1. Index

<!-- TOC -->

- [1. Anthology of App-SRE Axioms](#1-anthology-of-app-sre-axioms)
    - [1.1. Index](#11-index)
    - [1.2. Preface](#12-preface)
    - [1.3. Changes](#13-changes)
    - [1.4. Other sources of documentation you might be looking for:](#14-other-sources-of-documentation-you-might-be-looking-for)
    - [1.5. Access and surfaces list](#15-access-and-surfaces-list)
        - [1.5.1. On call](#151-on-call)
            - [1.5.1.1. Pagerduty set up](#1511-pagerduty-set-up)
            - [1.5.1.2. Follow the sun](#1512-follow-the-sun)
            - [1.5.1.3. Primary on call](#1513-primary-on-call)
            - [1.5.1.4. Secondary on call](#1514-secondary-on-call)
            - [1.5.1.5. Escalation](#1515-escalation)
            - [1.5.1.6. Notification](#1516-notification)
            - [1.5.1.7. Incident procedure](#1517-incident-procedure)
            - [1.5.1.8. RCA](#1518-rca)
    - [1.6. Standard operating procedures](#16-standard-operating-procedures)
    - [1.7. App oboarding / app acceptance criteria](#17-app-oboarding--app-acceptance-criteria)
        - [1.7.1. In the app-interface](#171-in-the-app-interface)
    - [1.8. Git process](#18-git-process)
    - [1.9. App-sre escalation to external teams](#19-app-sre-escalation-to-external-teams)
    - [1.10. Escalation procedures](#110-escalation-procedures)
    - [1.11. Contacts](#111-contacts)
        - [1.11.1. Acknowledgements](#1111-acknowledgements)
    - [1.12. Services](#112-services)
- [2. Glossary](#2-glossary)
    - [PnT](#pnt)
    - [PnT Ops](#pnt-ops)
    - [PnT DevOps](#pnt-devops)

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

* The app-interface: https://gitlab.cee.redhat.com/service/app-interface
* The developers guide: https://gitlab.cee.redhat.com/service/dev-guidelines
* App-sre team drive: https://drive.google.com/drive/u/0/folders/0B9akCOYRTJW_TFAxOUtEaWtRZWs

## 1.5. Access and surfaces list

Every app-sre engineer should have access to the following

* Github / LDAP username
* https://password.corp.redhat.com/changepassword/

* Mattermost: chat.openshift.io
    * Channels: devtools-sd, devtools-servicedel

* Slack: coreos.slack.com
    * Channels sd-org, sd-osd-sre, 4-dev-triage, sd-app-sre

* Internal IRC (irc.devel.redhat.com):
    - #MIM: Major incident management
    - #aos: Openshift
    - #libra-ops: Openshift SD SRE-ops
    - #libra-noc: Openshift SD SRE

* Calendar:
    - SD-org calendar: https://calendar.google.com/calendar?cid=cmVkaGF0LmNvbV9hZzdoNG5kMnIydGlrM2dqZWxhaGRmbGhkOEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t
    - SD-org PTO / OOO: https://calendar.google.com/calendar?cid=cmVkaGF0LmNvbV8xN2piaHNtYmR2MTdhMTJhaHBvcDc5cWJ0a0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t

- Invite to sprint kickoffs, coordination sessions
- Install bluejeans client
- Mailing lists:
    - Many people just use the web email client, other thunderbird.
    - Recommended to sort into folders
    - https://post-office.corp.redhat.com/mailman/listinfo is the mailing list central
        - ACCESS: sd-app-sre -> speak to @jake or @paul
        - ACCESS: sd-org -> subscribe from UI
        - ACCESS: devtools-saas -> subscribe from UI
        - ACCESS: devtools-team -> subscribe from UI
        - ACCESS: outage-list -> subscribe from UI
        - ACCESS: aos-devel -> subscribe from UI

- Gitlab:
    - https://gitlab.cee.redhat.com/dtsd/
        - Housekeeping: Keeps all our bits and bobs, Ansible, terraform, python, scripts etc
        - ACCESS: App-sre DTSD -> Owner access
        - Issue tracker tracks incoming developers request
    - https://gitlab.cee.redhat.com/service/
        - ACCESS: app-interface - Master access
        - ACCESS: jjb - Master access
        - ACCESS: vault-devshift-net Master access

- GPG key:
    - Generate one and put in https://gitlab.cee.redhat.com/dtsd/housekeeping/tree/master/gpg/SD
    - Use a passphrase!

- Sd-org onboarding
    - ACCESS Contact Meghna Gala (mgala@redhat.com) re Sd-org onboarding
        - Added to sd-org mailing list
        - Added to team tracking sheets
    - ACCESS: Jira: https://coreos.jira.com -> email openshift-jira-admin@redhat.com

- Openshift github onboarding (access to private repositories in openshift github org):
    - ACCESS: https://mojo.redhat.com/docs/DOC-1081313#jive_content_id_Github_Access

- AWS
    - Access managed through terraform
    - Reach out to Serhii or Paul for accounts on:
        - ACCESS: OSIO AWS account # 386414299200
        - ACCESS: App-sre AWS account # 950916221866
    - Automated process pending

- Bugzilla
    - ACCESS: Ensure you have private access to bugzilla via https://maitai-bpms.engineering.redhat.com/
        - Login with kerberos credentials
        - Start a process -> Bugzilla account creation

- Zabbix: https://zabbix.devshift.net:9443/zabbix/zabbix.php?action=dashboard.view
    - ACCESS: Admin access, can be granted by any App-sre member

- Dedicated admin on openshift clusters
    - See app-interface/data/openshift/ - only applies to OSD clusters
    ACCESS: oc adm groups add-users dedicated-admins <USER> [<USER> ...]
    - Can be granted by any dedicated admin (oc get group dedicated-admins)

- Pagerduty
    ACCESS: Reach out to team lead and manager for PD access

- App-sre team drive
    ACESS: Reach out to pbergene@redhat.com for

- Bangalore (BLR) infrastructure
    - In BLR we have 4 nodes of RHEV infrastructure, this is further documented on the App-sre index (available to app-sre team members)
    - Access is managed adding ssh keys to ansible and users via the RHEV console
    - ACCESS:

- Raleigh (infrastructure)
    - In BLR we have 4 nodes of RHEV infrastructure, this is further documented on the App-sre index (available to app-sre team members)
-  Access is managed adding ssh keys to ansible and IPMI users

- OpenStack Project infrastructure
    - We have our ci-int infrastructure deployed here: https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project/
    - More info here: https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/openstack-ci-int.md

- Tier 1 Bastion access:
    - This is necessary to access some clusters that are not publicly exposed (for example hive-production)
    - Access process is documented here: https://mojo.redhat.com/docs/DOC-1144200
    - You should request Tier1

 ## Primary on-call + interrupt catching

  - include interrupt catching doc and on-call specifics

### 1.5.1. On call

The App-sre on call schedule is a rotation to ensure handling of service outages and incidents for our application owners.
Schedule of past, current and future on call rotation can be viewed @ pagerduty: https://openshift.pagerduty.com/

The on call includes three tiers of response, detailed below.

#### 1.5.1.1. Pagerduty set up

Ensure you are listed with the appropriate contact detail in your Pagerduty profile.
The recommended setup includes the pagerduty app on your mobile phone.  From the website you can test notifications to ensure that you have correctly set up the application to override any do not disturb settings.

For notification troubleshooting see: https://support.pagerduty.com/docs/notification-troubleshooting

#### 1.5.1.2. Follow the sun

#### 1.5.1.3. Primary on call

#### 1.5.1.4. Secondary on call

#### 1.5.1.5. Escalation

#### 1.5.1.6. Notification

#### 1.5.1.7. Incident procedure

- App-sre

#### 1.5.1.8. RCA

Root Cause Analysis must be published after incidents to ensure that corrective actions are followed up.  Any incidents in a sprint will be reviewed on the following sprint retro, with the exception.

The person who is the first responder or aknowledges the alert is responsible for

- Description
- Outage
- Timeline
- Corrective actions with references
- Location

Distribute to sd-org@ and app-interface serviceOwner in app.yml

## 1.6. Standard operating procedures

- SOPs related to engineering tasks are to be stored in the app-interface/docs/app-sre/docs folder.
- A SOP should have the following filename format: [CATEGORY]-[SHORT_DESCRIPTION].md
    - Where category is 'OSD', [servicename] or other relevant category
- A SOP should contain the following information:
    - Author
    - Date last modified
    - Access required
    - Detailed procedure

## 1.7. App oboarding / app acceptance criteria

### 1.7.1. In the app-interface

* Must contain the following fields
    * Service owner
    * Incident contact
    * Continuity plan reference

## 1.8. Git process

## 1.9. App-sre escalation to external teams

## 1.10. Escalation procedures

## 1.11. Contacts

- OSD SRE
    - #libra-ops on irc.devel.redhat.com - Shift lead and on-call listed in /topic
    - #sd-osd-sre on slack.coreos.org
    - Openshift SRE Servicenow direct form: https://url.corp.redhat.com/OpenShift-SRE-Service-Request-Form

- BLR infrastructure -> PnT Devops irc -> Mattermost: sureshn, snandago@redhat.com -> PnT Devops
- RDU infrastructure ->
- OpenStack project -> Pnt Devops https://mojo.redhat.com/docs/DOC-1049381

<!- ## 1.13. Query app-interface
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface-basic-auth-prod ->

### 1.11.1. Acknowledgements

## 1.12. Services

# 2. Glossary

## PnT

Products & Technolgies, essentially Paul Cormier’s entire 7000 person org.

## PnT Ops

Product & Technologies Business Operations lead by VP Katrinka McCallum (non-technical team).  This is where all the Program Managers and metrics people hangout.

## PnT DevOps

Old Jay Ferrandini's team, made up of 5 pillars (SysOps, Labs, RCM, DevTools, AutomationQE).  This team handles hundreds of tools ranging from Jira & Bugzilla to platforms like CentralCI and UpShift. The SysOps pillar is most likely working on whatever is happening as they also maintain a huge pile of Jenkins boxes.  That team is lead by David Mair.
