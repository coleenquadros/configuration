# Quay.io is down SOP

## Background

If quay.io is down, we want to keep app-interface functional.

## Purpose

This is an SOP to list the actions to be performed to make app-interface operational when quay.io is down.

Note: This SOP currently uses stage.quay.io as the fallback. This is planned to be replaced with ECR in the near future.

## Content

To make app-interface operational, search for all occurences of the following string across the app-interface repository:
```
# replace the above line if quay.io is down (this is a stopgap)
```

In every found occurence, comment out the line above and un-comment the line below (update the image tag if it has changed)

This will replace all relevant images to be used from stage.quay.io instead of from quay.io, enabling our pipelines to keep running.

This includes:
- app-interface pr-check jobs
- app-interface build-master jobs
- app-interface periodic jobs (integrations, saas-deploy triggers, e2e tests)
- openshift-saas-deploy jobs
- saasherder saas-pr-check jobs
- saasherder saas-deploy jobs
