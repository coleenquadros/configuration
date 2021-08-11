# App-Interface Frequently Asked Questions

This document serves as a first tier support for issues around app-interface.

For questions unanswered by this document, please ping @app-sre-ic in [#sd-app-sre](https://coreos.slack.com/messages/CCRND57FW) on CoreOS Slack.

## ToC

- [Can you merge my MR?](#can-you-merge-my-mr)
- [Contacting AppSRE](#contacting-appsre)
- [How can I get access to X?](#how-can-i-get-access-to-x)
- [I can not access X](#i-can-not-access-x)
- [I need help with something AWS related](#i-need-help-with-something-aws-related)
- [I can not access ci-ext](#i-can-not-access-ci-ext)
- [Tagging options in app-interface](#tagging-options-in-app-interface)
- [Gating production promotions in app-interface](#gating-production-promotions-in-app-interface)
- [Get access to cluster logs via Log Forwarding](#get-access-to-cluster-logs-via-log-forwarding)
- [What is the Console or Prometheus URL for a service?](#what-is-the-console-or-prometheus-url-for-a-service)
- [Can you restart my pods?](#can-you-restart-my-pods)
- [Delete target from SaaS file](#delete-target-from-saas-file)
- [Jenkins is going to shut down](#jenkins-is-going-to-shutdown)
- [How can I make my PR check job run concurrently?](#how-can-i-make-my-pr-check-job-run-concurrently)
- [How can I see who has access to a service?](#how-can-i-see-who-has-access-to-a-service)
- [Accessing DataHub](#accessing-datahub)
- [Jenkins Vault plugin upgrade](#jenkins-vault-plugin-upgrade)

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

Managed to log in but having issues? Maybe even seeing this error message? `"Access denied: <your-github-username> is missing the Overall/Read permission"`

1. Log out and log in again.
2. Revoke the `jenkins-ci-ext` Authorized OAuth app in [GitHub settings](https://github.com/settings/applications) and log in again.

### Tagging options in app-interface

GitLab: Users are not being tagged by default for SaaS file reviews. To be tagged on MRs for SaaS files you own, add `tag_on_merge_requests: true` to your user file.

Slack: Users are being tagged by default for cluster updates in clusters they have access to (through membership in a Slack usergroup called <cluster_name>-cluster). To be removed from those usergroups, add `tag_on_cluster_updates: false` to your user file.

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

1. Submit a MR to app-interface to add the [log-consumer](https://gitlab.cee.redhat.com/service/app-interface/-/blob/f0ca82a2253b4c213c8b438408f68113a662d6c1/data/aws/app-sre/roles/log-consumer.yml) role to your user file. You will also need to [add your public GPG key](https://gitlab.cee.redhat.com/service/app-interface#adding-your-public-gpg-key) (if you havn't already) in the same MR.
    * For console.redhat.com use the [log-consumer-crc](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/aws/app-sre/roles/log-consumer-crc.yml) role.
1. Once the MR is merged you will get an email invitation to join the AWS account (in this example - the `app-sre` account). Follow the instructions in the email to login to the account.
    * Note: in case you did not get an invitation, the login details can be obtained from the [Terraform-users Credentials](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/terraform-users-credentials.md) page.
    * Note: to decrypt the password: `echo <password> | base64 -d | gpg -d - && echo` (you will be asked to provide your passphrase to unlock the secret) 
1. Once you are logged in, go to [Security Credentials page](https://console.aws.amazon.com/iam/home?#/security_credentials) and enable Multi-factor authentication (MFA).
1. Logout and login to the account again using the configured MFA device.
1. Once you are logged in, navigate to the Switch Role link obtained from the [ocm-aws-infrastructure-access-switch-role-links](https://gitlab.cee.redhat.com/service/app-interface-output/-/blob/master/ocm-aws-infrastructure-access-switch-role-links.md) page (suggestion: add to bookmarks).
    * Note: search for your org_username for the cluster you want to view logs.
1. In the Switch Role page, select a name for this role (suggestion: `<cluster_name>-read-only`) and click "Switch Role" (Account and Role should be filled automatically).
1. You are now logged in to the cluster's AWS account. Go to the [CloudWatch console](https://console.aws.amazon.com/cloudwatch/home?#logsV2:log-groups) and get your logs!

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

### Delete target from SaaS file

To delete a target from a SaaS file, set `delete: true` in the target you wish to delete. This will cause all associated resources to be deleted in the next deployment. Follow this up with another MR to delete the target from the SaaS file.

More information: [Continuous Delivery in App-interface](/docs/app-sre/continuous-delivery-in-app-interface.md)

### Jenkins is going to shutdown

Problem:
Seeing this message in ci-ext - `Jenkins is going to shut down. No further builds will be performed`.

Reason:
Jenkins is configured to perform a [Thin backup](https://plugins.jenkins.io/thinBackup) periodically. It is recommended to perform the backup when no jobs are running. Jenkins will not schedule jobs during the waiting period (waiting for all running jobs to complete). No manual intervention is required, this is expected.

If a job is pending and need to be rushed, contact the App SRE team for assitance (canceling the current restart will get pending jobs to run, but will not cancel the backup).

### How can I make my PR check job run concurrently

Add `concurrent_build: true` to your job definition. [example](https://gitlab.cee.redhat.com/service/app-interface/blob/9e1185d/data/services/ocm/cicd/ci-int/jobs.yaml#L143)

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
