# Interrupt Catching Process

The interrupt catcher is a rotation that dedicates an AppSRE engineer to triage or process incoming incidents, alerts, and tenant requests. The goal is to have a defined escalation point to reduce the number of interruptions to the rest of the AppSRE team.

The IC schedule matches the AppSRE escalation policy in Pager Duty, which is [Follow The Sun](https://redhat.pagerduty.com/schedules#PQ022DV) when someone is defined, and [Primary Oncall](https://redhat.pagerduty.com/schedules#PHS3079) otherwise.

## AppSRE engineer guide to IC responsibilities

There are several tasks that are expected of the AppSRE engineering acting as the IC for the shift. They are listed below in the order of priority.

#### 1. Respond to critical alerts that are sent via Pagerduty (also sent to [#sd-app-sre-oncall](https://coreos.slack.com/archives/CKN746TDW))

`critical` or `critical-fts` alerts are an indicator that a service is significantly degraded or completely down, the latter being for alerts that only page us when there is FTS coverage. These incidents are the highest priority for the IC engineer, regardless of any other responsibilities such as meetings or other tasks on this list. The IC engineer should respond to these incidents as soon as possible and escalate to others on the team if you are unable to do so for any reason.

Ensure that you are familiar with the [incident response doc](/docs/app-sre/incident-process.md) and use the criteria in that document to determine whether to declare an incident. When in doubt do not hesitate to escalate incidents to others within the AppSRE team.

#### 2. Respond to user-reported issues affecting production in [#sd-app-sre](https://coreos.slack.com/messages/CCRND57FW/)

There are several types of issues that fall within this category including:

* A user reports a production issue that hasn't triggered an alert (we try to avoid this, but it can happen)
* A user needs an MR merged because they're actively investigating a production issue (this is the only time a tenant should be directly pinging the IC to merge an MR)

It is important to evaluate the actual impact to the service when these reports come in. Sometimes these could be false positives (client-side issues), but other times they are not. For these situations, if there aren't any active alerts, you'll want to escalate to the tenant team for assistance with assessing impact, and see the criteria in the [incident response doc](/docs/app-sre/incident-process.md) to determine if an incident needs to be declared.

#### 3. Review app-interface merge requests

The majority of changes to resources managed by app-interface need to be approved by an AppSRE engineer. The IC engineer is responsible for handling these reviews during their shift. There is a separate guide for more details on [reviewing app-interface MRs](/docs/app-sre/sop/app-interface-review-process.md).

#### 4a. Review ASIC tickets

The IC engineer should review any open [ASIC](https://issues.redhat.com/projects/ASIC/issues/) tickets and attempt to resolve them, or at least start the investigation and post and findings to the ticket.

#### 4b. Answer users questions in [#sd-app-sre](https://coreos.slack.com/messages/CCRND57FW/) that aren't impacting production

Users will often ask questions in [#sd-app-sre](https://coreos.slack.com/messages/CCRND57FW/) such as how to perform some task in app-interface, or other general questions. Keep the following in mind when answering questions in this channel:

1. If the application is `InProgress`, then the question should be asked in [#sd-app-sre-onboarding](https://coreos.slack.com/archives/C02CMTM9GG1).
2. Sometimes users will ask about an issue with their OSD cluster. We only assist in cases where the cluster is managed by app-interface, otherwise they've probably mistaken us for [#sd-sre-platform](https://coreos.slack.com/archives/CCX9DB894)

#### 5. Respond to high alerts in [#sd-app-sre-alert](https://coreos.slack.com/archives/CDW0S85QU)

`high` alerts are sent to the [#sd-app-sre-alert](https://coreos.slack.com/archives/CDW0S85QU) Slack channel. The IC engineer doesn't need to respond to these immediately, but we should attempt to keep an eye on alerts that are recurring. The general process for dealing with these alerts is:

1. Click on the **Runbook** link in the channel alert channel to access the SOP
2. Read through the SOP and attempt to resolve the issue
3. Escalate to the tenant team if you cannot resolve the issue with the SOP
4. When the issue is mitigated/resolved, search through the alerts Slack channel to see if this alert has been trending, or if there were concerns because the SOP was incomplete, create an [ASIC](https://issues.redhat.com/projects/ASIC/issues/) ticket to track working with the team to fix the alert or underlying issue

### Additional notes

* Keep in mind that the priorities of the tasks above are a general guide, but we want to keep in mind the [SLOs that we've defined for the team](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/README.md#service-agreements).
* If you are having a very busy shift (an incident / many alerts), don't hesitate to ask for assistance in [#sd-app-sre-teamchat](https://coreos.slack.com/archives/GGC2A0MS8) if you're falling behind on tasks that are near breaching their SLO. It's possible that someone else can jump in quickly to assist with taking a look at alerts, MRs, etc.
  * TODO: it'd be good if we were more actively tracking SLOs on the different tasks listed above so that it's clearer when the IC is falling behind

### Handover process

There is a Slack reminder (see `/remind list`) setup in the [#sd-app-sre-handover](https://coreos.slack.com/archives/C019FBYNL4F) channel to remind the IC to perform a handover.

The handover should include:

1. A status update of any active issues that you're working on that need attention from the oncoming IC
2. Any helpful information such as "I didn't have much time to review app-interface MRs, so there are many in the queue"

Please be sure to complete a handover even if it is "There are no issues to handover."

## Resources

### Incident response

The [incident response doc](/docs/app-sre/incident-process.md) covers this topic at length. Ensure that you're familiar with this document for your IC and on-call shifts.

### Access to systems

- [AAA - Anthology of App-SRE Axioms](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/AAA.md) - ensure that you have access to all required systems

### Tenant questions

- [Developer guidelines](https://gitlab.cee.redhat.com/service/dev-guidelines)
- [App-Interface Frequently Asked Questions](https://gitlab.cee.redhat.com/service/app-interface/blob/master/FAQ.md)
- [Service Delivery support](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/support.md) - for OpenShift upstream issues
