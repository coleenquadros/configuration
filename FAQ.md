# App-Interface Frequently Asked Questions

This document serves as a first tier support for issues around app-interface.

For questions unanswered by this document, please ping @app-sre-ic in [#sd-app-sre](https://coreos.slack.com/messages/CCRND57FW) on CoreOS Slack.

## ToC

[TOC]

## Useful links

- [Visual App-Interface](https://visual-app-interface.devshift.net)

## Topics

### Can you merge my MR

The App-SRE IC (interrupt catcher) periodically reviews the MRs in the app-interface repository. There is no need to ping us to let us know you've opened a MR.

If your MR is urgent or time sensitive requests, see [contacting AppSRE](#contacting-appsre)

### Contacting AppSRE

You can catch the AppSRE team in the `#sd-app-sre` channel of `coreos.slack.com`.

To create a request, please open an issue in the [APPSRE Project](https://issues.redhat.com/projects/APPSRE/issues) in JIRA.

For *time sensitive* requests, please ping `@app-sre-ic` in the `#sd-app-sre` channel.

If you have an urgent matter affecting production that needs to be addressed as soon as possible, please do the following:

- Ping `@app-sre-emea` or `@app-sre-nasa` depending on the time of the day.
- If you get no response, and if it's truly critical follow the [Paging AppSRE team](docs/app-sre/paging-appsre-oncall.md) guide.

### How can I get access to X?

Start by accessing the Visual App-Interface at https://visual-app-interface.devshift.net.  Using the side bar, navigate to the [Permissions](https://visual-app-interface.devshift.net/permissions) section.

Find a permission that matches the access you require. For this example, choose [ci-ext](https://visual-app-interface.devshift.net/permissions#/dependencies/ci-ext/permissions/ci-ext.yml)

choosing a permission will take you to the Permission's page, in which you can view a list of `Roles` who grant this permission.  Choose the role that best matches your requirement and submit a merge request to app-interface adding that role to your user file.

### I can not access X

This may be caused due to several reasons. Follow this procedure:

1. Follow the "How can I get access to X" story and make sure you are assigned a role that enables the desired access.
2. Be sure to accept the GitHub invitation at https://github.com/app-sre

### I need help with something AWS related

Please check our [AWS docs](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master/docs/aws).

### I can not access ci-ext

Start by following [I can not access X](#i-can-not-access-x)

Problem: I Can not log in to https://ci.ext.devshift.net.

Managed to log in but having issues? Maybe even seeing this error message? `"Access denied: <your-red-hat-username> is missing the Overall/Read permission"`

Access is managed via app-interface. The role that grants access is [ci-ext-ro-access](/data/dependencies/ci-ext/roles/ci-ext-ro-access.yml).

If you don't have a user file on app-interface:

1. Submit a MR to app-interface adding your user file
1. Add the [ci-ext-ro-access](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/ci-ext/roles/ci-ext-ro-access.yml) role to your user file in the same MR.

If you already have a user file

1. Make sure that your user has the [ci-ext-ro-access](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/ci-ext/roles/ci-ext-ro-access.yml) role assigned, if it's not the case, submit a MR adding the role to your user file.

*Note that the permission could be granted to your user via a role that has the permission assigned, check if any of the roles assigned to your user have the access to ci-ext*

### I can not access ci-int

Start by following [I can not access X](#i-can-not-access-x)

Problem: I Can not log in to https://ci.int.devshift.net.

Managed to log in but having issues? Maybe even seeing this error message? `"Access denied: <your-red-hat-username> is missing the Overall/Read permission"`

Access is managed via app-interface. The role that grants access is [ci-int-access](/data/dependencies/ci-int/roles/ci-int-access.yml).

If you don't have a user file on app-interface:

1. Submit a MR to app-interface adding your user file
1. Add the [ci-int-access](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/ci-int/roles/ci-int-access.yml) role to your user file in the same MR.

If you already have a user file

1. Make sure that your user has the [ci-int-access](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/dependencies/ci-int/roles/ci-int-access.yml) role assigned, if it's not the case, submit a MR adding the role to your user file.

*Note that the permission could be granted to your user via a role that has the permission assigned, check if any of the roles assigned to your user have the access to ci-int*

### I can not access Grafana

The AppSRE Grafana instance is available at https://grafana.app-sre.devshift.net.

Access is managed via app-interface. The role that grants access is [observability-access](data/services/observability/roles/observability-access.yml).

If you are a member of the OpenShift GitHub organization, you can use https://grafana.openshift-app-sre.devshift.net instead (does not require a user file).

### My Grafana Dashboard is missing

Grafana dashboards are discovered automatically if you follow this [guide](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/monitoring.md#adding-dashboards).

- Make sure the key, where you store the dashboard is of the following format: `unique_name.json`. If you use other type, like `.yaml` the dashboard might not be discovered.
- Make sure the uuid in the dashboard json is unique, especially if you copy and paste the dashboard from another one. In doubt just use a uuid.

If still missing, ask AppSRE to check logs of the Discovery and Grafana containers.

### Tagging options in app-interface

GitLab: Users are not being tagged by default for SaaS file reviews. To be tagged on MRs for SaaS files you own, add `tag_on_merge_requests: true` to your user file.

Slack: Users are being tagged by default for cluster updates in clusters they have access to (through membership in a Slack usergroup called <cluster_name>-cluster). To be removed from those usergroups, add `tag_on_cluster_updates: false` to your user file.

### Can you reset my AWS password?

We've got you.

Follow these instructions: https://gitlab.cee.redhat.com/service/app-interface#reset-aws-iam-user-passwords-via-app-interface

### Gating production promotions in app-interface

Prerequisites:

1. Your app's OpenShift templates are located in the same repository as your source code.
    - Hint: multiple code repos? multiple OpenShift templates
    - Hint: not [saas-templates](https://gitlab.cee.redhat.com/insights-platform/saas-templates)

To gate production promotions, follow these steps:

1. Define a [post-deployment testing SaaS file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-testing-in-app-interface.md#define-post-deployment-testing-saas-file) containing tests to be run against the service following it's deployment to the stage environment.
1. Define an [automated/gated promotion](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md#automatedgated-promotions) based on the results of the post-deployment tests that ran on stage.

### Get access to cluster logs via Log Forwarding

The App SRE team uses the CloudWatch Log Forwarding Addon to forward Application and Infra logs to AWS CloudWatch on the cluster's AWS account.

To get access to CloudWatch on a cluster's AWS account, follow these steps (examples for `app-sre-stage-01`):

1. Submit a MR to app-interface to add the [log-consumer](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre-logs/roles/log-consumer.yml) role to your user file. You will also need to [add your public GPG key](https://gitlab.cee.redhat.com/service/app-interface#adding-your-public-gpg-key) (if you havn't already) in the same MR.
    * For console.redhat.com use the [log-consumer-crc](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre-logs/roles/log-consumer-crc.yml) role.
1. Once the MR is merged you will get an email invitation to join the AWS account (in this example - the `app-sre-logs` account). Follow the instructions in the email to login to the account.
    * Note: in case you did not get an invitation, the login details can be obtained from the [Terraform-users Credentials](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/terraform-users-credentials.md) page.
    * Note: to decrypt the password: `echo <password> | base64 -d | gpg -d - && echo` (you will be asked to provide your passphrase to unlock the secret) 
1. Once you are logged in, go to [Security Credentials page](https://console.aws.amazon.com/iam/home?#/security_credentials) and enable Multi-factor authentication (MFA).
1. Logout and login to the account again using the configured MFA device.
1. Once you are logged in, navigate to the Switch Role link obtained from the [ocm-aws-infrastructure-access-switch-role-links](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/ocm-aws-infrastructure-access-switch-role-links.md) page (suggestion: add to bookmarks).
    * Note: search for your org_username for the cluster you want to view logs.
1. In the Switch Role page, select a name for this role (suggestion: `<cluster_name>-read-only`) and click "Switch Role" (Account and Role should be filled automatically).
1. You are now logged in to the cluster's AWS account. Go to the [CloudWatch console](https://console.aws.amazon.com/cloudwatch/home?#logsV2:log-groups) and get your logs!

> Note: CloudWatch logs from all accounts are also available in Grafana, using the `<cluster_name>-cloudwatch` datasource. Feel free to [Explore](https://grafana.app-sre.devshift.net/explore?orgId=1&left=%5B%22now-5m%22,%22now%22,%22app-sre-stage-01-cloudwatch%22,%7B%22id%22:%22%22,%22region%22:%22us-east-1%22,%22namespace%22:%22%22,%22refId%22:%22A%22,%22queryMode%22:%22Logs%22,%22logGroupNames%22:%5B%22app-sre-stage-0-ctbn8.application%22%5D,%22expression%22:%22fields%20@message,%20kubernetes.namespace_name%5Cn%7C%20limit%20100%22,%22statsGroups%22:%5B%5D%7D%5D)!

### User unable to assume IAM role in the AWS Console

If the `Invalid information in one or more fields. Check your information or contact your administrator.` error is displayed when trying to assume a different IAM role, make sure [to enable MFA on your user AWS Account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html). After MFA is enabled, log out and back in. 

### What environments are supported by AppSRE?

The AppSRE team supports only stage and production environments for onboarded services, as described in the [contract](https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/service/environments.md).

The AppSRE team also maintains an OpenShift Dedicated (OSD) integration environment on behalf of Service Delivery (SD) - https://api.integration.openshift.com. This environment is SD-owned, and thus - OSD related services (OSD operators, OCM components) owned by SD teams are allowed to levarage it.

> Note: OSD does not include consoleDot.

### What is the Console or Prometheus URL for a service?

Start by accessing the Visual App-Interface at https://visual-app-interface.devshift.net.  Using the side bar, navigate to the [Services](https://visual-app-interface.devshift.net/services) section.

Choose the relevant service from the list. For example, [cincinnati](https://visual-app-interface.devshift.net/services#/services/cincinnati/app.yml).

Choosing the service will take you to the the service's page, in which you can view a list of `Namespaces` which are related to this service.  In this example the namespaces are:
- `cincinnati-production`
- `cincinnati-stage`

Choose the namespace for which you would like to find the Console/Prometheus URL. For this example, choose [cincinnati-stage](https://visual-app-interface.devshift.net/namespaces#/services/cincinnati/namespaces/cincinnati-stage.yml).

Choosing the namespace will take you to the namespace's page, in which you can find a link to the cluster running this namespace.

In the Cluster page, you can find links to the cluster's Console and to the cluster's Prometheus.
 
### Can you restart my pods?

There are a couple of choices depending on the state of onboarding the service is in currently
[here](https://visual-app-interface.devshift.net/services)
_Note: To the right of the search for services the drop down defaults to "show child apps" you can choose to hide these by selecting the "hide child apps" option_

#### OnBoarded Services

__Example service:__ [quay.io](https://visual-app-interface.devshift.net/services#/services/quayio/app.yml)
If the service is OnBoarded you can contact @app-sre-ic in the #sd-app-sre channel with the reason why you are requesting to "bounce" a pod, (which is actually deleting the pod.)
We also require a Jira ticket in the backlog of the development team that owns the service to automate pod restarting via liveliness probes or health checks so manual intervention is not required.
You may also want to collect information from the the cluster and namespace.  Clusters are listed [here](https://visual-app-interface.devshift.net/clusters) ex. [quayp05ue1](https://visual-app-interface.devshift.net/clusters#/openshift/quayp05ue1/cluster.yml). If the application team still needs help to retrieve debugging information please let the @app-sre-ic team know before we "bounce" the pod.
#### Services not yet OnBoarded

A service may be in some other state such as, but not limited to: _BestEffort_ or _InProgress_

In cases where pods get into an unhealthy state and may require a restart. Below is what you should do:
1. Verify that you are exposing a `REPLICAS` parameter for templating.
2. Submit a MR to app-interface to changes `REPLICAS` to 0 (owners of that saas file are able to self-service the merge).
3. After the MR is merged and applied, submit another MR to app-interface to change `REPLICAS` back to the original value.

Now that the fire is out, please work towards not having to do this again. The solution depends on the underlying issue, but here are some common cases:
1. A dependency of the pod is not responding (example: Kafka). You may want to consider using Kubernetes health probes. We can highly recommend:
A liveness probe that checks your container's health thoroughly; on a liveness probe failure, Kubernetes restarts the container. A readiness probe that takes a container out of service if it is not healthy.
2. A new version of a Secret/ConfigMap has been rolled out. You may use the `qontract.recycle: "true"` annotation to indicate that any pods using these resources should be restarted upon update. More information [here](/README.md#manage-openshift-resources-via-app-interface-openshiftnamespace-1yml).

### Can you run this command or query for me?

It does not scale well to have a team of SREs running ad-hoc commands for recurring needs of many development teams. Additionally, it leads to teams being blocked for standard operations that they can self-service.

If AppSRE is asked to run an ad-hoc command, we will ask for an [ASIC ticket](https://issues.redhat.com/projects/ASIC/issues) to be created with the following information:

1. A justification for why this cannot be performed via some other method:
   1. `Job` or `CronJob` (see [Continous Delivery in app-interface](docs/app-sre/continuous-delivery-in-app-interface.md)). Note that using this method would also make the operation self-service in many cases.
   2. For database operations: [Execute a SQL Query on an App Interface controlled RDS instance](README.md#execute-a-sql-query-on-an-app-interface-controlled-rds-instance)
2. A step-by-step list of what needs to be done for this change
3. An approval from a team member added to the ticket indicating that the command is safe to run

The only exception to above is when there is an active incident.

The ASIC ticket helps the AppSRE team to track cases where there are recurring needs that would be better supported by the methods mentioned above.

### Can you share the AWS access keys associated with an AWS resource with me?

Most AWS resources that are created in app-interface will have an IAM user associated with them. The access keys for this IAM user are typically exposed via a `Secret` in the namespace (`/openshift/namespace-1.yml`) that you've associated the resource with.

These access keys are meant only for programmatic access with your code running in the OpenShift namespace. These access keys will not be shared with you for any other use case. There are several reasons for this including that the access provided by this user may be more than what is needed (read vs. read-write) and an accidental credential leak could also affect your service (leaked access keys are automatically revoked, impacting your service).

There are other options that will depend on whether the use case is **human** or **service** access. Please see the sections below.

#### Human access

We only allow AWS console access for human access (no access keys). The docs for gaining access are covered [here](/README.md#manage-aws-users-via-app-interface-awsgroup-1yml-using-terraform).

#### Service access

Service access covers anything that isn't human access, including another service in Red Hat that needs access to your resource(s). The two options for providing a service with access to the resources are [aws-iam-role](/README.md#manage-iam-roles-via-app-interface-openshiftnamespace-1yml) or [aws-iam-service-account](/README.md#manage-iam-service-account-users-via-app-interface-openshiftnamespace-1yml) with **read-only privileges**.

The general guidance for selecting one or the other is:

* IAM roles are preferred because they don't require sharing of access keys and are therefore more secure. IAM roles allow you to permit some other AWS principal (IAM user, IAM role) to temporarily assume the role you've created and access the required resources. 
* IAM services accounts should be used only where assuming roles isn't practical, and will require AppSRE to share long-lived access keys with the team that needs to access the resources

In the MR to create the role or user, please provide a detailed explanation of why the access is required and how the data will be used.

### Delete target from SaaS file

To delete a target from a SaaS file, set `delete: true` in the target you wish to delete. This will cause all associated resources to be deleted in the next deployment. Follow this up with another MR to delete the target from the SaaS file.

For example, to delete the stage deployment from this saas-file:
```
(top of the file)
resourceTemplates:
- name: exampleApp
  path: /deploy/clowdapp.yaml
  url: https://github.com/RedHatInsights/exampleApp
  targets:
  - namespace:
      $ref: /services/insights/example/namespaces/example-stage.yml
    ref: b17281f74dea89f0834c34f697ea257445f3c195
  - namespace:
      $ref: /services/insights/example/namespaces/example-prod.yml
    ref: b17281f74dea89f0834c34f697ea257445f3c195
```
Open an MR, add `delete: true` to the target you wish to delete:
```
(top of the file)
resourceTemplates:
- name: exampleApp
  path: /deploy/clowdapp.yaml
  url: https://github.com/RedHatInsights/exampleApp
  targets:
  - namespace:
      $ref: /services/insights/example/namespaces/example-stage.yml
    ref: b17281f74dea89f0834c34f697ea257445f3c195
    delete: true # deleting from the namespace - will remove in followup MR.
  - namespace:
      $ref: /services/insights/example/namespaces/example-prod.yml
    ref: b17281f74dea89f0834c34f697ea257445f3c195
```
Then open up a follow-up MR to delete the target from the saas file:
```
(top of the file)
resourceTemplates:
- name: exampleApp
  path: /deploy/clowdapp.yaml
  url: https://github.com/RedHatInsights/exampleApp
  - namespace:
      $ref: /services/insights/example/namespaces/example-prod.yml
    ref: b17281f74dea89f0834c34f697ea257445f3c195
```

More information: [Continuous Delivery in App-interface](/docs/app-sre/continuous-delivery-in-app-interface.md)

### Jenkins is going to shutdown

Problem:
Seeing this message in ci-ext - `Jenkins is going to shut down. No further builds will be performed`.

Reason:
Jenkins is configured to perform a [Thin backup](https://plugins.jenkins.io/thinBackup) periodically. It is recommended to perform the backup when no jobs are running. Jenkins will not schedule jobs during the waiting period (waiting for all running jobs to complete). No manual intervention is required, this is expected.

If a job is pending and need to be rushed, contact the App SRE team for assitance (canceling the current restart will get pending jobs to run, but will not cancel the backup).

### How can I make my PR check job run concurrently

Add `concurrent_build: true` to your job definition. [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/2d18ad87e9775cfefa0a18be77c9b795eb81b730/data/services/app-interface/cicd/ci-ext/jobs.yaml#L59)

### How can I see who has access to a service

Start by accessing the Visual App-Interface at https://visual-app-interface.devshift.net.  Using the side bar, navigate to the [Services](https://visual-app-interface.devshift.net/services) section.

Choose the relevant service from the list. For example, [telemeter](https://visual-app-interface.devshift.net/services#/services/rhobs/telemeter/app.yml).

Choosing the service will take you to the the service's page, in which you can view a list of `Namespaces` which are related to this service.  In this example the namespaces are:
- `telemeter-production`
- `telemeter-stage`

Choose the namespace for which you would like to see the users. For this example, choose [telemeter-production](https://visual-app-interface.devshift.net/namespaces#/services/rhobs/telemeter/namespaces/telemeter-production.yml).

Choosing the namespace will take you to the namespace's page, in which you can view a list of `Roles` which are associated with this namespace.  Some of the roles in this namespace are:
- `dev`
- `view`

Choosing a role will take you to the Role's page, in which you can view a list of `Users` who have this role associated to them, and the namespace access granted through this role.  To finalize this example, choose the [dev](https://visual-app-interface.devshift.net/roles#/teams/telemeter/roles/dev.yml) role to see a list of users who has this role.

The users in this page are granted a `view` permission in the `telemeter-production` namespace through the `dev` role.

### Accessing DataHub

DataHub is not managed by the AppSRE team, but you can find the process to [request access here](https://help.datahub.redhat.com/docs/interacting-with-telemetry-data). To report issues with Datahub (ex: timeouts with telemeter-lts-dashboards.datahub.redhat.com) see [this help page](https://help.datahub.redhat.com/docs/data-hub-report-issues) or reach out to [#forum-telemetry](https://coreos.slack.com/messages/forum-telemetry) on Slack for additional info.

### Jenkins Vault plugin upgrade

The App SRE team is upgrading the Vault plugin on it's Jenkins instances from version 2 to 3.

As a result from this upgrade, jobs may fail due to not being able to read secrets from Vault if they contain empty keys. If you encounter a failing job which seems related to Vault, please check all the secrets used by the job to verify they do not contain empty keys.

In case of any other issues, please reach out to @app-sre-ic on #sd-app-sre in CoreOS slack.

Related Jira ticket: https://issues.redhat.com/browse/APPSRE-947

### I didn't receive my invite for the Github organization

Check your mailbox! It should be there! If not, ask the IC to review [the AppSRE organization](https://github.com/orgs/app-sre/people) and see if your invite is pending or failed. They can cancel the pending invite and send a new one to you.

### I need to add a package to a jenkins slave

The App SRE team recommends transitioning to using containerized builds over trying to load specific packages onto a jenkins slave.  Containerized builds provide numerous advantageous to our users including:

- Control over the build dependencies
- Idempotency
- Portability

Information about multi-stage container builds can be found [here](https://docs.docker.com/develop/develop-images/multistage-build).  Here's an simple [example](https://github.com/app-sre/deployment-validation-operator/blob/master/build/Dockerfile) of a Dockerfile using multi-stage build.

If using a containerized build is not possible, please submit an MR to the [infra](https://gitlab.cee.redhat.com/app-sre/infra) repo and ping the IC.

### My configuration is merged into app-interface but it isn't applied!

Check your namespace and your saas file! Is your new configuration's type listed in the `managedResourceTypes` field? For instance, if you have submitted a new `ConfigMap` for a namespace, its namespace file must list `ConfigMap` in its `managedResourceTypes`.

Review #sd-app-sre-reconcile in slack for messages related to your configuration, it should tell you if it is applying it or it is skipping it. See [this ticket](https://issues.redhat.com/browse/APPSRE-3668)

### My tekton deploy PipelineRun is silenty failing for no obvious reason

If the `openshift-saas-deploy` Task of the Pipeline fails to finish successfully and leaves no trace about there's a good chance that the pod responsible to execute the Task's steps are hitting the memory limit getting killed by the kernel OOM. In order to verify this, you can search for pods in the tekton provider's namespace associated your saas file. If you see pods related to your `PipelineRun` (which are named after your saas file) showing `OOMKilled` status, you will need to increase the resources assigned to your deployment pods. In order to do that, just add a [`deployResources`](/docs/app-sre/continuous-delivery-in-app-interface.md#saas-file-structure) section in your saas file or increase the resources associated there. The resulting MR can be approved by the saas file owners.

### I can not see metrics from my service in Prometheus

AppSRE uses [openshift-customer-monitoring](./docs/app-sre/osdv4-openshift-customer-monitoring.md) to monitor services.

For Prometheus to be able to monitor a service, two things are required:
1. a NetworkPolicy allowing traffic from the `openshift-customer-monitoring` namespace to the service namespace. Here is an [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/85cc048cef88f9cccfd4e5dbde5e0d9234390bca/data/services/insights/rbac/namespaces/rbac-prod.yml#L20).
1. a view RoleBinding in the service namespace for `openshift-customer-monitoring/prometheus-k8s`. Here is an [example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/85cc048cef88f9cccfd4e5dbde5e0d9234390bca/data/services/observability/roles/app-sre-osdv4-monitored-namespaces-view.yml#L398-400).

For further instructions, check out the complete [monitoring](./docs/app-sre/monitoring.md) guide.

### I am having problems accessing a Gabi instance

In order to provide generic db access for tenant‘s service, we provide [gabi](https://github.com/app-sre/gabi) to run SQL queries on protected databases.

In case you have lost access to a gabi instance for your service (an `Unauthorized` message) - the reason is likely the instance expiration. Submit a MR to extend the expiration date.

More information: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/gabi-instances-request.md
