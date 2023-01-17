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

### Label Permissions

Introducing labels as a state machine for `gch` operations means that we must also manage the list of users who can apply change control labels to a MR. In gitlab housekeeping, a list of allowed users is checked when processing labels, and labels from unauthorized sources are removed. In general, this means that most users have permissions to modify labels, but they will not persist on subsequent reconciliation loops.

The label permissions for change-control-automation should apply to any developer who is creating MRs to app-interface. 

### GitLab and Jira Client Technical Requirements

#### Jira

* create_issue (supported)
* get_issues (supported) - needs a code update or a new method to support custom JQL queries

One important note - the "approved" status in Jira may correspond to a number of ticket states. i.e. "Awaiting Implementation," or other label strings. We must include constants in `gch` which represent the totality of possible approval states as it relates to tickets.

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

### No actions
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |   |   |   | 
|   |  **Integration** | **Labels**  | | 
| **Actions**  |   |   |   |   |

### New MR
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |  open |   |   |
|   |  **Integration** | **Labels**  | |
| **Actions**  |   |   |   |

### Existing MR, add change control record automation
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |  open | +cr-pending  |   |
|   |  **Integration** | **Labels**  | |
| **Actions**  | Create ticket  |   | Ticket created |

### Existing MR, actions performed after ticket created
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |  open | cr-pending  | open |
|   |  **Integration** | **Labels**  | |
| **Actions**  |  Set labels, find ticket, comment ticket url | -cr-pending +cr-active |  |

### Existing MR, Jira ticket approved
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |  open | cr-active | approved |
|   |  **Integration** | **Labels**  | |
| **Actions**  |  |  |   |   |

### Existing MR, add major change protection
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |  open | cr-active, +cr-approval-required  |  open |
|   |  **Integration** | **Labels**  | |
| **Actions**  | Set labels, Poll for ticket status, enforce merge protection, comment "major change protection enabled" |  | |   |

### Existing MR, Jira ticket approved
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |  open | cr-active, cr-approval-required | approved |
|   |  **Integration** | **Labels**  | |
| **Actions**  | Set labels, Poll for ticket status, allow merge, comment "major change record approved" | -cr-approval-required +cr-approved |  |

### Existing MR, Jira ticket denied
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |  open | cr-active, cr-approval-required |  denied |
|   |  **Integration** | **Labels**  | |
| **Actions**  | Set labels, Poll for ticket status, deny merge, comment "major change record denied" | -cr-approval-required +cr-denied |  |

### Existing MR, cancel major change protection
-----

|   | **MR**  |  **Labels** |  **Jira Ticket**  |
|:---:|:---|:---|:---|
|  **Conditions** |  open | cr-active, cr-approval-required, +cr-approval-required-cancel |  open |
|   |  **Integration** | **Labels**  | |
| **Actions**  | Set labels, comment "major change protection off | -cr-approval-required, -cr-approval-required-cancel  |   |
