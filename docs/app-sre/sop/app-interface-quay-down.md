# Quay.io is down SOP

## Background

If quay.io is down, we want to keep app-interface functional.

## Purpose

This is an SOP to list the actions to be performed to make app-interface operational when quay.io is down.

## Content

To make app-interface operational, search for all occurences of the following string across the app-interface repository:
```
# replace the above line if quay.io is down
```

In every found occurence, comment out the line above and un-comment the line below (update the image tag if it has changed)

This will replace all relevant images to be used from gcr.io instead of from quay.io, enabling our pipelines to keep running.

This includes:
- app-interface pr-check jobs
- app-interface build-master jobs
- app-interface periodic jobs (integrations, saas-deploy triggers, e2e tests)
- openshift-saas-deploy jobs

In addition, disable the quay integrations in Unleash.
