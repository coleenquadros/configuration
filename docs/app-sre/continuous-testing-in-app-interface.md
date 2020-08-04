# Continuous Testing in App-interface

App-interface is a declarative interface to define everything.
Service owners are able to define their post deployment tests using a SaaS file.

## Overview

This SaaS file should deploy resources of kind `Job` to the same namespace as the application. The deployment of the Jobs should only be carried out after the application was deployed successfully.

The Jobs to deploy should be defined in a separate OpenShift template, and each Job name should end with `-{IMAGE_TAG}` so the jobs will be recreated after every update to the source code. The jobs from the previous round will be deleted automatically.

## Define post-deployment testing SaaS file

In order to define Continuous Testing pipelines in app-interface, define a SaaS file with a structure according to the [SaaS file structure](/docs/app-sre/continuous-delivery-in-app-interface.md#saas-file-structure), with the following specifications:
* `managedResourceTypes` - should be only `Job`
* `publishJobLogs` - (optional) if this is a [saas file running post-deployment tests](), set this to `true` to publish Jobs' pods logs as artifacts in the Jenkins job.
* `resourceTemplates.target.upstream` - set this to the name of the deployment job (`openshift-saas-deploy-<saas_file_name>-<environment_name>`)
    * `saas_file_name` is the name of the SaaS file deploying the application.
    * `environment_name` is the name of the environment that the namespace (to which the application is being deployed) is a part of. Read more on [Environments](/docs/app-interface/api/entities-and-relations.md).

A complete example for github-mirror can be found [here](/data/services/github-mirror/cicd/test.yaml).
