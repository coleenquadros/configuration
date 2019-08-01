# SOP : Hive Monitor

<!-- TOC depthTo:2 -->

- [SOP : Hive Monitor](#SOP--Hive-Monitor)
- [Responsibilities](#Responsibilities)
- [Enhance the SOPs in app-interface repository](#Enhance-the-SOPs-in-app-interface-repository)
- [Contact information for SRE team](#Contact-information-for-SRE-team)

<!-- /TOC -->

# Responsibilities

We will have team members on a weekly rotation to keep an eye on the Hive environments. 

Responsibilities:
1. Monitor the `#team-hive-alert` channel in coreos.slack.com and investigate alerts using the alert-provided SOP. Note that accessing SOPs on [https://gitlab.cee.redhat.com](https://gitlab.cee.redhat.com) requires being on the Red Hat VPN.
2. Add a new alert document SOP if a doc does not exist for the alert in [https://gitlab.cee.redhat.com/service/app-interface/tree/master/docs/hive/sop](https://gitlab.cee.redhat.com/service/app-interface/tree/master/docs/hive/sop)
    - For details refer to the section on [Enhance the SOPs in app-interface repository](#Enhance-the-SOPs-in-app-interface-repository)
3. If investigation yields a new a Hive bug, create a card in Jira under the `SRE Platform (SREP)` project. For production issues, ensure that priority is set to High.
4. Contact SRE team if required. For details refer section on [Contact information for SRE team](#Contact-information-for-SRE-team)
5. Monitor general Hive cluster health and error rates on the [Hive dashboard](https://grafana.app-sre.devshift.net/d/hive/hive?orgId=1).
6. Ideally Hive monitor is only part time responsibility and able to continue normal work.

# Enhance the SOPs in app-interface repository
The SOPs(runbook) for specific alerts in `#team-hive-alert` slack channel are present in [https://gitlab.cee.redhat.com/service/app-interface/tree/master/docs/hive/sop](https://gitlab.cee.redhat.com/service/app-interface/tree/master/docs/hive/sop).

If you find a new alert which does not have an SOP or want to improve the existing SOPs then send a PR for it. 

Sending a PR to app-interface repository:
- Fork [https://gitlab.cee.redhat.com/service/app-interface](https://gitlab.cee.redhat.com/service/app-interface)
- Add `@devtools-bot` as a member (maintainer) to your fork (your fork -> settings -> members)
    - This is required for PR tests.
- Add content to your branch and send the PR.
- Example commit for adding a new runbook https://gitlab.cee.redhat.com/service/app-interface/commit/befca4e32e39f94b68e01a79d3abc1a23feab34c

# Contact information for SRE team

- You can raise an alert in pager duty or ping @sre-primary or @sre-secondary alias in #team-hive-alert slack channel depending on priority to get whoever is on-call at that moment.
- For escalations ping SRE interrupt catcher i.e. alias @app-sre-ic in slack #sd-app-sre channel.
