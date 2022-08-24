# Gitlab.cee Escalation

[TOC]

## Overview

[Gitlab.cee](https://gitlab.cee.redhat.com/) is a private GitLab Community Edition instance managed by the [IT ALM team](https://source.redhat.com/departments/it/digitalsolutionsdelivery/it-application-lifecycle-management). 
The service is only accessible via Red Hat VPN and is used to manage the source code of non public-facing code, including App Interface.
AppSRE has a large reliance on GitLab and have an [existing SOP in place if GitLab is down](./../sop/app-interface-gitlab-down.md).

## Contact Points

In the event of significant GitLab.cee issues, your contact point is the IT ALM Team. [Source](https://source.redhat.com/groups/public/gitlabcee/user_documentation/getting_support)

| Description | Endpoint | Notes |
|---|---|---|
| Tickets | it-alm-tickets@redhat.com |  |
| Support GChat | https://chat.google.com/room/AAAAFb3PAOM |  |
| On-Call Support (US Eastern Business Time Hours) | https://chat.google.com/room/AAAAFb3PAOM |  |
| Critical Support Issues (Outside US Eastern Business Time Hours) | page-alm-oncall@redhat.pagerduty.com | This pages out the on call engineer, if they don't respond in 15 minutes, it pages out the whole team, and if they don't respond, it start escalating up the chain of command. |
| Feature Requests | it-alm-team@redhat.com |  |

## Grafana Dashboards
- [GitLab Overview](https://grafana.engineering.redhat.com/d/wsSteMemz/gitlab-prod-omnibus-overview?orgId=1&refresh=1m)
    - Keep an eye on the Sidekiq queue. In [APPSRE-5772](https://issues.redhat.com/browse/APPSRE-5772), our integrations were responsible for a huge increase in the Sidekiq queue which degraded the performance of the service.
- [Additional GitLab Dashboards](https://grafana.engineering.redhat.com/dashboards/f/SSVDIpiGk/cip)
- [AppSRE Integrations](https://grafana.app-sre.devshift.net/d/Integrations/integrations?orgId=1)
    - The MR queue depth may reflect a degradation of GitLab performance if too many MRs are not being processed correctly

## More Information
- [GitLab Down SOP](./../sop/app-interface-gitlab-down.md)
- [AppSRE bot account](https://gitlab.cee.redhat.com/devtools-bot)
- [APPSRE-5772, when our webhooks degraded GitLab performance](https://issues.redhat.com/browse/APPSRE-5772)
- [GitLab info on the Source](https://source.redhat.com/groups/public/gitlabcee)
