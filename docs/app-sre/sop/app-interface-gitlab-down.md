# GitLab is down SOP

## Background

Given AppSRE's substantial reliance on GitLab, this document attempts to contemplate:
* how would we adapt if GitLab went down today for an extended period?
* contingency plans we can adopt/create now to reduce risk

This SOP is the result of a discussion recorded in https://issues.redhat.com/browse/APPSRE-4097

GitLab escalation information is detailed in [this runbook](./../runbook/gitlab-escalation.md).

## Content

If gitlab goes down it essentially means that some environments are in freeze.

The immediate effect is that development work, or at least work that needs to be pushed (and promoted) stops. This is not an immediate concern for AppSRE, but worth noting. It is, however, a problem for AppSRE, in the sense that app-interface is in gitlab, and it holds all the deployment definitions. This means that nothing can be deployed to any environment. Again, not an immediate concern, but our service (and SLOs?) is affected.

This becomes a more concrete concern in case there is a bug found in production and we need to push an urgent fix.

Since every merge to app-interface only generates a bundle and uploads it to S3, it is easy to workaround by running the same thing locally (SOP: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/app-interface-manual-deployment.md). The bundle will be pulled by the server and acted upon by our integrations.

Since we are talking about gitlab, this is slightly more difficult, and we will need to dive in deeper.

Start out with restoring the latest backup of the repository (SOP: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/git-keeper-restore.md). Since we are talking about a fix to production, it is VERY likely that the version deployed to production exists in the restored repository. This alleviates the concern of having a backup that doesn't contain all the latest content.

Once restored, we will need to obtain the content that needs to be added as the fix. We will follow the hotfix path (SOP: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/the-app-sre-hotfix-path.md) to add the changes to the version that is currently deployed in production.

The hardest part is running the build_deploy script of the service, as there are many variables that need to be taken into account (environment variables from Vault, OS on which the build usually runs, required tools to have installed locally which are installed where the build usually runs, etc). This hard part should be alleviated in the future if and when tenants switch their builds to run in a containerized environment, but we are not there yet.

Assuming we are talking about a gitlab issue only, which is what we are seeing lately, this hard part can be made easier if we run the build_deploy script on the Jenkins node which usually builds the service image. This is what we've done when we needed a new image for quay.io in the infamous outage (https://issues.redhat.com/browse/APPSRE-1924).

Once the image is built and pushed, we can promote it by manually (OMG) changing it in production.

Once gitlab is back, we will need to redo the process through the regular pipelines of course.

 

So assuming gitlab is down, app-interface is down which slows down all teams, but the real concern is an urgent fix in production, which is possible, but not straight forward.

 

Assuming gitlab goes down for DAYS, we will need to think what is the best thing to do.

One solution may be to migrate over to a different gitlab instance Red Hat runs, but I'm not sure on the viability of this option.

I believe a possible solution (not thinking about political implications here) will be to bootstrap our own gitlab instance (gitlab.devshift.net? ) on one of our internal production clusters (currently we only have appsrep05ue1). This option didn't exist in the past as we didn't have an OSD cluster behind the VPN. But now we do.

This of course means A LOT of work to hook things up close enough to what they were so our automations can take over, and even more work if we want to accommodate development work, and even more work to migrate everything back to gitlab.cee.
