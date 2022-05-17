# Continuous Integration in App-interface

App-interface is a declarative interface to define everything.
Service owners are able to define their CI jobs using a jenkins config file.

## Jenkins config file structure

In order to define Continuous Integration pipelines in app-interface, define a Jenkins config file with the following structure -

* `$schema` - should be `/dependencies/jenkins-config-1.yml`
* `labels` - a map of labels (currently not used by automation)
* `name` - name of saas file (usually starts with `saas-` and contains the name of the deployed app/service/component)
* `description` - description of the saas file (what is being deployed in this file)
* `app` - a reference to the application that this deployment is a part of
    * reference an app file, usually located under /data/services/<service_name>/
* `instance` - Jenkins instance where generated deployment jobs run
    * options -
        - /dependencies/ci-ext/ci-ext.yml
        - /dependencies/ci-int/ci-int.yml
    * what to choose? refer to https://service.pages.redhat.com/dev-guidelines/docs/appsre/onboarding/continuous-integration/#guidelines
* `type` - usually should be `jobs`.
    * read this for [more information](/README.md#manage-jenkins-jobs-configurations-using-jenkins-jobs).
* `config` - a list of `project` objects. each project -
    * `name` - name of collection of jobs in this `project` (usually the name of the service)
    * `label` - Jenkins view to associate the job to
    * `node` - run these jobs on a Jenkins node with this label
    * `gh_org`/`gl_group` - github organization of gitlab group where the repository is found
    * `gh_repo`/`gl_project` - name of repository (a project in gitlab)
    * `quay_org` - if this jobs builds and pushes a docker image, specify the destination Quay organization
    * `jobs` - a list of jobs to create in this project. each job -
        * `<job_template_name>` - job template to be used.
            * `display_name` - display name of the Jenkins job
            * additional optional fields can be found in [advanced usage](https://gitlab.cee.redhat.com/service/dev-guidelines#cicd).

A complete example for github-mirror can be found [here](/data/services/github-mirror/cicd/deploy.yaml).

## How does it work?

Every jenkins config file contains a list of projects, and each project contains a list of jobs to create.  A Jenkins job will be automatically created for each jenkins config file and for each project and job.

## Additional setup

Add the repository to a `codeComponents` section in the matching application's app file.

ci-ext - follow these [requirements](https://gitlab.cee.redhat.com/service/dev-guidelines/-/blob/master/content/en/docs/AppSRE/Onboarding/continuous-integration.md#configuring-a-repo-to-work-with-ci-ext).

ci-int - add the `devtools-bot` as a Maintainer to your project.
