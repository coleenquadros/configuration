# AppSRE Incident Process

<!-- TOC -->

- [AppSRE Incident Process](#appsre-incident-process)
    - [Introduction to the SD Incident Management Process](#introduction-to-the-sd-incident-management-process)
    - [Major Incident Definition Criteria](#major-incident-definition-criteria)
    - [Incident Roles in the AppSRE team](#incident-roles-in-the-appsre-team)
    - [AppSRE Internal Escalations](#appsre-internal-escalations)
        - [During working hours](#during-working-hours)
        - [Outside of working hours](#outside-of-working-hours)
    - [Specific AppSRE Flow](#specific-appsre-flow)
    - [Incident Commander Responsibilities](#incident-commander-responsibilities)
        - [Incident Management](#incident-management)
        - [Immediate Communication](#immediate-communication)
        - [Continuous Communication (every 30 minutes)](#continuous-communication-every-30-minutes)
        - [Resolution](#resolution)
    - [External Escalations](#external-escalations)
    - [Resolution](#resolution-1)
    - [Tecnical Resolution of the Issue](#tecnical-resolution-of-the-issue)

<!-- /TOC -->

## Introduction to the SD Incident Management Process

AppSRE follows the official [Service Delivery Incident Management Process](https://source.redhat.com/groups/public/service-delivery/service_delivery_wiki/incident_management_process).

All AppSRE team members must read this process.

## Major Incident Definition Criteria

This process must be followed for major incidents, classified as such if _any_ of the following criteria are met:

* The outage is visible to customers (internal or external).
* Another team besides AppSRE is needed in order to fix the incident.
* The Service is breaching its SLOs.

If the incident does not qualify as a major incident, there is no need to follow this process.

## Incident Roles in the AppSRE team

* **First Responder**: Oncall engineer, by default FTS, Primary or Secondary, in that order.
* **Incident Tech Lead**: In charge of the technical resolution of the incident: investigation, mitigation and resolution. It defaults to **First Responder**. A different person may be chosen by the **Incident Commander**, or by the team manager or by the team lead.
* **Incident Commander**: In charge of communications, fallout and ensuring continuity of the incident investigations. Nominated by the **First Responder**, or by the team manager or by the team lead. In case of an incident outside of working hours, where no one else is available, this role defaults to the **First Responder**.
* **PI (Parallel Investigator)**: An additional engineer that will support the **Incident Tech Lead** to assist with the issue investigation, mitigation and resolution.
* **Incident Owner**: Responsible for the incident after the incident has been resolved. Defaults to **First Responder**. Can be changed by the team manager or team lead, but requires explicit acknowledgement of the change.

## AppSRE Internal Escalations

### During working hours

The **First Responder** may ask other AppSRE team members to join with the incident effort. The **Incident Tech Lead** role will default to the **First Responder**, unless otherwise explicitely stated during the initial moments of the incident. At least one more person will be involved which will be made the **Incident Commander**. Depending on the severity of the issue, other people may join to act as a **PI**.

The team manager and the team lead must be notified of these incidents.

### Outside of working hours

The **First Responder**, acting as the **Incident Tech Lead**, will try to resolve the incident by themselves. If assistance is needed due to the complexity or criticality of the issue, the **First Responder** may escalate to the **Secondary On-Call**, to the team manager or to the team lead via PagerDuty (create issue in PD and assign to them).

## Specific AppSRE Flow

1. Initial Response:
  * AppSRE engineer on call (FTS, Primary, Secondary) becomes the **First Responder**.
  * Continue debugging the issue.
2. 10 minutes later:
  * Nominate **Incident Commander** (defaults to **First Responder** if outside of working hours).
  * Join the AppSRE bridge [zti].
  * Continue debugging the issue.

## Incident Commander Responsibilities

As soon as the **Incident Commander** is nominated, which should be 10 minutes after the start of the incident, and which defaults to the **First Responder** in the event that no other AppSRE engineers are available, they must carry out these tasks:

### Incident Management

* Nominate any additional Parallel Investigators.
* Ensure there is an incident continuity plan, so the incident continues to be investigated after the current shift ends.
* Request help from relevant SMEs, usually from other teams.
* Escalate to managers.
* Ensure the incident is actively being investigated, mitigated and resolved.

### Immediate Communication

* Create a JIRA with type `Task`, with label `type/incident` in the [APPSRE board].
* Create slack channel for the incident, referencing the JIRA and the bridge ([zti]).
* Start the RCA, by creating a copy of the [RCA template]. Attach to the JIRA.
* Post a message to #sd-org with: link to bridge ([zti]), JIRA, and short description of the issue.
* Send email to [serviceOwners], [serviceNotifications],
  [sd-org@redhat.com](mailto:sd-org@redhat.com),
  [sd-notifications@redhat.com](mailto:sd-notifications@redhat.com) and
  optionally [outage-list@redhat.com](mailto:outage-list@redhat.com) if
  relevant. The email should include: Service Name, Impact, JIRA, and incident
  slack channel.

### Continuous Communication (every 30 minutes)

This section needs to be carried out every 30 minutes.

* [Updating status.redhat.com] if relevant.
* [Updating status.quay.io] if relevant.
* Update #sd-org channel with current state of the incident, including impact.
* Send update to the email thread created in the first step.

### Resolution

Upon resolution, this should be notified to all the surfaces that were used to report the incident:

* Incident slack channel.
* #sd-org slack channel.
* Email thread created in the first step.

## External Escalations

If the AppSRE engineer is not able to resolve the issue, it is a good idea to escalate it to the service team, especially during business hours.

Outside business hours, the AppSRE engineer may escalate to the developer oncall if the escalation policy has been provided and documented in App-Interface in the `escalationPolicy` field of the corresponding `app-1.yml` file.

Additionally, if there is any indication that the incident may be caused by an infrastructure issue, the incident team should escalate to the oncall SREP, by pinging `@sre-platform-primary` in the `#sd-sre-platform` channel, or by creating a PD incident and assigning to them.

## Post Mortem

Once the issue has been mitigated and resolved, the **Incident Owner** (defaults to **First Responder**) must carry out the following tasks:

* Understanding the course of the incident and its technical details from start to finish.
* Organizing and driving the PMR meeting in the 5 business days after recovery.
* Is accountable to ensure that full RCA documentation is written up and making sure it contains all the corrective actions.
* Being the main point of reference for the incident when there are follow-up questions about it.
* Driving any follow-up activity linked to the incident.
* Cleaning up after the incident is fully closed, like archiving the slack channel.

## Tecnical Resolution of the Issue

The **Incident Tech Lead** (defaults to **First Responder**) and **Parellel Investigator(s)** are responsible for the investigation, mitigation and resolution of the incident.

The goal of this section is to propose some actions, and to list some resources, that may help with the resolution of the incident.

**Collect Information**

* Log into the cluster with the `oc` cli tool, and then run the [must-gather] script to collect data.
* Access the AppSRE grafana and look for the relevant [dashboard](https://grafana.app-sre.devshift.net/dashboards).
* Fetch pod logs with `oc logs`. If you need older data, it can be accessed via CloudWatch, following the [Log Forwarding] FAQ.

**Service Documention and SOPs**

* Find the service in [Visual App-Interface](https://visual-app-interface.devshift.net/services).
* `sopsUrl` field of the corresponding `app-1.yml` file. TODO: Add to Visual-App-Interface.
* `architectureDocument` field in the `app-1.yml` file.
* Many services have placed their SOPs in the [App-Interface docs] folder.
* Onboarding questionnaire for the service. This can be found referenced by an [Onboarding Epic].

**Common Causes**

This section aims to give some ideas of possible generic underlying causes.

* Recent configuration changes and/or deployments. This implies checking the service `saas-file` and the relevant `namespace` file in App-Interface. If this is the case, a rollback should be evaluated.
* Check the latest deployment job to find any discrepancies or errors.
* Killing the pods (if the service is stateless), may fix the issue or help uncover the root cause.
* Many issues are related to lack of resources. OOMKills are usually a tell-tale sign of this. Increasing `requests` and `limits` in the OpenShift manifest via parameters in the `saas-file` could fix the issue. It is important to support that theory with data, usually obtained from Grafana.
* Underlying infrastructure issues should be ruled out. For example, if all crashing pods are in the same node. If this is the case it should be escalated to SREP.
* RDS should be ruled out as the cause. It is recommended to look at the datavase through the AWS Console. In particular: CPU and memory load, IOPS and burst quota. When in doubt, AWS Performance Insights can be enabled to obtain further data about the database, including long running issues. Note that rebooting the database is not recommended by default.

[RCA Template]: https://docs.google.com/document/d/12ZVT35yApp7D-uT4p29cEhS9mpzin4Z-Ufh9eOiiaKU/edit
[zti]: https://meet.google.com/zti-gkvy-pvn
[APPSRE board]: https://issues.redhat.com/projects/APPSRE/
[Updating status.quay.io]: https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/quay/statuspage.md
[Updating status.redhat.com]: https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/statuspage.md
[serviceOwners]: https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/app-sre/app-1.yml
[serviceNotifications]: https://gitlab.cee.redhat.com/service/app-interface/blob/master/schemas/app-sre/app-1.yml
[must-gather]: https://gitlab.cee.redhat.com/app-sre/must-gather#usage
[Log Forwarding]: https://gitlab.cee.redhat.com/service/app-interface/blob/master/FAQ.md#get-access-to-cluster-logs-via-log-forwarding
[App-Interface docs]: https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs
[Onboarding Epic]: https://issues.redhat.com/issues/?jql=project%20%3D%20SDE%20AND%20labels%20in%20(OnBoarding%2C%20onboarding)

