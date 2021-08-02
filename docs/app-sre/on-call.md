# On Call rotation

The AppSRE on call schedule is a rotation to ensure handling of service outages
and incidents for our application owners. Schedule of past, current and future
on call rotation can be viewed @ pagerduty: https://redhat.pagerduty.com/

### Follow the sun

The follow the sun cycle (FTS) is an on-call rotation to ensure that the first page triggered by an alert goes to an engineer who, at the time, is within regular working hours. This is to prevent direct pages to the primary on-call within the regular hours of others. If there is no engineer available within their regular hours the page will go directly to the primary on-call.

Schedule: https://redhat.pagerduty.com/schedules#PQ022DV

Any person currently active as the FTS, will also be the IC (Interrupt Catcher), documented [here](/docs/app-sre/interrupt-catching.md).

### Primary on-call

The primary on-call is a 24/7 on-call rotation assigned on a weekly basis. The engineer assigned is required to be available for the initial response within 30 minutes of the page.

Pages for primary on-calls should be be kept at a minimum and are reserved for critical issues in production environments which need immediate attention.

The primary on-call also acts as the interrupt-catcher during their work hours that cycle.

Schedule: https://redhat.pagerduty.com/schedules#PHS3079

### Secondary on-call

The secondary on-call is a 24/7 on-call rotation that serves as backup and support function for the primary on-call. The secondary on-call will be paged if the primary on-call does not aknowledge the incident via Pagerduty (via app, slack integration or other means). The engineer assigned is required to be available for the initial response within 30 minutes of the page.

Schedule: https://redhat.pagerduty.com/schedules#PSTVSQD
