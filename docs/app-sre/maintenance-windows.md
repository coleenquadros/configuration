# Maintenance Windows

Maintenance windows are often required for actions such as database upgrade or infrastructure migrations. This document is meant to provide guidance for common procedures across all maintenance window activities. There will be many considerations that are service-specific that will not be covered here.

## General guidelines

* Test the change in the service's staging environment before production
* All customers and stakeholders should be notified in advance (specific requirements will vary from service to service)
* Every step to be performed in the maintenance window [should be documented](#runbooks) such that any AppSRE engineer could complete the activity (or roll it back)

## Runbooks

A runbook outlining all steps that an engineer should take during a maintenance window should be **mandatory for any significant production change that will cause an outage, or has the possibility to cause an outage**.

The template should have best practices built into it, but it's worth stating that this document should be written such that any engineer on the team could complete the activity in the middle of the night without issue. Having very detailed steps documented has several benefits:

* The activity can be formally approved by key stakeholders
* The actions can be peer-reviewed
* Any engineer on the team can fill in for the engineer that was originally scheduled to perform the work (emergencies happen)
* Provides documentation of exactly what changed which could be useful in the future

To create a runbook, **make a copy of**: [Maintenance Window Runbook](https://docs.google.com/document/d/1BpJXvU40qvvRV4k6hCQCQWPtCtEtLGQVt0wEyFnx-Ks/edit)

## Useful Resources

* [Status page updates](/docs/app-sre/statuspage.md)
