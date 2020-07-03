# App-interface integrations promitions

## Background

App-interface integrations are being executed in multiple locations in multiple ways.  This SOP explains how to promote a new version of our integrations to each location.

## Process

* To promote integrations running in the app-sre-prod-01 cluster, update `hash` in [saas-app-interface](https://github.com/app-sre/saas-app-interface/blob/master/qontract-reconcile-services/qontract-reconcile.yaml).
* To promote integrations running in the app-interface periodic jobs running in ci-int, update `RECONCILE_IMAGE_TAG` in [.env](/.env).
* To promote openshift-saas-deploy version in all Jenkins jobs, update `qontract_reconcile_image` in [global defaults](/resources/jenkins/global/defaults.yaml).
