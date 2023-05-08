# Anthology of AppSRE Axioms

* Anthology: *a published collection of poems or other pieces of writing*
* Axiom: *a statement or proposition which is regarded as being established, accepted, or self-evidently true.*

## Index

<!-- TOC -->

- [Anthology of AppSRE Axioms](#anthology-of-appsre-axioms)
    - [Index](#index)
    - [Preface](#preface)
    - [Complementary Documentation and Resources](#complementary-documentation-and-resources)
    - [AppSRE Engineer Onboarding](#appsre-engineer-onboarding)
        - [Laptop security](#laptop-security)
        - [Registering the user in App-Interface](#registering-the-user-in-app-interface)
        - [Access and Surfaces list](#access-and-surfaces-list)
            - [Returning Red Hat Employee Gotchas](#returning-red-hat-employee-gotchas)
            - [Maintaining access pieces](#maintaining-access-pieces)
        - [Knowledge Sharing and Training](#knowledge-sharing-and-training)
            - [Introduction](#introduction)
            - [Training Resources](#training-resources)
            - [Deep Dive sessions](#deep-dive-sessions)
            - [Practical Training Syllabus](#practical-training-syllabus)
    - [On call](#on-call)
    - [Incident Process](#incident-process)
        - [Generic Resources](#generic-resources)
    - [Contract](#contract)
        - [SRE Checkpoints](#sre-checkpoints)

<!-- /TOC -->

## Preface

This document is for AppSRE engineer consumption.

It aims to ensure agreement and govern the AppSRE continuity and readiness plan.
Information within this document aims to be the authoritative source for access,
surfaces and processes, including incident management.

## Complementary Documentation and Resources

* [AppSRE Resources](https://source.redhat.com/groups/public/sre-services/sre_services_wiki/appsre_introduction)
* [App-Interface](https://gitlab.cee.redhat.com/service/app-interface)
* [AppSRE Contract](https://gitlab.cee.redhat.com/app-sre/contract)
* [Developer's Guide](https://service.pages.redhat.com/dev-guidelines/)
* [Site Reliability Engineering / AppSRE shared
  drive](https://drive.google.com/drive/folders/0AIimM0HiftflUk9PVA) (shared with Site Reliability Engineering)
* [AppSRE Team Drive](https://drive.google.com/drive/folders/1FkGuqIWdY0XLgIfUGIdpckhF-cDsVF_u) (viewable and editable by AppSRE members only)

## AppSRE Engineer Onboarding

### Laptop security

You have a new, shiny laptop. Now, make sure you comply with [the laptop security guidelines](https://source.redhat.com/departments/it/it-information-security/wiki/laptop_security).

### Declare your GitHub repositories in Rover

Ideally, you'd declare your **professional** social media in your
[Rover profile](https://rover.redhat.com/people/profile/). At the very
least, we want you to declare your GitHub account there so that
InfoSec can [scan for any key
leaks](https://source.redhat.com/departments/it/it-information-security/wiki/details_about_rover_github_information_security_and_scanning#how-can-i-tell-the-scanner-to-allow-certain-things-in-my-repo-)
on your **public** repositories.

### Registering the user in App-Interface

Most of the resources required as an AppSRE will be obtained via a user definition with AppSRE-specific roles in App-Interface.

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

### Preventing key leaks

This is **VERY** important since key leaks happen and they are very expensive both cloud resources and in engineer to fix them. Please follow this [guide](https://gitlab.corp.redhat.com/infosec-public/developer-workbench/tools/-/tree/main/rh-pre-commit) to install a pre-commit hook that will prevent you from committing any change that can expose a key.

### Access and Surfaces list

Every AppSRE/MT-SRE engineer should have access to the following:

* LDAP
  * If needed can reset Kerberos password
    [here](https://password.corp.redhat.com/changepassword).
  * https://gitlab.cee.redhat.com/app-sre/infra: keeps our Ansible and Terraform bits and bobs.
* Slack: redhat-internal.slack.com
  * To gain access to redhat-internal.slack.com, follow the instructions [here](https://source.redhat.com/groups/public/atomicopenshift/atomicopenshift_wiki/openshift_slack#jive_content_id_Quickstart).
  * #sd-app-sre-teamchat (private channel): speak to any team member to get an
    invitation.
  * User groups: @app-sre-team: obtained via this
    [permission](/data/teams/app-sre/permissions/app-sre-team-coreos-slack.yml).
* Internal IRC (irc.devel.redhat.com):
  * **#appsre**: backup channel if Slack is down or if sensitive content must be addressed.
  * **#servicedelivery**: backup channel for service delivery org if Slack is down.
  * **#mim**: Major incident management (MIM).
  * **#aos**: OpenShift channel.
* Calendar:
  * [AppSRE calendar](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV9iZ2VzaW1tYThyMTdndHJ2amxkaXU5Ym9ub0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    AppSRE engineers are encouraged to create all meetings in this calendar for team awareness.
  * [SD-org PTO / OOO](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV8xN2piaHNtYmR2MTdhMTJhaHBvcDc5cWJ0a0Bncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    Any PTO must be reported here.
  * [SD-org calendar](https://calendar.google.com/calendar/u/0?cid=cmVkaGF0LmNvbV9hZzdoNG5kMnIydGlrM2dqZWxhaGRmbGhkOEBncm91cC5jYWxlbmRhci5nb29nbGUuY29t):
    AppSRE doesn't use this calendar usually.
* Google Meet:
  * AppSRE bridge: https://meet.google.com/zti-gkvy-pvn. We refer to this room as [ZTI](https://meet.google.com/zti-gkvy-pvn).
* BlueJeans
  * To be used only if Google Meet is not available.
  * (Optional) Install BlueJeans client.
  * AppSRE bridge: https://bluejeans.com/994349364/8531
* Mailing lists:
  * http://groups.google.com/: new mailing list manager
    * [sd-app-sre-announce](https://groups.google.com/u/0/a/redhat.com/g/sd-app-sre-announce)
    * [outage-list](https://groups.google.com/a/redhat.com/g/outage-list/about)
  * https://post-office.corp.redhat.com/mailman/listinfo: old mailing list central
    * ACCESS: sd-app-sre. Speak to @jonathan beakley.
    * ACCESS: sd-notifications. Subscribe from UI.
    * ACCESS: sd-org. Subscribe from UI.
    * ACCESS: sres. Subscribe from UI.
    * ACCESS: it-iam-announce-list. Subscribe from UI.
    * ACCESS: it-user-announce-list (useful for SSO). Subscribe from UI.
  * Optional - Additional information surfaces, subscription not mandatory
    * ACCESS: aos-devel: very high volume (useful to get the latest news about OpenShift development). Subscribe from UI.
* Sd-org onboarding
  * ACCESS Contact Meghna Gala (mgala@redhat.com) regarding sd-org onboarding (may not be needed)
    * Added to sd-org mailing list
  * ACCESS: [Jira](https://issues.redhat.com)
    * Email openshift-jira-admin@redhat.com for any issues
    * Jira boards [Sprint Board](https://issues.redhat.com/secure/RapidBoard.jspa?rapidView=5536) & [SD Epics](https://issues.redhat.com/projects/SDE)
* github.com/openshift
  * ACCESS: [here](https://source.redhat.com/groups/public/atomicopenshift/atomicopenshift_wiki/openshift_onboarding_checklist_for_github)
* Bugzilla
  * ACCESS: Ensure you have access to [Bugzilla](https://bugzilla.redhat.com)
    * Login as Red Hat Associate with Kerberos credentials
  * Verify you have permission to view private and private_comment. This should be provided as part of the Red Hat group. See [here](https://docs.engineering.redhat.com/pages/viewpage.action?spaceKey=OMEGA&title=Group+Membership+Policy) for group information.
* PagerDuty
  * Open a Service-Now (also known as "SNOW") ticket requesting PagerDuty account creation and access using [this](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=ed13c6af1b2a2c50e43942a7bc4bcbc3) form.
  * Feel free to add your Manager to the list of additional contacts so that they can also receive status updates.
  * Ensure that your contact details and time zone are set up correctly.
  * The recommended setup includes the PagerDuty application on your mobile phone. From the website, you can test notifications to ensure that you have correctly set up the application to override any do not disturb settings.
  * For notifications troubleshooting see [here](https://support.pagerduty.com/docs/notification-troubleshooting).
* AppSRE shared folders
  * ACCESS: Make sure that you have access to the above Google Drive folders.
* Vault
  * Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
    * [setup instructions](https://service.pages.redhat.com/dev-guidelines/docs/appsre/onboarding/adding-sensitive-data/#getting-access-to-vault)
* Quay
  * Login to/Create an account at https://quay.io
    * Attach with Red Hat SSO.
  * Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  * Add `quay_username` in the [user file](https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/teams/app-sre/users) and populate with quay user.
* SSH access to Jenkins-related instances
  * Via MR to [app-sre/infra repo](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/group_vars/all)
    * Add username and public part of your SSH key like [here](https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/144)
* CLI installs
  * Ansible
    * You can install it directly on your local machine or in a virtual environment (recommended)
      * To install locally:
        * (MacOS) `brew install ansible`
        * (Fedora/RHEL) `dnf install ansible-core`
      * To install in a virtual environment:
        * Set up pyenv
        * Activate the virtual environment and install Ansible with `pip install ansible`
        * For this setup, I currently have `python version 3.9.12`, `ansible version 2.9.27`, `jinja2 version 3.0.3`, and `hvac version 0.10.0`
          * NOTE: The versions are very finicky, so it may take some trial and error
    * Ensure you have your SSH hosts file configured correctly because the ansible-playbook command assumes you do otherwise, it will throw an SSH error
  * Terraform
    * To install, go to the [vendor's download site](https://releases.hashicorp.com/terraform/) to find the version you need.
    * Ensure you have the correct terraform version on your laptop by looking at what [cli.py shows in qontract-reconcile for environment variable TERRAFORM_VERSION](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/cli.py)
  * AWS
    * Following the installation steps [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    * Since enforcing MFA, you will need to follow [these steps](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/) in order to use the CLI.
      * Please note that this will only work for virtual devices.
  * Python
    * (MacOS) To install: `brew install python`
    * (Fedora/RHEL) should be pre-installed
    * Because we now require MFA, in order to login, you will have to do the following:
  * Alternatively, use pyenv to manage your versions of Python
    * (MacOS) To install: `brew install pyenv`
    * (Fedora/RHEL) Check out [pyenv-installer](https://github.com/pyenv/pyenv-installer)
  * OpenShift Client (oc)
    * Check out [this download page](https://access.redhat.com/downloads/content/290) or, alternatively [this mirror](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/).
    * Instructions for installing are [here](https://docs.openshift.com/container-platform/4.10/cli_reference/openshift_cli/getting-started-cli.html).
    * qontract-reconcile uses a specific version of the oc binary [referenced in cli.py](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/cli.py#L136)

Every AppSRE engineer should have access to the following:

* GitHub
  * GitHub profile must include `Company: Red Hat`.
  * Verify inclusion in the [app-sre](https://github.com/app-sre) GitHub organization.
* Gitlab:
  * https://gitlab.cee.redhat.com/app-sre
    * Access to all repositories is managed via this group.
    * Obtained via this [role](/data/teams/app-sre/roles/app-sre.yml).
  * https://gitlab.cee.redhat.com/service/app-interface (See general [workflow](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/#workflow) to create a merge request)
* AppSRE OCM org (https://console.redhat.com/openshift)
  * Access is [configured manually by an org administrator](/docs/app-sre/sop/ocm-appsre-org-access.md)
* AWS
  * Nothing to do. Access obtained via a [role](/data/teams/app-sre/roles/app-sre.yml)
  * Make sure you enable MFA in **all** your AWS accounts.
* AppSRE infrastructure managed by Ansible
  * Access is managed by adding SSH keys to the [admin-list](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/hosts/group_vars/all#L4) and applying the `baseline` role to all hosts. It is recommended that SSH key is RSA, 4096-sized and password-protected, as those are the [requirements for Tier 1 Bastion keys](https://source.redhat.com/groups/public/openshiftplatformsre/wiki/faq_openshift_tiered_access_overview_for_osd3#jive_content_id_Tier_1)
* OpenStack Project infrastructure
  * We have our ci-int infrastructure deployed [here](https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project)
    * Domain: redhat.com
    * Kerberos login and password
  * Detailed info [here](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/openstack-ci-int.md)
* Tier 1 Bastion access for OSD3 (optional - mostly not needed):
  * This is necessary to access some clusters that are not publicly exposed (for example, Hive shards still in OSDv3)
  * Access process is documented [here](https://source.redhat.com/groups/public/openshiftplatformsre/wiki/faq_openshift_tiered_access_overview_for_osd3)
    * You should request Tier1
* Pendo:
  * This is necessary to post maintenance and outage messages in https://console.redhat.com/openshift
  * Access is provided via e-mail to Jacquelene Booker <jbooker@redhat.com>.
  * [Logging](https://app.pendo.io/login) in is done using the full Red Hat e-mail.
  * Required permissions at the time of writing are:
    * Analyst
    * Guide Publisher
    * Guide Creator
    * Guide Content Editor
    * Viewer
* Unleash:
  * Feature toggle service to enable/disable features in runtime.
  * AppSRE unleash instance is here: https://app-interface.unleash.devshift.net/
  * More details are available [here](https://gitlab.cee.redhat.com/service/dev-guidelines/blob/master/unleash.md)
* SendGrid
  * Nothing to do, granted by `sendgrid_accounts` in the [AppSRE role](data/teams/app-sre/roles/app-sre.yml).
* Deadman's snitch
  * Ask somebody in the team to invite you to the organization. You'll receive an e-mail with a link to the invite. Create a new account then it will be added automatically to the organization, and you'll see all the heartbeats we have configured. You'll also be able to create even more.
* AppSRE [kube-configs](https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs/)

#### Returning Red Hat Employee Gotchas

* Accounts need to be re-enabled
  * Bugzilla
    * Send e-mail to bugzilla-owner@redhat.com or create a ticket at the [Help Portal](https://help.redhat.com/)
    * It is likely the re-activated account will not have the needed
      permissions. Request access to the devel group by following the directions
      [here](https://docs.engineering.redhat.com/display/OMEGA/Group+Membership+Policy)
  * BlueJeans
    * Create an IT ticket

#### Maintaining access pieces

Access pieces are a very quickly moving target, and they change very frequently. In order to maintain an accurate list of access pieces, these actions must be followed by each AppSRE team member:

* All access pieces are documented in the [Access and surfaces list](#access-and-surfaces-list) section.
* If an AppSRE team member gains access to something and it's not linked from in this list, it's their responsibility to add it there.
* This list is actively reviewed by onboarding AppSRE members.

### Knowledge Sharing and Training

This section documents the specific processes related to knowledge sharing by
the AppSRE team in order to maintain a high level of accuracy and coverage of
all the knowledge within AppSRE.

#### Introduction

The purpose of this section is to document how knowledge is shared by the
AppSRE, both internally and externally.

Before diving into specific processes, it is important to state that the team
has a very clear mission with regard to knowledge sharing:

* There are no single owners or SMEs for any of the components and processes
  owned or implemented by the AppSRE team.
* It is the responsibility of every AppSRE member to make sure no knowledge is
  in a silo and to share any new knowledge piece with the rest of the team using
  the implemented processes and channels.
* Each AppSRE member has the right to raise any concerns about any knowledge
  gaps, and the team will prioritize filling in those gaps.

#### Training Resources

The AppSRE team will maintain an index of training resources. All AppSRE members must go through [those training documents](https://source.redhat.com/groups/public/sre-services/sre_services_wiki/appsre_introduction#jive_content_id_AppSRE_Training).

#### Deep Dive sessions

On a periodical basis, the AppSRE team will hold "Deep Dive sessions". These sessions have the following characteristics:

* The main goal is to share knowledge within the AppSRE team.
* Periodicity: every 6 weeks.
* 1h sessions.
* Presentations should have an accompanying slide deck and must be well-prepared.
* Any topics that are directly related to the AppSRE day-to-day will be prioritized over general knowledge ones.
* Attendance from all the team members is strongly encouraged, as well as participation and making the session dynamic.

Those sessions are tracked in this document: [AppSRE Deep Dives](https://docs.google.com/document/d/1T4QNO2qQYpBl4uhiNdr2iP7LO1pfmCVkzyWHgHDIIJA/edit).

Every AppSRE member that identifies any knowledge gaps in our documentation / resources has the responsibility of adding new proposals to the Deep Dives list of proposals.

#### Practical training Syllabus

Or: How to become a contributing AppSRE team member

This section guides a new team member in carrying out tasks that are:

- beneficial for the new team member
- beneficial for the team

As long as we can find tasks that match the learning criteria, we'll prefer to do them over doing an exercise task.

The assumption behind the structure of the syllabus is that there is a limited amount of information that is understood in every task, especially during the first period with the team. To have an experience in which the team member gets as much out of every task, we will want to make each task as narrow as possible. Following tasks will assume the knowledge from previous tasks and expand around it. This essentially means that we are doing more [DFS than BFS](https://www.geeksforgeeks.org/difference-between-bfs-and-dfs).

Since every project, small or large, goes through app-interface in some way, the first few tasks will focus on day-to-day activities in app-interface, such as CI/CD and integrations. With this knowledge gained very early in the on-boarding process of a new team member, many requests in #sd-app-sre will already be understandable.

A big part of being an SRE is to work through toil items. We want to encourage new team members to contribute to refactors, cleanups, and any other toil item. We want to encourage everyone to do that! chop wood, carry water.

Practical training is really a fancy name for working on tickets. Tickets to get started with are usually labelled as a `good-first-issue`, and some will contain an additional label `ai#n` to indicate the difficulty level:

[AI #1](https://issues.redhat.com/issues/?jql=project%20%3D%20APPSRE%20AND%20status%20%3D%20%22To%20Do%22%20AND%20labels%20%3D%20%22ai%231%22)
[AI #2](https://issues.redhat.com/issues/?jql=project%20%3D%20APPSRE%20AND%20status%20%3D%20%22To%20Do%22%20AND%20labels%20%3D%20%22ai%232%22)
[AI #3](https://issues.redhat.com/issues/?jql=project%20%3D%20APPSRE%20AND%20status%20%3D%20%22To%20Do%22%20AND%20labels%20%3D%20%22ai%233%22)
[AI #4](https://issues.redhat.com/issues/?jql=project%20%3D%20APPSRE%20AND%20status%20%3D%20%22To%20Do%22%20AND%20labels%20%3D%20%22ai%234%22)

Some of these tickets may be related to qontract-reconcile, which will require a [development environment setup](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/app-sre/sop/app-interface-development-environment-setup.md).

## On call

Documented in the [On Call rotation](./on-call.md) SOP.

## Incident Process

All AppSRE team members will follow the Incident Process as accurately as possible, raise any concerns and keep it up to date.

Documented in the [Incident Process](./incident-process.md) SOP.

### Generic Resources

* [PnT DevOps - Issue Escalation Procedure](https://docs.engineering.redhat.com/pages/viewpage.action?pageId=140541042)
* [Red Hat Major Incident Management (MIM)](https://source.redhat.com/groups/public/it-major-incident-management)
* [IT ISO (IT Operations)](https://source.redhat.com/groups/public/iso/it_operations_iso_wiki/welcome_to_it_iso_it_operations)
* PnT-Infra-Escalation google chat group to escalate issues regarding OpenStack, OCP, etc...
* [People Index for PnT-EXD](https://docs.engineering.redhat.com/pages/viewpage.action?spaceKey=EXDINFRA&title=EXD+Infrastructure+People+Index)

## Contract

AppSRE establishes a contract with the tenants. The contract is live [here](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/README.md).

All Services must satisfy the list of ACs (Acceptance Criteria): [acs.html](https://app-sre.pages.redhat.com/contract/acs.html) and [acs.txt](https://app-sre.pages.redhat.com/contract/acs.txt).

The process for Service Onboarding is documented [here](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/service/service_onboarding_flow.md).

### SRE Checkpoints

All Services will receive an SRE Checkpoint periodically. Each SRE Checkpoint will take 1 day, and each AppSRE engineer will conduct one per sprint. [Further information](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/process/sre_checkpoints.md).

## Maintenance Windows

Maintenance window activity guidance is documented [here](/docs/app-sre/maintenance-windows.md).
