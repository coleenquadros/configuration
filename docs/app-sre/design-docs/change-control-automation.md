# Change Control Automation

## Introduction

Reduce toil time and improve consistency in change records by automating a connection between GitLab and Jira change control projects. Require an approved jira ticket for automatic merge approval for designated major changes.

Further introduction by @anjaasta:

* All "changes" that occur in the fedramp universe are expected to have a special "change-record jira ticket", assigned to a special change-record board, associated with that change.
* A subset of these "change-record jira tickets" (dubbed "major changes") are supposed to be approved by one or more designated persons with change-approval power. These changes are discussed at a weekly change control meeting and approved by a cross-functional group.
* These "change-record jira tickets" are completely separate from "normal jira tickets"; i.e. tickets that teams use as part of their own work tracking.

## What

Automate the creation of change records for pending MRs to GitLab repositories (targeted at FedRAMP, but useful for commercial change control applications as well). When a MR is open and receives a label `cr-pending`, automatically populate a jira ticket in the change control project.

After the ticket is created, have a q-r integration (`gitlab-compliance-housekeeping`) interact with MR labels and report on ticket status via comments. 

To support major change controls, add a label, `cr-approval-required`, which will enforce an approval constraint on the ticket for the MR to be merged. 

### Merge Request fields -> Jira Ticket Mapping

* Title: MR Title
* Description: MR Description
* Project: Change Control
* Assigned to: Compliance change members, specified in a per-environment basis
* Watchers: MR Author

## Technical Implementation

### gitlab-compliance-housekeeping integration

Create a new integration in qontract-reconcile called `gitlab-compliance-housekeeping` (gch). The integration will poll all app-interface controlled gitlab repositories, looking for specific labels and acting on them. `gch` will perform specific state-based activities:

* create jira tickets
* get state of a given jira ticket based on a label (sha hash)
* update MR comments to include links to the change control jira ticket (write only, no read)
* manage MR labels
* enable and disable change protection approval requirements
* enforce merge requirements on change protection approval requirements

The prior version of this document included usage of Alertmanager, Jiralert, and qontract-cli queries. After full analysis of the purposes of `gch` integration, it is my strongly held belief that using this complicated stack to create tickets will introduce multiple points of failure and represent an overly complicated architecture.

`gch` will interact with GitLab and Jira whether or not `gch` makes the initial change request ticket. Therefore, there is no strong purpose to segment the creation of a ticket to a distributed system. Instead, I believe we will achieve faster impact and a lower ongoing support cost if we move ticket creation and ticket management into `gch`, as opposed to just ticket management.

### GitLab MR and Jira Ticket Relationships



### GitLab and Jira Client Technical Requirements

#### Jira

* create_issue (supported)
* get_issues (supported) - needs a code update or a new method to support custom JQL queries

#### GitLab

* get_merge_requests (supported)
* get_merge_request_label_events (supported)
* get_merge_request_labels (supported)
* add_label (supported)
* remove_label (supported)
* get_merge_request_first_commit_hash - need to add this feature

#### Label Types

* cr-pending
* cr-active
* cr-approval-required
* cr-approval-required-cancel
* cr-approved
* cr-denied

#### Label Interactions

Each table below describes the conditions for `gch` actions and the actions performed based on the state of the MR, Labels, Comments, and Jira Ticket.

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |   |   |   |   |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  |   |   |   |   |

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |  open |   |   |   |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  |   |   |   |   |

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |  open |   | /change-record  |   |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  |  Set labels | +change-record-pending  |   |  Create ticket |

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |  open | change-record-pending  | /change-record  |  open |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  |  Set labels, find ticket | -change-record-pending +change-record-active | +ticket url  |   |

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |  open | change-record-active | /change-record  |  approved |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  |  |  |   |   |

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |  open | change-record-active | /change-record, /major-change  |  open |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  | Set labels, Poll for ticket status, enforce merge protection | +major-change-pending | +major change protection on  |   |

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |  open | Change-record-active, major-change-pending | /change-record, /major-change  |  approved |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  | Set labels, Poll for ticket status, allow merge | -major-change-pending +major-change-approved | +change approved  |   |

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |  open | Change-record-active, major-change-pending | /change-record, /major-change  |  denied |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  | Set labels, Poll for ticket status, deny merge | -major-change-pending +major-change-denied | +change denied  |   |

|   | **MR**  |  **Labels** |  **Comments** | **Jira Ticket**  |
|:---:|:---:|:---:|:---:|:---:|
|  **Conditions** |  open | Change-record-active, major-change-pending | /change-record, /major-change, /major-change-cancel  |  open |
|   |  **Integration** | **Labels**  | **Comments**  | **Jiralert**  |
| **Actions**  | Set labels | -major-change-pending  | +major change protection off  |   |
