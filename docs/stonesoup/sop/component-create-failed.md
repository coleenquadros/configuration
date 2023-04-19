# Component create failed

## Pre-requisites

* [Gain view access to RHTAP clusters](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/logs.md)
* [Gain access to view RHTAP logs](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/logs.md)

## Indicators of "Component create failed"

### Errors in logs

* Refer to: [RHTAPBUGS-115](https://issues.redhat.com/browse/RHTAPBUGS-115)
* Error in the logs: `Component create failed: application devfile model is empty. Before creating a Component, an instance of Application should be created xyz-tenant/devfile-abc` 
* Error example 2: `2023-03-23T16:46:39.803Z ERROR controllers.Application Unable to create repository {"appstudio-component": "HAS", "Application": "<user>/<namespace>", "clusterName": "", "error": "POST https://api.github.com/orgs/redhat-appstudio-appdata/repos: 403 You need admin access to the organization before adding a repository to it. []"}`
* Example from the build-service log: `2023-04-13T16:59:24Z	INFO	controllers.ComponentOnboarding	Waiting for ContainerImage to be set	{"ComponentOnboarding": "xyz-tenant/devfile-abc"}`

### Builds fail to start

* A customer may report that they were creating a new application, but the build never started. On the Application Lifecycle page, the UI says "no builds yet".
* Refer to: [RHTAP-784](https://issues.redhat.com/browse/RHTAP-784)

### Canary performance test fails

* Frequent build timeouts reported on the [performance testing dashboard](http://kibana.intlab.perf-infra.lab.eng.rdu2.redhat.com/app/dashboards#/view/01508c40-d5e0-11ed-a972-8971ce66b77d)
* Refer to: [RHTAP-784](https://issues.redhat.com/browse/RHTAP-784)

### Steps

* An error like `2023-04-13T16:59:24Z	INFO	controllers.ComponentOnboarding	Waiting for ContainerImage to be set	{"ComponentOnboarding": "xyz-tenant/devfile-abc"}` can happen in a normal operation when the Application and Component CRs are created at the same time. The situation should be resolved automatically on reconciliation after the GitOps repo has been created successfully. It is part of the normal operation. Having said that, the message can cause confusion with a real functional failure. This issue: https://issues.redhat.com/browse/DEVHAS-332 was opened to improve the message to avoid the confusion.
* We also saw this error when the version of the UI was accidentally out of date. [Slack thread](https://redhat-internal.slack.com/archives/C04F4NE15U1/p1681454135674519?thread_ts=1681329160.019999&cid=C04F4NE15U1). Other symptoms of the UI being out of date were that the browser occasionally showed errors instead of loading the page correctly, and there were errors in the browser's developer console. In this case, reach out to the HAC team for help.
* Check the [configuration of the HAS Github organization](https://github.com/redhat-appstudio/infra-deployments/blob/main/components/has/production/kustomization.yaml) - is the server using the correct organization?  The HAS development team will need to help with this.
* Check the Github token - is it incorrect, expired or revoked? Is it stored at the [expected path in App Interface](https://github.com/redhat-appstudio/infra-deployments/blob/main/components/has/production/has-github-token-patch.yaml)?  The HAS development team will need to help with this.
