# Design doc: Service Maintenance declaration and status page announcement via app-interface

## Author/date

Gerd Oberlechner - May 2022

## Problem statement

AppSRE tenants want to announce maintenances for their services on status.redhat.com but have no or limited access to the management capabilities for statuspage.io. AppSRE is not always informed about such maintenances but must be aware of them.

## Goal

Allow tenants to self service maintenance announcement on the status page

## Out of scope

It is not the goal of this document to provide a proposal for full fledged maintenance management via app-interface.

## Proposed solution

### Describing maintenances in app-interface

Define a new schema `/app-sre/maintenance-1.yml` that tracks details for a maintenance like titles, descriptions, time window, etc.

```yaml
$schema: /app-sre/maintenance-1.yml
...
name: maintenance name
title: Maintenance for xxx
stage: scheduled | in_progress | verifying | completed
scheduledStart: ISO timestamp
scheduledEnd: ISO timestamp
```

Maintenance announcements can be defined in a dedicated `announcements` section, which allows for different announcement providers. An announcement provider `statuspage` will be supported to begin with, enabling tenants to post maintenance announcements on the status page.

```yaml
announcements:
- provider: statuspage
  announceAt: ISO timestamp
  message: a message describing the maintenance on the status page
  statuspage:
    page:
        $ref: ref-to-status-page.yaml
    remindSubscribers: true | false
    notifySubscribersOnStart: true | false
    notifySubscribersOnCompletion: true | false
```

Maintenances can also be bound to specific components on the status page. By referencing a maintenance in a `/dependencies/status-page-component-1.yml#status` section, a component participates in the maintenance. This means that the the component is specifically listed as being part of the maintenance on the status page and inherits a maintenance status during the time of the maintenance.

```yaml
$schema: /dependencies/status-page-component-1.yml
...
status:
- provider: maintenance
  maintenance:
    $ref: ref-to-maintenance.yaml
```

## Future work

Maintenances tracked that way are also a great way to drive communication between tenants, AppSRE and SD in general, e.g.

* remind AppSRE IC via Slack before a maintenance starts
* app-interface-output list with all planned and ongoing maintenances

## Alternatives considered

There are no other tools available to AppSRE or AppSRE tenants to define maintenances. ServiceNow change management is available to IT only.

## Milestones
