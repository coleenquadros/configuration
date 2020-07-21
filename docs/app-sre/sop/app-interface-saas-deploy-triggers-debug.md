# Periodic openshift-saas-deploy-triggers Job debugging

## Background

This job triggers Jenkins jobs to deploy changes declared in saas files in app-interface.
The job runs once a minute and executes the [periodic_saas_deploy_triggers.sh](/hack/periodic_saas_deploy_triggers.sh) script.

This script runs the following integrations:
- `openshift-saas-deploy-moving-commits` - Trigger a job in case a commit changed under a reference such as `master`.
- `openshift-saas-deploy-configs` - Trigger a job in case a configuration changed in app-interface (new target, updated ref, etc).  In case a configuration changes during a run of an upstream job, the trigger will be sent and the job should wait for upstream job to succeed.

## Purpose

This is an SOP for failure of the openshift-saas-deploy-triggers job.

## Failure scenarios

### Failure due to app-interface data reload

This happens when the data is reloaded. The job will be marked as unstable and this can be safely ignored for now.

### Failure to trigger a job in Jenkins

In case the request to trigger a job in Jenkins failed, the integrations will fail and retry in the next execution.

Look into Jenkins' health at this point.

### Failure to persist state

These integrations are stateful and use S3 as their backend. If S3 can not be reached, the integrations will fail. A symptom may be multiple triggers of the same job.

## Run integrations locally to further debug

To run the integrations locally follow the [running-integrations-manually](/docs/app-sre/sop/running-integrations-manually.md) SOP.

Since the integrations are stateful, you will need to do the following:
```
export APP_INTERFACE_STATE_BUCKET=app-interface-production
export APP_INTERFACE_STATE_BUCKET_ACCOUNT=app-sre
```
