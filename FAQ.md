# App-Interface Frequently Asked Questions

This document serves as a first tier support for issues around app-interface.

For questions unanswered by this document, please ping @app-sre-ic in [#sd-app-sre](https://coreos.slack.com/messages/CCRND57FW) on CoreOS Slack.

## ToC

- [Contacting AppSRE](#contacting-appsre)
- [How can I get access to X](#how-can-i-get-access-to-x)
- [I can not access X](#i-can-not-access-x)
- [I can not access ci-ext](#i-can-not-access-ci-ext)
- [What is the Console or Kibana URL for a service](#what-is-the-console-or-kibana-url-for-a-service)
- [Jenkins is going to shut down](#jenkins-is-going-to-shutdown)
- [How can I make my PR check job run concurrently](#how-can-i-make-my-pr-check-job-run-concurrently)
- [How can I see who has access to a service](#how-can-i-see-who-has-access-to-a-service)
- [How to determine my AWS permissions](#how-to-determine-my-aws-permissions)
- [Accessing DataHub](#accessing-datahub)

## Useful links

- [Visual App-Interface](https://visual-app-interface.devshift.net)

## Topics

### Contacting AppSRE

You can catch the AppSRE team in the `#sd-app-sre` channel of `coreos.slack.com`.

To create a request, please open an issue in the [APPSRE Project](https://issues.redhat.com/projects/APPSRE/issues) in JIRA.

For *time sensitive* requests, please ping `@app-sre-ic` in the `#sd-app-sre` channel.

If you have an urgent matter affecting production that needs to be addressed as soon as possible, please do the following:

- Ping `@app-sre-emea` or `@app-sre-nasa` depending on the time of the day.
- If you get no response, and if it's truly critical follow the [Paging AppSRE team](docs/app-sre/paging-appsre-oncall.md) guide.

### How can I get access to X

Start by accessing the Visual App-Interface at https://visual-app-interface.devshift.net.  Using the side bar, navigate to the [Permissions](https://visual-app-interface.devshift.net/permissions) section.

Find a permission that matches the access you require. For this example, choose [ci-ext](https://visual-app-interface.devshift.net/permissions#/dependencies/ci-ext/permissions/ci-ext.yml)

choosing a permission will take you to the Permission's page, in which you can view a list of `Roles` who grant this permission.  Choose the role that best matches your requirement and submit a merge request to app-interface adding that role to your user file.

### I can not access X

This may be caused due to several reasons. Follow this procedure:

1. Follow the "How can I get access to X" story and make sure you are assigned a role that enables the desired access.
2. Be sure to accept the GitHub invitation at https://github.com/app-sre

### I can not access ci-ext

Start by following [I can not access X](#i-can-not-access-x)

Problem: I Can not log in to https://ci.ext.devshift.net.

Managed to log in but having issues? Maybe even seeing this error message? `"Access denied: <your-github-username> is missing the Overall/Read permission"`

1. Log out and log in again.
2. Revoke the `jenkins-ci-ext` Authorized OAuth app in [GitHub settings](https://github.com/settings/applications) and log in again.

### What is the Console or Kibana URL for a service

Start by accessing the Visual App-Interface at https://visual-app-interface.devshift.net.  Using the side bar, navigate to the [Services](https://visual-app-interface.devshift.net/services) section.

Choose the relevant service from the list. For example, [cincinnati](https://visual-app-interface.devshift.net/services#/services/cincinnati/app.yml).

Choosing the service will take you to the the service's page, in which you can view a list of `Namespaces` which are related to this service.  In this example the namespaces are:
- `cincinnati-production`
- `cincinnati-stage`

Choose the namespace for which you would like to find the Console/Kibana URL. For this example, choose [cincinnati-stage](https://visual-app-interface.devshift.net/namespaces#/services/cincinnati/namespaces/cincinnati-stage.yml).

Choosing the namespace will take you to the namespace's page, in which you can find a link to the cluster running this namespace.

In the Cluster page, you can find links to the cluster's Console and to the cluster's Kibana.

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

Choose the relevant service from the list. For example, [telemeter](https://visual-app-interface.devshift.net/services#/services/telemeter/app.yml).

Choosing the service will take you to the the service's page, in which you can view a list of `Namespaces` which are related to this service.  In this example the namespaces are:
- `telemeter-production`
- `telemeter-stage`

Choose the namespace for which you would like to see the users. For this example, choose [telemeter-production](https://visual-app-interface.devshift.net/namespaces#/services/telemeter/namespaces/telemeter-production.yml).

Choosing the namespace will take you to the namespace's page, in which you can view a list of `Roles` which are associated with this namespace.  Some of the roles in this namespace are:
- `dev`
- `view`

Choosing a role will take you to the Role's page, in which you can view a list of `Users` who have this role associated to them, and the namespace access granted through this role.  To finalize this example, choose the [dev](https://visual-app-interface.devshift.net/roles#/teams/telemeter/roles/dev.yml) role to see a list of users who has this role.

The users in this page are granted a `view` permission in the `telemeter-production` namespace through the `dev` role.

### How to determine my AWS permissions

Your user file contains a list of `roles`. Each AWS related role contains a list of AWS groups and/or AWS user policies.
To determine what are your permissions, follow the `$ref` to the AWS group or user policy, and read the description field.

For example:

The role `/teams/devtools/roles/f8a-dev-osio-dev.yml` leads to the [corresponding role file](/data/teams/devtools/roles/f8a-dev-osio-dev.yml).
This role file has the user policy `/aws/osio-dev/policies/OwnResourcesFullAccess.yml`, which leads to the [corresponding user policy file](/data/aws/osio-dev/policies/OwnResourcesFullAccess.yml).
This user policy file a description, which explains the permissions allowed by this user policy.

### Accessing DataHub

DataHub is not managed by the AppSRE team, but you can find the process to request access here: https://help.datahub.redhat.com/docs/interacting-with-telemetry-data
