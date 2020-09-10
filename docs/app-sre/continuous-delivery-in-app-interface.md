# Continuous Delivery in App-interface

App-interface is a declarative interface to define everything.
Service owners are able to define their deployment flow using a SaaS file.

This functionality replaces the saasherder flow described [here](https://github.com/openshiftio/saasherder#the-process).

## SaaS file structure

In order to define Continuous Delivery pipelines in app-interface, define a SaaS file with the following structure -

* `$schema` - should be `/app-sre/saas-file-1.yml`
* `labels` - a map of labels (currently not used by automation)
* `name` - name of saas file (usually starts with `saas-` and contains the name of the deployed app/service/component)
* `description` - description of the saas file (what is being deployed in this file)
* `app` - a reference to the application that this deployment is a part of
    * reference an app file, usually located under `/data/services/<service_name>/`
* `instance` - Jenkins instance where generated deployment jobs run
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
* `slack` - configure where to send notifications of success/failure of deployments
    * `output` - a type of output to use
        - `publish` - (default) publish jenkins job results using the slack publisher
        - `events` - publish the events that were carried out in the job as slack messages
    * `workspace` - a reference to a slack workspace
        * currently only `/dependencies/slack/coreos.yml` is supported.
    * `channel` - channel to send notifications to
* `managedResourceTypes` - a list of resource types to deploy (indicates that any other type is filtered out)
* `takeover` - (optional) if set to true, the specified `managedResourceTypes` will be managed exclusively
* `compare` - (optional) if set to true, the job compares desired to current resource and only applies if it has changed
* `timeout` - (optional) set a timeout in minutes for the deployment job ([default](https://gitlab.cee.redhat.com/service/app-interface/-/blob/2581e30973e9ead6611d6fa1b0fa7dc34d41e63d/resources/jenkins/global/defaults.yaml#L24))
* `publishJobLogs` - (optional) if this is a [saas file running post-deployment tests](/docs/app-sre/continuous-testing-in-app-interface.md), set this to `true` to publish Jobs' pods logs as artifacts in the Jenkins job.
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
        * `parameters` - (optional) parameters for `oc process` to be used when deploying to the current namespace
        * `upstream` - (optional) name of Jenkins job to build after.
            * use this option in the case a docker image should be built before deployment
                * or any other script that should run prior to deployment
                * see [Continuous Integration in App-interface](/docs/app-sre/continuous-integration-in-app-interface.md) for more details
            * the `instance` should match the one where the upstream job runs.
        * `disable` - (optional) if set to `true`, target will be skipped during deployment.
    * `hash_length` - (optional) if `IMAGE_TAG` should be set according to the referenced target, specify a length to use from the commit hash.
        * default is set in [app-interface settings](/data/app-interface/app-interface-settings.yml#L31).


A complete example for github-mirror can be found [here](/data/services/github-mirror/cicd/deploy.yaml).

## Environment parameters

In addition to the parameters defined in the saas file, a deployment to each namespace will also use any parameters defined in the environment file referenced from the namespace. Read more on [Environments](/docs/app-interface/api/entities-and-relations.md).

Here is an example to parameters defined for the [insights-stage](/data/products/insights/environments/stage.yml) environment.

Environment parameters can be used to template saas file parameters. For example, if `ENV_PARAMETER` is defined in the environment file parameters, it can be reused in a saas file parameters: `SAAS_PARAMETER: ${ENV_PARAMETER}/api/example`.

## How does it work?

Every saas file contains a list of resources to deploy, and each resource contains a list of targets to deploy to.  Each target is a namespace, and each such namespace is associated to an environment.

A Jenkins job will be automatically created for each saas file and for each environment.  Each job executes an app-interface integration called `openshift-saas-deploy` for the specific saas file and environment.  The output will be similar to output you see in other app-interface integrations.

## Triggering jobs

Whenever changes are detected for an environment, a saas file, a resource template or a target, the corresponding Jenkins job will be triggered automatically.

Jobs are not being triggered? [follow this SOP](/docs/app-sre/sop/app-interface-saas-deploy-triggers-debug.md)

## Approval process

Most MRs to app-interface require a review from the App SRE team.  Merging of MRs to saas files does NOT require an approval from App SRE and should be completely self serviced.

Each saas file must be referenced from at least one role under the `owned_saas_files` field. [Example](/data/teams/app-sre/roles/app-sre.yml#L130-131). Each such role must be referenced from at least one user file. TL;DR - every saas file should have at least one owner.

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

## Where do I sign?

The App SRE team will contact you directly to migrate any saas repos you have to saas files.

## Questions?

Reach out to us on #sd-app-sre in the CoreOS slack!

## Future development

* add ability to define automated promotion flows

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
