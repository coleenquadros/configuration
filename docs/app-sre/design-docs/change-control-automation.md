# Change Control Automation

## Introduction

Reduce toil time and improve consistency in change records by automating a connection between GitLab and Jira change control projects. Require an approved jira ticket for automatic merge approval for designated major changes.

## What

Automate the creation of change records for pending MRs to GitLab repositories (targeted at FedRAMP, but useful for commercial change control applications as well). When a MR is open and receives a comment `/change-record`, automatically populate a jira ticket in the change control project.

After the ticket is created, have a q-r integration (`gitlab-compliance-housekeeping`) interact with MR labels and report on ticket status via comments. 

To support major change controls, include a comment, `/major-change`, which will enforce an approval constraint on the ticket for the MR to be merged. 

### Merge Request fields -> Jira Ticket Mapping

* Title: MR Title
* Description: MR Description
* Project: Change Control
* Assigned to: Compliance change members, specified in a per-environment basis
* Watchers: MR Author

## Technical Implementation

### High Level

PrometheusRules + qontract-cli query + Alertmanager Receiver + Jiralert x gitlab-compliance-housekeeping integration

### PrometheusRules Alert

Create a PrometheusRules definition in the app-sre-prod-01 cluster where qontract-suite lives. The alert will poll for new MRs on a one minute basis, and will create an alert in alertmanager when a new MR fires. An alertmanager receiver for this type of alert will be set up, forwarding contents to Jiralert which will create a Jira ticket with metadata from the alert.

```
---
$schema: /openshift/prometheus-rule-1.yml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    prometheus: app-sre
    role: alert-rules
  name: app-interface-merge-requests-control
spec:
  groups:
  - name: app-interface-merge-requests-control.rules
    rules:
    {{%- for app in get_app_interface_merge_requests() %}}
    - alert: ChangeControlRequired
      annotations:
        dashboard: ""
        message: "Change control required."
        runbook: "Please approve this change control. this MR will be closed automatically when the MR is merged."
        link_url: "link.to.control.sop"
      expr: |
        1
      for: 1m
      labels:
        service: app-interface-merge-requests-control
        severity: medium
        jiralert: CONTROLBOARD
    {{%- endfor %}}
```

### Qontract-cli query

Create a qontract-cli query which will return a list of all open merge requests that meet criteria.

Use https://github.com/app-sre/qontract-reconcile/pull/2776 as an example on how to generate a query that can be used in aforementioned PrometheusRules.

`{{%- for app in get_app_interface_merge_requests() %}}`

### Alertmanager Receiver

An alertmanager receiver will be setup to route "fake" alertmanager alerts to jiralert, creating the ticket we want. We have prior art in this space:

```
# resources/observability/alertmanager/alertmanager-instance.secret.yaml


{{% if jiralert_host %}}
  # Send jiralert alerts to the correct jiralert receiver
  # or fall through if none is defined
  - match_re:
      jiralert: '.+'
    continue: true
    group_wait: 30s
    group_interval: 5m
    repeat_interval: 30m
    group_by: [alertname, cluster, job, service, app]
    routes:
    {{%- for jira_board in query('/queries/jira_boards.graphql') %}}
    {{%- for sev_prio_map in jira_board.severityPriorityMappings.mappings %}}
    - match:
        jiralert: {{{ jira_board.name }}}
        severity: {{{ sev_prio_map.severity }}}
      receiver: jiralert-{{{ jira_board.name }}}-{{{ sev_prio_map.severity }}}
    {{%- endfor %}}
    {{%- endfor %}}
  {{% endif %}}

  # This alert is processed by JiraAlert and being sent to the team's board
  # This receiver prevents it to be sent to app-sre-alerts slack channel.
  # https://issues.redhat.com/browse/ASIC-256
  - match:
      alertname: RDSPredictOutOfBurstBalance
      dbinstance_identifier: ccx-notification-prod
    receiver: blackhole
    continue: false
```

### gitlab-compliance-housekeeping integration

Create a new integration in qontract-reconcile called `gitlab-compliance-housekeeping` (gch). The integration will poll all app-interface controlled gitlab repositories, looking for specific labels and acting on them. `gch` will perform specific state-based activities:

* update MR comments to include links to the change control jira ticket
* manage MR labels
* enable and disable major change protection
* enforce merge requirements on major changes

An alternative proposal is to use the existing `gitlab-housekeeping` integration to perform the same activities. My original though was to keep compliance based label state management separate from `gitlab-housekeeping` activities. I am open to other ideas.

#### Label Types

* change-record-pending
* change-record-active
* major-pending
* major-approved
* major-denied

#### Label comment controls

* `/change-record`: Create a new change record ticket
* `/major-change`: Enforce merge protection 
* `/major-change-cancel`: Cancel merge protection

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
