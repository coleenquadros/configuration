# Continuous Delivery in App-interface

App-interface is a declarative interface to define everything.
Service owners are able to define their deployment flow using a Saas file.

This functionality replaces the saasherder flow described [here](https://github.com/openshiftio/saasherder#the-process).

## SaaS file structure

In order to define Continuous Delivery pipelines in app-interface, define a SaaS file with the following structure:

* `$schema` - should be `/app-sre/saas-file-1.yml`
* `labels` - a map of labels (currently not used by automation)
* `name` - name of saas file (usually starts with `saas-` and contains the name of the deployed app/service/component)
* `description` - description of the saas file (what is being deployed in this file)
* `app` - a reference to the application that this deployment is a part of
    * reference an app file, usually located under `/data/services/<service_name>/`
* `instance` - Jenkins instance where generated deployment jobs run
    * options:
        - /dependencies/ci-ext/ci-ext.yml
        - /dependencies/ci-int/ci-int.yml
    * what to choose?
        * when in doubt, go with ci-int.
        * use ci-int if:
            - the deployed version of the service is considered sensitive information
            - the manifests to be deployed are in a gitlab repository
            - the manifests to be deployed are in a private github repository
        * otherwise, use ci-ext
* `slack` - configure where to send notifications of success/failure of deployments
    * `workspace` - a reference to a slack workspace
        * currently only `/dependencies/slack/coreos.yml` is supported.
    * `channel` - channel to send notifications to
* `managedResourceTypes` - a list of resource types to deploy (indicates that any other type is filtered out)
* `parameters` - (optional) parameters for `oc process` to be used in all resource templates in this saas file.
* `resourceTemplates` - a list of configurations of OpenShift templates to deploy
    * `name` - a descriptive name of the deplyoed resources
    * `url` - git repository URL (https and not SSH)
    * `path` - path to file containing an OpenShift template in the repository
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

A complete example for github-mirror can be found [here](/data/services/github-mirror/cicd/saas.yaml).

## Environment parameters

In addition to the parameters defined in the saas file, a deployment to each namespace will also use any parameters defined in the environment file referenced from the namespace. Read more on [Environments](/docs/app-interface/api/entities-and-relations.md).

Here is an example to parameters defined for the [insights-stage](/products/insights/environments/stage.yml) environment.

## How does it work?

Every saas file contains a list of resources to deploy, and each resource contains a list of targets to deploy to.  Each target is a namespace, and each such namespace is associated to an environment.

A Jenkins job will be automatically created for each saas file and for each environment.

Whenever changes are detected for an environment, a saas file, a resource template or a target, the corresponding Jenkins job will be triggered automatically.

Jobs are not being triggered? [follow this SOP](/docs/app-sre/sop/app-interface-saas-deploy-triggers-debug.md)

## Approval process

Most MRs to app-interface require a review from the App SRE team.  Merging of MRs to saas files does NOT require an approval from App SRE and should be completely self serviced.

Each saas file must be referenced from at least one role under the `owned_saas_files` field. [Example](/data/teams/app-sre/roles/app-sre.yml#L130-131)

Each user with this role can approve MRs by adding a `/lgtm` comment in the MR in the following cases:
- the MR only changes saas files that this user is an owner of and no other files
- all tests are passing succesfully 
- approving user is an owner of the saas file in a merged version in app-interface (prevent privilege escalation). [Read more](/docs/app-sre/sop/app-interface-integrations-flow-and-failure-scenarios.md)

If a `/lgtm` comment is added and all conditions are valid, an `approved` label will be automatically added to the MR, and it will be automatically rebased and merged within a few minutes.

MR is not being merged? [follow this SOP](/docs/app-sre/sop/app-interface-periodic-job-debug.md)

## Where do I sign?

The App SRE team will contact you directly to migrate any saas repos you have to saas files.

## Questions?

Ping @app-sre-ic on the CoreOS slack!
