# App-interface integrations promotions

## Background

App-interface integrations are being executed in multiple locations in multiple ways.  This SOP explains how to promote a new version of our integrations to each location.

## Process

* To promote integrations running in the app-sre-prod-01 cluster, update `ref` in [saas-app-interface](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-interface/cicd/ci-ext/saas.yaml).
* To promote integrations running in the app-interface periodic jobs running in ci-int, update `RECONCILE_IMAGE_TAG` in [.env](/.env).
* To promote openshift-saas-deploy version in all Jenkins jobs, update `qontract_reconcile_image_tag` in [global defaults](/resources/jenkins/global/defaults.yaml).
* To promote qontract-reconcile based jobs (timed/with-upstream), update `qontract_reconcile_image_tag` in the job definition (will override the default from the previous section).
