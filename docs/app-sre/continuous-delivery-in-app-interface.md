# Continuous Delivery in App-interface

App-interface is a declarative interface to define everything.
Service owners are able to define their deployment flow using a SaaS file.

This functionality replaces the saasherder flow described [here](https://github.com/openshiftio/saasherder#the-process).

## Overview

A deployment process for a service is defined using a SaaS file. In a SaaS file, you define a list of resource templates to be deployed. For each such resource template, you define a url and path where the template can be found. You then define targets (namespaces) to deploy this template to.

In this context, deploying a resource template will usually consist in processing the Openshift template  via `oc process` and deploy it via `oc apply`. There is a way to deploy raw Openshift manifests, look below for the `provider` option.

You would usually define the main branch as the ref to be deployed to stage, and a specific commit SHA as the ref to be deployed to production. This means that a template's location is defined once, and deployed to multiple targets.

This structure -
- provides a notion of promotion - the same template is promoted across different environments (every targets is a namespace, and every namespace is associated to an environment)
- adds confidence that what worked in stage will also work in production and
- prevents inconsistencies between the resources deployed to each environment

## SaaS file structure

In order to define Continuous Delivery pipelines in app-interface, define a SaaS file with the following structure -

* `$schema` - should be `/app-sre/saas-file-2.yml` (Tekton provider)
* `labels` - a map of labels (currently not used by automation)
* `name` - name of saas file (usually starts with `saas-` and contains the name of the deployed app/service/component)
* `description` - description of the saas file (what is being deployed in this file)
* `app` - a reference to the application that this deployment is a part of
    * reference an app file, usually located under `/data/services/<service_name>/`
* `pipelinesProvider` - A reference to a Pipelines Provider file created in a Tekton [bootstrap](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/tekton/tekton-howto.md#bootstrap) phase.
* `deployResources` - It sets requests and limits for the `qontract-reconcile` step of the Task deploying the manifests. This overrides resources set via the saas file associated pipelines provider.
   * `requests`: Task step requests
       - `cpu`: cpu requests
       - `memory`: memory requests
   * `limits`: Task step requests
       - `cpu`: cpu limits
       - `memory`: memory limits
* `slack` - configure where to send notifications of success/failure of deployments
    * `output` - a type of output to use
        - `publish` - (default) publish jenkins job results using the slack publisher
        - `events` - publish the events that were carried out in the job as slack messages
    * `workspace` - a reference to a slack workspace
        * currently only `/dependencies/slack/coreos.yml` is supported.
    * `channel` - channel to send notifications to
* `managedResourceTypes` - a list of resource types to deploy (indicates that any other type is filtered out)
* `takeover` - (optional) if set to true, the specified `managedResourceTypes` will be managed exclusively
* `compare` - (optional) if set to false, the job does not compare desired to current resource and applies all resources even if they have not changed
* `timeout` - (optional) set a timeout in minutes for the deployment job ([default](https://gitlab.cee.redhat.com/service/app-interface/-/blob/2581e30973e9ead6611d6fa1b0fa7dc34d41e63d/resources/jenkins/global/defaults.yaml#L24))
* `publishJobLogs` - (optional) if this is a [saas file running post-deployment tests](/docs/app-sre/continuous-testing-in-app-interface.md), set this to `true` to publish Job's pods logs as artifacts in the Jenkins job.
* `clusterAdmin` - (optional) set this to `true` if the resources deployed in the saas file require cluster-admin permissions (CRDs for example).
* `imagePatterns` - a list of strings specifying allowed images to deploy
    * examples: `quay.io/app-sre`, `quay.io/prom/prometheus`
* `authentication` - specify credentials required to authenticate to `code` repository or to `image` registry
    * `code` - only required for private GitHub repositories
        * `path` - path to secret in Vault containing credentials
        * `field` - secret field (key) to use
    * `image` - only required for private images. Additional steps may be required to pull from private repos, [see this doc](/docs/app-sre/sop/make-registry-private.md) for more information.
        * `path` - path to secret in Vault containing credentials (should contain `config.json`, `user` and `token` keys)
        * `field` - should be `all`.
* `parameters` - (optional) parameters for `oc process` to be used in all resource templates in this saas file.
* `secretParameters` - (optional) a list of parameters from secrets in Vault for `oc process` to be used in all resource templates in this saas file.
    * `name` - name of parameter
    * `secret` - a description of a secret in Vault to get parameter value from.
        * `path` - path to secret in Vault containing credentials
        * `field` - secret field (key) to use
        * `version` - secret version to use (if this is a KV v2 secret engine)
* `resourceTemplates` - a list of configurations of OpenShift templates to deploy
    * `name` - a descriptive name of the deployed resources
    * `url` - git repository URL (https and not SSH)
    * `path` - path to file containing an OpenShift template in the repository
    * `provider` - (optional) specify what is the form of the resources in the specified url and path. options:
        * `openshift-template` - default, an OpenShift template that will be processed into resources and applied
        * `directory` - a directory containing raw manifests to be applied (not templated)
    * `targets` - a list of namespaces to deploy resources to
        * `namespace` - a reference to a namespace to deploy to
          * **Note:** a namespace should never be defined more than once in `targets`. Some users may wish to do this to deploy the same resources, but with different `parameters`, to a particular namespace. The correct approach for this use case is to create a separate entry in `resourceTemplates`, which will have a separate `targets` list.
        * `ref` - git ref to deploy (commit sha or branch name (usually `master`))
            * for deployments to a production namespace, always use a git commit hash
        * `promotion` - a section to indicate promotion behavior/validations
            * `publish` - a list of channels to publish the success of the deployment
            * `subscribe` - before deploying, validate that the current commit sha has been successfully deployed and published to the specified channels
            * `promotion_data` - This section is managed by the integrations. It includes data relative to what triggered a promotion. [more info](/docs/app-sre/saas-walkthrough.md#automated-promotions-with-configuration-changes)
        * `parameters` - (optional) parameters for `oc process` to be used when deploying to the current namespace
        * `secretParameters` - (optional) a list of parameters from secrets in Vault for `oc process` to be used in all resource templates in this saas file (description above).
        * `upstream` - (optional):
            * use this option in the case a docker image should be built before deployment
                * or any other script that should run prior to deployment
                * see [Continuous Integration in App-interface](/docs/app-sre/continuous-integration-in-app-interface.md) for more details
            * use this option only with a `ref` which is a branch (such as `master` or `main`). using it with a commit sha is not valid.
            - instance reference and job name to build after:
                * `instance` - reference to Jenkins instance where upstream job exists
                * `name` - name of the Jenkins job to use as upstream
        * `disable` - (optional) if set to `true`, target will be skipped during deployment.
        * `delete` - (optional) if set to `true`, resources coming from this target will be deleted.
    * `hash_length` - (optional) if `IMAGE_TAG` should be set according to the referenced target, specify a length to use from the commit hash.
        * default is set in [app-interface settings](/data/app-interface/app-interface-settings.yml#L31).


A complete example for github-mirror can be found [here](/data/services/github-mirror/cicd/deploy.yaml).

## Environment parameters

In addition to the parameters defined in the saas file, a deployment to each namespace will also use any parameters defined in the environment file referenced from the namespace. Read more on [Environments](/docs/app-interface/api/entities-and-relations.md).

Here is an example to parameters defined for the [insights-stage](/data/products/insights/environments/stage.yml) environment.

Environment parameters can be used to template saas file parameters. For example, if `ENV_PARAMETER` is defined in the environment file parameters, it can be reused in a saas file parameters: `SAAS_PARAMETER: ${ENV_PARAMETER}/api/example`.

Environment parameters can also be consumed from secrets in Vault, in the same way as described in the above structure section.

Environment parameters must not be duplicated. If defined in an environment file they cannot be defined again with the same value in a saas file consuming the environment.

## Automatically generated parameters

In addition to the supplied parameters, there are additional parameters which are generated automatically:

- `IMAGE_TAG` - The AppSRE deployments rely on image tags in one of the following forms:
  - `CHANNEL-{hash_substring}` if the saas file attribute `use_channel_in_image_tag` is set to `true`. In this case the `CHANNEL` parameter is mandatory.
  - `{hash_substring}` if the `use_channel_in_image_tag` saas file attribute is `false` or absent.

  where `{hash_substring}` is the first N (see `hash_length`) characters of the git repository commit hash.

  This parameter will be populated according to the above logic in order to deploy images by tags instead of `latest`.

  **Note**: The parameter will not be generated if it is explicitly specified in the SaaS file parameters.

- `REPO_DIGEST` - The full by-digest URI of a repository image.
  Equivalent to `{REGISTRY_IMG}@{IMAGE_DIGEST}`.
  This parameter will be populated in case an image needs to be deployed according to a digest and not a tag.
    * Note: These parameters are mandatory for `REPO_DIGEST` to be generated: `REGISTRY_IMG`, `IMAGE_TAG` (according to previous section).
- `IMAGE_DIGEST` - The digest of a repository image, in `{algorithm}:{hash}` form.
  This parameter will be populated in case an image needs to be deployed according to a digest and not a tag.
    * Note: These parameters are mandatory for `REPO_DIGEST` to be generated: `REGISTRY_IMG`, `IMAGE_TAG` (according to previous section).

## How does it work?

Every saas file contains a list of resources to deploy, and each resource contains a list of targets to deploy to.  Each target is a namespace, and each such namespace is associated to an environment.

For v1 SaaS files, A Jenkins job will be automatically created for each saas file and for each environment.  Each job executes an app-interface integration called `openshift-saas-deploy` for the specific saas file and environment.  The output will be similar to output you see in other app-interface integrations.

For v2 SaaS files, A generic Tekton Pipeline will be automatically created in the pipelines namespace ([bootstrap tekton](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/tekton/tekton-howto.md#bootstrap)). A Tekton PipelineRun will be created (deployment will be triggered) for each saas file and for each environment.  Each run executes an app-interface integration called `openshift-saas-deploy` for the specific saas file and environment.  The output will be similar to output you see in other app-interface integrations.

## What triggered a deployment?

Deployments are triggered due to 2 types of events:
1. a change in app-interface configuration
2. a new commit pushed to the main branch of the source code repository

Once a deployment was triggered, in the `YAML` section of a `PipelineRun` you will be able to find the integration that triggered a deployment and the reason it was triggered.

In the case of a configuration change to app-interface that is deemed to may impact how a service is deployed, a deployment will be triggered by an integration called `openshift-saas-deploy-trigger-configs`. In this case the reason will be a link to an app-interface commit.

In the case of a new commit to the source code repository - if there is a Jenkins job defined in the `upstream` section, a deployment will be triggered following a successful build by an integration called `openshift-saas-deploy-trigger-upstream-jobs`. In this case the reason will be a link to a job in Jenkins. If there is no Jenkins job, a deployment will be triggered by an integration called `openshift-saas-deploy-trigger-moving-commits`. In this case, the reason will be a link to a commit in the source code repository.

For more information, please follow [CI/CD - Builds, Triggers, Deployments and Promotions](/docs/app-sre/saas-walkthrough.md).

## Triggering PipelineRuns in Tekton

Whenever changes are detected for an environment, a saas file, a resource template or a target, the corresponding Tekton Pipeline will be triggered automatically by an automated creation of a PipelineRun resource.

To trigger a deployment manually, log in to OpenShift, navigate to the Pipelines page, find the `openshift-saas-deploy` Pipeline in your pipelines namespace and from the top right corner choose "Actions -> Start". Supply the name of the SaaS file and the name of the environment to deploy to. :warning: **NOTE:** In current versions of OpenShift 4.7, developers may not be able to trigger PipelineRuns via the web console due to a [known bug](https://bugzilla.redhat.com/show_bug.cgi?id=1949935). As a workaround, you can [use the `tkn` CLI tool](#triggering-pipelineruns-using-the-tkn-cli-tool).

To cancel a deployment manually, delete the active offending PipelineRun resource.

For more information on Environments: [Products, Environments, Namespaces and Apps](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-interface/api/entities-and-relations.md#products-environments-namespaces-and-apps)

Jobs are not being triggered? [follow this SOP](/docs/app-sre/sop/app-interface-saas-deploy-triggers-debug.md)

### Triggering PipelineRuns using the `tkn` CLI tool
The `tkn` tool provides an intuitive approach for managing Tekton pipelines from the command line and can be used to trigger new pipeline runs.

1. From the OpenShift console, open the Help menu and select the **Command line tools** option.
2. Download and extract the `oc` and `tkn` packages to a location in your binary path.
3. Follow the *Copy Login Command* link from the CLI tools page and login to the cluster using the provided `oc` command.
4. Use the `tkn pipeline start` command to trigger a new pipeline run.
  * For SaaS deploy pipelines, use:
  ```
  tkn pipeline start o-openshift-saas-deploy-<saas_file_name> \
    -p saas_file_name=<saas_file_name> \
    -p env_name=<environment> \
    -p tkn_cluster_console_url=<cluster console root url> \
    -p tkn_namespace_name=<namespace where the pipeline runs> \
    -n <openshift_project>
  ```
  The `tkn_cluster_console_url` and `tkn_namespace_name` can be found in app-interface through the Pipelines provider. They are only used in the metric emitted at the end of the pipeline run, so placeholders may be used if you're in a rush.
5. Follow the progress of the pipeline run via the `tkn pipelinerun logs` command provided or via the OpenShift console.

An example manual pipeline run:
```bash
$ tkn pipeline start o-openshift-saas-deploy-rhsm-api-proxy-clowder \
      -p saas_file_name=rhsm-api-proxy-clowder \
      -p env_name=insights-stage \
      -p tkn_cluster_console_url=https://console-openshift-console.apps.app-sre-prod-01.i7w5.p1.openshiftapps.co \
      -p tkn_namespace_name=crc-pipelines \
      -n crc-pipelines
PipelineRun started: openshift-saas-deploy-run-r2mkz

In order to track the PipelineRun progress run:
tkn pipelinerun logs openshift-saas-deploy-run-r2mkz -f -n crc-pipelines

```

## Approval process

Most MRs to app-interface require a review from the App SRE team.  Merging of MRs to saas files does NOT require an approval from App SRE and should be completely self serviced.

Each saas file must be referenced from at least one role under the `owned_saas_files` field. [Example](https://gitlab.cee.redhat.com/service/app-interface/-/blob/e40300ca8ebc2cc0be18cf09fa076bb7ebae4dd9/data/teams/app-sre/roles/app-sre.yml#L189-191). Each such role must be referenced from at least one user file. TL;DR - every saas file should have at least one owner.

Each user with this role can approve MRs by adding a `/lgtm` comment in the MR in the following cases -
- the MR only changes saas files that this user is an owner of and no other files
- the MR only changes one or more of the following fields in a saas file:
    - `ref`
    - `parameters`
    - `upstream`
    - `disable`
    - `deployResources`
- all tests are passing successfully
- approving user is an owner of the saas file in a merged version in app-interface (prevent privilege escalation). [Read more](/docs/app-sre/sop/app-interface-integrations-flow-and-failure-scenarios.md)

If a `/lgtm` comment is added and all conditions are valid, an `approved` label will be automatically added to the MR, and it will be automatically rebased and merged within a few minutes.

If any of the above conditions is not met, a member of the App SRE team needs to review the MR and label it with `lgtm` when it is good to go. Reviews are being performed regularly during working hours. As mentioned in the [app-interface etiquette](/README.md#app-interface-etiquette), no need to ping any App SRE team member.

Can I get pinged on merge requests updating saas files I am an approver for? Yes! Add `tag_on_merge_requests: true` to your user file.

Additional supported commands:
- `/lgtm cancel` - cancel previous LGTM comment (`bot/lgtm` label will be removed)
- `/hold` - prevents merging, does not cancel previous LGTM (`bot/approved` label will be removed, `bot/hold` label will be added)
- `/hold cancel` - cancels previous HOLD and follows existing LGTM comments  (`bot/hold` label will be removed)
- `/retest` - run tests again.

MR is not being merged? [follow this SOP](/docs/app-sre/sop/app-interface-periodic-job-debug.md)

## Automated/Gated promotions

By defining `promotion.publish` and `promotion.subscribe` on deployment `targets` you can add a validation that the commit being promoted was previously successfully deployed.

For example, define a `promotion.subscribe` to a production target and a `promotion.publish` to a stage post-deployment test target with a matching value (any unique string) to make the production deployment dependant on the success of the stage post-deployment tests.

Examples:

* Publish: [github-mirror stage post-deployment testing SaaS file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/fe22ed43d0cb46f1ac708cf86f9f569c1ffa5b68/data/services/github-mirror/cicd/test.yaml#L42-44)
* Subscribe: [github-mirror production deployment](https://gitlab.cee.redhat.com/service/app-interface/-/blob/fe22ed43d0cb46f1ac708cf86f9f569c1ffa5b68/data/services/github-mirror/cicd/deploy.yaml#L49-51)

To make the promotion process automated, set `promotion.auto` to `true`.

## Questions?

Reach out to us on #sd-app-sre in the CoreOS slack!

## Developer workflow

App-interface saas files are pluggable. If development teams wish to deploy to their development environment, they can add an additional `target` to an existing saas file.

For example, by adding a target with `ref: develop` and a namespace in a development environment, developers will get a continuous delivery pipeline from the `develop` branch to their namespace through the App SRE pipelines.

> Note: The [saasherder developer flow](https://github.com/openshiftio/saasherder/#run) hasn't changed, you can still use saasherder the same way you were using it, and everything will continue to work.

Want to manually deploy the same templates as deployed via app-interface?

To generate a pseudo script to assist in deployment, you can use the [qontract-cli tool](https://github.com/app-sre/qontract-reconcile).

First, create a `config.toml` file (place it in a directory called `config`).The config file should have the following structure:

```
[graphql]
server = "https://app-interface.devshift.net/graphql"
token = "Basic REDACTED"
```

To get a token to query app-interface, follow [these instructions](/README.md#querying-the-app-interface).

For example, to generate a script to deploy the `uhc` application, as deployed to the `osd-integration` environment, use the following command:

```
docker run \
    -v $PWD/config:/config:z \
    quay.io/app-sre/qontract-reconcile:latest \
    qontract-cli --config /config/config.toml \
    saas-dev --app-name uhc --env-name osd-integration
```
