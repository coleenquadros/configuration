# console.redhat.com Production Support Plan

This SOP describes the support plan for the console.redhat.com production environment during the period of time where the platform is running on OSDv4 (August 2020) and AppSRE officially supports the platform (November 2020).

Below is the plan that the console.redhat.com Engineering team will follow to provide support for the console.redhat.com platform.

For reference, the AppSRE Incident Management Procedure can be read [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/AAA.md#incident-procedure).

### On-call Plan

The console.redhat.com Engineering team includes a set of engineers who form an on-call rotation.  They are responsible for fielding, troubleshooting, and resolving critical alerts that may be triggered by the platform.  The rotation is managed by PagerDuty (https://redhat.pagerduty.com/schedules#P0IM8C0).

On-call rotations are one week (Monday to Monday).  On Monday at 9am ET, the on-call engineer rotates to the next engineer on the calendar.

### Incident Response Plan

- Acknowledge the alert (e.g., PagerDuty, Slack, email)
- Confirm that the reported incident is valid. Example verification methods:
  - Manually visit the URL specified
  - Review status pages
  - Review internal high level platform dashboards
  - Is it customer impacting?
- Once verified, determine the individuals who can respond to the event and build a solution
- Determine the communication plan and begin communicating
  - Elect a member of the team to be responsible for regular communication
  - Business Hours: Engineering manager over the responding engineer
  - Non-Business Hours: On-call engineer
- Immediately post a message to the Ansible Slack #cloudservices-outage channel indicating that we are aware of the incident
  - Set the channel topic to something like "Inventory is down, refer to XYZ for details"
  - Continually post updates in this channel every 30 minutes, when new information is available, or when the incident is resolved
- Immediately send an email to the insights-platform@ and cloudservices-outage-list@ mailing lists
  - Continually send email updates every 60 minutes, when new information is available, or when the incident is resolved
- If an immediate merge into app-interface is necessary, page the AppSRE primary on-call
  -  Trigger the on-call AppSRE engineer by typing /pd trigger in the #sd-app-sre-oncall CoreOS Slack channel. Fill in the appropriate information as mentioned in this [blog post](https://mojo.redhat.com/groups/service-delivery/blog/2020/03/19/paging-appsre-oncall)

- Resolve the incident

- Notify the proper channels that the issue is resolved
- Post a message to the #cloudservices-outage channel indicating the incident is resolved and then change the topic back to "No known outages"
- Send an email to the cloudservices-outage-list and insights-platform mailing lists informing stakeholders that the issue is resolved

### Escalation

To escalate to a dependency team, see [here](https://docs.google.com/document/d/1cv55VZaxmJp_LkE-SSk54S6IXASnGM05dSonQXiqN9k/)
Ask for help from another platform engineer, see [here](https://docs.google.com/spreadsheets/d/1D4p7ZbO6C4DVrZjPV9H_au8kPEWrKMX6e4_-GJpvjHc/edit#gid=0)
To escalate to an offering on the platform, see [here](https://docs.google.com/spreadsheets/d/1D4p7ZbO6C4DVrZjPV9H_au8kPEWrKMX6e4_-GJpvjHc/edit#gid=1886825234) 

In the event where you are not able to reach the offering contact, the platform has the right to resolve the issue any way they can (e.g., including taking down an app if it resolves the issue).

