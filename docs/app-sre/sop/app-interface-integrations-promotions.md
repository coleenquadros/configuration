# App-interface integrations promotions

## Background

App-interface integrations are being executed in multiple locations in multiple ways.  This SOP explains how to promote a new version of our integrations to each location.

## Process

* To promote integrations running in the app-sre-prod-01 cluster, update `ref` in [saas-qontract-reconcile](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml).
* To promote integrations running in appsres03ue1 or in appsrep05ue1 (internal clusters), update `ref` in [saas-qontract-reconcile-internal](data/services/app-interface/cicd/ci-int/saas-qontract-reconcile-int.yaml).
* To promote integrations running in the app-interface pr-check job running in ci-int, update `RECONCILE_IMAGE_TAG` in [.env](/.env).
* To promote openshift-saas-deploy version in all Jenkins jobs, update `qontract_reconcile_image_tag` in [global defaults](/resources/jenkins/global/defaults.yaml).
* To promote openshift-saas-deploy version in all Tekton pipelines, update `qontract_reconcile_image_tag` in [app-interface shared-resources](/data/services/app-interface/shared-resources).
    * Note: there may currently be additional shared-resources files containing `qontract_reconcile_image_tag`. It is usually needed to update all of them (search for `qontract_reconcile_image_tag`).
