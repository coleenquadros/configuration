# Migrate CodeReady Analytics services to App SRE standards

## Overview

This process serves several purposes:
- Migrate off ci.centos.org (related to [APPSRE-2140](https://issues.redhat.com/browse/APPSRE-2140))
- Split CodeReady Analytics out of openshift.io (related to [SDE-1050](https://issues.redhat.com/browse/SDE-1050))
- Move from saasherder to current App SRE deployment method ([openshift-saas-deploy](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md))

This guide lists the steps required to migrate a service from -> to:
1. Build: ci.centos -> ci.ext
1. Container images: quay.io/openshiftio -> quay.io/app-sre
1. Deployment: saas repos (saasherder) -> saas files (openshift-saas-deploy)

This guide will use [fabric8-analytics-worker](https://github.com/fabric8-analytics/fabric8-analytics-worker) as an example.

## Steps

### Build

1. Define image repositories in quay.io/app-sre

    The first part of this effort is to build the code in [ci.ext](https://ci.ext.devshift.net) and push the images to quay.io/app-sre. To be able to build the images we need to be able to pull the base images (used in the Dockerfiles' `FROM` statement).

    Most services are building two images, one of which is RHEL based. To build a RHEL based image, most services rely on a private RHEL base image located in quay.io/openshiftio. Since we only expose a single set of quay.io credentials in our pipelines, we can't pull a private image from quay.io/openshiftio and push to quay.io/app-sre. Hence, we will need to start by mirroring any image dependencies from quay.io/openshiftio to quay.io/app-sre.

    For fabric8-analytics-worker, [Dockerfile.rhel](https://github.com/fabric8-analytics/fabric8-analytics-worker/blob/f98ebb858e7383b06ae39163ef582b76373b06e3/Dockerfile.rhel) uses quay.io/openshiftio/rhel-fabric8-analytics-f8a-worker-base as a base image, so we'll need to mirror this image to quay.io/app-sre.

    * ACTION ITEM: Submit a MR to app-interface to mirror and/or build any images which are dependencies for building the service's image.
        * Examples:
            - https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15360
            - https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15370
            - https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15385

    > Pro tip: You can submit a single MR for the entire `Build` section.

    > Note: at a later point we will want to move the base image build jobs to push directly to quay.io/app-sre, but [this is currently not possible](https://gitlab.cee.redhat.com/service/app-interface/-/blob/093bf933062f64565ebc93b3b63dd9f60104bbcf/data/services/openshift.io/cicd/ci-int/jobs.yaml#L47-55).

    In addition to the base images, we will also need image repositories for the service images.

    For fabric8-analytics-worker, The images can be found in the [Makefile](https://github.com/fabric8-analytics/fabric8-analytics-worker/blob/f98ebb858e7383b06ae39163ef582b76373b06e3/Makefile#L5-L11).

    To keep all previous image tags we need to create new quay repos in quay.io/app-sre that will also mirror the content from the old quay repo in quay.io/openshiftio

    * ACTION ITEM: Submit a MR to app-interface to add quay repos for the service images.
        * Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15365

1. Define build jobs in ci.ext

    For each image used by the service (not the `FROM` base images) we need to define a job to build and push the image.

    For fabric8-analytics-worker, we are building and pushing two images, so we will need to create two jobs. Since one of the images is RHEL based, we will need to run this job on a RHEL based Jenkins node.

    * ACTION ITEM: Submit a MR to app-interface to add jenkins jobs for the service images
        * Examples:
            - https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15368
            - https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15371

1. Define build scripts in source code repository

    In the previous section we created two jobs to build and push the service images. By default, the jobs will run a script that will be located in the code repository (defined in the `build_deploy_script_path` variable). We now need to create the matching scripts in the code repository.

    * ACTION ITEM: Submit a PR to the code repository to add scripts to build and push the service images.
        * Example: https://github.com/fabric8-analytics/fabric8-analytics-worker/pull/950

    > Note: To pull and push to quay.io/app-sre we need to duplicate the Dockerfiles. These will be cleaned up in a following step.

    You will also need to define a Push webhook in the code repository.

    * ACTION ITEM: Go to https://github.com/{org}/{repo}/settings/hooks and add a webhook:
        * Payload URL: https://ci.ext.devshift.net/github-webhook/
        * Which events would you like to trigger this webhook? Just the push event

1. Validate jobs success

    Once all above MRs/PRs are merged, go to the [CodeReady-Analytics view in ci.ext](https://ci.ext.devshift.net/view/codeready-analytics/), find the new jobs and make sure their last result is a success. If not, try to debug to understand the issues and iterate until success.

### Deploy

1. Update OpenShift deployment manifests to include a ServiceAccount

    If the service is using private images, you need to add an `imagePullSecrets` section to DeploymentConfigs which mounts a private pull secret.

    * ACTION ITEM: Submit a PR to the code repository to add/update OpenShift deployment manifests.
        * Example: https://github.com/fabric8-analytics/fabric8-analytics-worker/pull/956

1. Remove webhooks to ci.centos.org

    Since the service is now deployed to stage through app-interface, we no longer need to trigger builds in ci.centos.

    * ACTION ITEM: Go to https://github.com/{org}/{repo}/settings/hooks and delete webhooks:
        * Payload URL: https://ci.centos.org/*

1. Define saas file to deploy the service to the stage (preview) environment

    A saas file is the newer version of a saas repository. A single file can (and should _not_) replace an entire saas repository. We will define a new saas file for each service we migrate in this process. The documentation exists [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/continuous-delivery-in-app-interface.md).

    The saas file structure is very similar to the saas repo service.

    For fabric8-analytics-worker, this is the [saas service](https://github.com/openshiftio/saas-analytics/blob/master/bay-services/worker.yaml) which we will need to translate to the saas file.

    * ACTION ITEM: Submit a MR to app-interface to add a saas file for the service and deploy it to stage.
        * Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15378

    > Note: in this MR we are commenting out all the production targets. It is easier to add all targets in a single effort and commenting out.

1. Remove the saas service file from the saas repository

    This is to avoid having the service deployed from both app-interface and the saas repository.

    * ACTION ITEM: Submit a PR to the saas repository removing the saas service file.
        * Example: https://github.com/openshiftio/saas-analytics/pull/943

1. Deploy from saas file to production

    Once the service has been deployed and validated in stage, we can now deploy to production. The service is already deployed, but we are taking over the deployment in this step.

    * ACTION ITEM: Submit a MR to app-interface to uncomment all production targets from the saas file introduced in the previous section.
        * Example: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/15508

### Cleanup

1. Remove duplications introduced in previous steps from code repository

    * ACTION ITEM: Submit a PR to the service code repository to undo any duplications made in previous steps.
        * Example: https://github.com/fabric8-analytics/fabric8-analytics-worker/pull/952

1. Remove definitions from app-interface

    In this final cleanup, we will remove resources from app-interface:
    - job definitions
    - unused job templates
    - quay repositories mirroring
    - quay repositories
    - code repositories from openshift.io app file

    * ACTION ITEM: Submit a MR to app-interface to remove any job definitions and templates used by the service
        * Example: TBD
