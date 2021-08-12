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

* `$schema` - should be `/app-sre/saas-file-1.yml` (Jenkins provider) or `/app-sre/saas-file-2.yml` (Tekton provider)
* `labels` - a map of labels (currently not used by automation)
* `name` - name of saas file (usually starts with `saas-` and contains the name of the deployed app/service/component)
* `description` - description of the saas file (what is being deployed in this file)
* `app` - a reference to the application that this deployment is a part of
    * reference an app file, usually located under `/data/services/<service_name>/`
* `instance` - (v1 SaaS file) Jenkins instance where generated deployment jobs run
    * options -
        - /dependencies/ci-ext/ci-ext.yml
        - /dependencies/ci-int/ci-int.yml
    * what to choose?
        * when in doubt, go with ci-int.
        * use ci-int if -
            - the deployed version of the service is considered sensitive information
            - the manifests to be deployed are in a gitlab repository
            - the manifests to be deployed are in a private github repository
        * otherwise, use ci-ext
* `pipelinesProvider` - (v2 SaaS file) A reference to a Pipelines Provider file created in a Tekton [bootstrap](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/tekton/tekton-howto.md#bootstrap) phase.
* `slack` - configure where to send notifications of success/failure of deployments
    * `output` - a type of output to use
        - `publish` - (default) publish jenkins job results using the slack publisher
        - `events` - publish the events that were carried out in the job as slack messages
    * `workspace` - a reference to a slack workspace
        * currently only `/dependencies/slack/coreos.yml` is supported.
    * `channel` - channel to send notifications to
    * not yet supported for v2 SaaS files.
* `managedResourceTypes` - a list of resource types to deploy (indicates that any other type is filtered out)
* `takeover` - (optional) if set to true, the specified `managedResourceTypes` will be managed exclusively
* `compare` - (optional) if set to false, the job does not compare desired to current resource and applies all resources even if they have not changed
* `timeout` - (optional) set a timeout in minutes for the deployment job ([default](https://gitlab.cee.redhat.com/service/app-interface/-/blob/2581e30973e9ead6611d6fa1b0fa7dc34d41e63d/resources/jenkins/global/defaults.yaml#L24))
* `publishJobLogs` - (optional) if this is a [saas file running post-deployment tests](/docs/app-sre/continuous-testing-in-app-interface.md), set this to `true` to publish Jobs' pods logs as artifacts in the Jenkins job.
* `clusterAdmin` - (optional) set this to `true` if the resources deployed in the saas file require cluster-admin permissions (CRDs for example).
* `imagePatterns` - a list of strings specifying allowed images to deploy
    * examples: `quay.io/app-sre`, `quay.io/prom/prometheus`
* `authentication` - specify credentials required to authenticate to `code` repository or to `image` registry
    * `code` - only required for private GitHub repositories
        * `path` - path to secret in Vault containing credentials
        * `field` - secret field (key) to use
    * `image` - only required for private images
        * `path` - path to secret in Vault containing credentials (should contain `config.json`, `user` and `token` keys)
        * `field` - should be `all`.
* `parameters` - (optional) parameters for `oc process` to be used in all resource templates in this saas file.
* `resourceTemplates` - a list of configurations of OpenShift templates to deploy
    * `name` - a descriptive name of the deplyoed resources
    * `url` - git repository URL (https and not SSH)
    * `path` - path to file containing an OpenShift template in the repository
    * `provider` - (optional) specify what is the form of the resources in the specified url and path. options:
        * `openshift-template` - default, an OpenShift template that will be processed into resources and applied
        * `directory` - a directory containing raw manifests to be applied (not templated)
    * `targets` - a list of namespaces to deploy resources to
        * `namespace` - a reference to a namespace to deploy to
        * `ref` - git ref to deploy (commit sha or branch name (usually `master`))
            * for deployments to a production namespace, always use a git commit hash
        * `promotion` - a section to indicate promotion behavior/validations
            * `publish` - a list of channels to publish the success of the deployment
            * `subscribe` - before deploying, validate that the current commit sha has been successfully deployed and published to the specified channels
        * `parameters` - (optional) parameters for `oc process` to be used when deploying to the current namespace
        * `upstream` - (optional):
            * use this option in the case a docker image should be built before deployment
                * or any other script that should run prior to deployment
                * see [Continuous Integration in App-interface](/docs/app-sre/continuous-integration-in-app-interface.md) for more details
            - (v1 SaaS file) name of Jenkins job to build after.
                *  the `instance` should match the one where the upstream job runs.
            - (v2 SaaS file) instance reference and job name to build after:
                * `instance` - reference to Jenkins instance where upstream job exists
                * `name` - name of the Jenkins job to use as upstream
            * not yet supported for v2 SaaS files.
        * `disable` - (optional) if set to `true`, target will be skipped during deployment.
        * `delete` - (optional) if set to `true`, resources coming from this target will be deleted.
    * `hash_length` - (optional) if `IMAGE_TAG` should be set according to the referenced target, specify a length to use from the commit hash.
        * default is set in [app-interface settings](/data/app-interface/app-interface-settings.yml#L31).


A complete example for github-mirror can be found [here](/data/services/github-mirror/cicd/deploy.yaml).

## Environment parameters

In addition to the parameters defined in the saas file, a deployment to each namespace will also use any parameters defined in the environment file referenced from the namespace. Read more on [Environments](/docs/app-interface/api/entities-and-relations.md).

Here is an example to parameters defined for the [insights-stage](/data/products/insights/environments/stage.yml) environment.

Environment parameters can be used to template saas file parameters. For example, if `ENV_PARAMETER` is defined in the environment file parameters, it can be reused in a saas file parameters: `SAAS_PARAMETER: ${ENV_PARAMETER}/api/example`.

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

## Migrating from saas-file-1 (Jenkins provider) to saas-file-2 (Tekton-provider)

Follow the migration instructions in https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/tekton/tekton-howto.md#migration

## Triggering jobs in Jenkins

Whenever changes are detected for an environment, a saas file, a resource template or a target, the corresponding Jenkins job will be triggered automatically.

To trigger a job manually, log in to Jenkins and hit "Build".

Jobs are not being triggered? [follow this SOP](/docs/app-sre/sop/app-interface-saas-deploy-triggers-debug.md)

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
  tkn pipeline start openshift-saas-deploy \
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
$ tkn pipeline start openshift-saas-deploy \
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
    - `disable`
- all tests are passing succesfully 
- approving user is an owner of the saas file in a merged version in app-interface (prevent privilege escalation). [Read more](/docs/app-sre/sop/app-interface-integrations-flow-and-failure-scenarios.md)

If a `/lgtm` comment is added and all conditions are valid, an `approved` label will be automatically added to the MR, and it will be automatically rebased and merged within a few minutes.

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
