# Interrupt Catching Process

The interrupt catcher is a rotation in which each week the team dedicates a person to triage or process incoming requests/incidents, not already committed to in the sprint.

The IC schedule matches the AppSRE escalation policy in Pager Duty, which is [Follow The Sun](https://redhat.pagerduty.com/schedules#PQ022DV) when someone is defined, and [Primary Oncall](https://redhat.pagerduty.com/schedules#PHS3079) otherwise.

## Surfaces

### Chat

- [coreos.slack.com #sd-app-sre](https://coreos.slack.com/messages/CCRND57FW/)

### Email

- [SD App-SRE list](http://post-office.corp.redhat.com/mailman/listinfo/sd-app-sre)
- [Devtools-SaaS list](http://post-office.corp.redhat.com/mailman/listinfo/devtools-saas)
- [SD Org list](http://post-office.corp.redhat.com/mailman/listinfo/sd-org)

### Jira

- [App-SRE Interrupt Catcher](https://issues.redhat.com/projects/ASIC/issues?filter=allopenissues)
- [App-SRE Scrum](https://jira.coreos.com/secure/RapidBoard.jspa?rapidView=92&view=planning)
- [App-SRE Incident (KanBan)](https://jira.coreos.com/secure/RapidBoard.jspa?rapidView=145&view=detail)

#### PRs

PRs should be reviewed and potentially merged by the IC according to the [AppSRE SLOs](https://source.redhat.com/groups/public/sre-services/sre_services_wiki/appsre_slos) document:

- [App-Interface](https://gitlab.cee.redhat.com/service/app-interface/merge_requests) - [review process SOP](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/sop/app-interface-review-process.md).
- [Infra](https://gitlab.cee.redhat.com/app-sre/infra/merge_requests) - should be processed manually (ansible/terraform) if a job does not exist in ci-int.
- [EL-Dockerfiles](https://github.com/rhdt/EL-Dockerfiles/pulls)

### Resources

- [AAA - Anthology of App-SRE Axioms](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/AAA.md)
- [Developer guidelines](https://gitlab.cee.redhat.com/service/dev-guidelines)
- [App-Interface Frequently Asked Questions](https://gitlab.cee.redhat.com/service/app-interface/blob/master/FAQ.md)
- [Service Delivery support](https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/support.md) - for OpenShift upstream issues

## IC schedule

### Wednesday, Handoff/Initialization

- End of the week IC hand-off: communicate with the next IC inform about pending issues. These should be track in Jira.
- `@app-sre-ic` Slack group member will be set automatically to the person who is IC according to the PagerDuty Primary schedule.

### Daily

#### Requests / Support

- Record each request and action performed by the IC as a Jira issue on the ASIC board.
    * In case the request included work from App SRE side that is more then reviewing PRs.
- Search the backlog for IC issues created by our tenants and move them to the ASIC board.
    * Will usually appear at the bottom of the APPSRE backlog.

#### Incidents / Maintenance

Follow the [AAA Incident procedure](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/AAA.md#168-incident-procedure).

Who to notify:

- [Devtools-SaaS list](devtools-saas@redhat.com) - for dsaas + OSIO clusters problems
- [SD Org list](sd-org@redhat.com) - for everything else
