# Qontract Reconcile with Upstream Trigger Configs Job debugging

## Background

The app-interface qontract-reconcile-with-upstream-trigger-configs jenkins job is executing the following:

```
#!/bin/bash

set -e -o pipefail -o errexit

# Write config.toml for reconcile tools
mkdir -p config
echo "$CONFIG_TOML" | base64 -d > config/config.toml
WORK_DIR=`pwd`

set -x
for integration in openshift-saas-deploy-trigger-configs; do
    docker run --rm \
        -v $WORK_DIR/config:/config:z \
        -v /etc/pki:/etc/pki:z \
        -v /var/tmp/.cache:/root/.cache:z \
        -e REQUESTS_CA_BUNDLE=/etc/pki/tls/cert.pem \
        -e GITHUB_API=$GITHUB_API \
        -e APP_INTERFACE_STATE_BUCKET=$app_interface_state_bucket \
        -e APP_INTERFACE_STATE_BUCKET_ACCOUNT=$app_interface_state_bucket_account \
        -e UNLEASH_API_URL=$UNLEASH_API_URL \
        -e UNLEASH_CLIENT_ACCESS_TOKEN=$UNLEASH_CLIENT_ACCESS_TOKEN \
        {qontract_reconcile_image} \
        qontract-reconcile --config /config/config.toml $integration \
         &
        pids+=($!)
done

for pid in "${{pids[@]}}"; do
    wait "$pid"
done
```

_Note: {qontract-reconcile_image} above is a variable replacement used with Jenkins Job Builder for the image used._

## Purpose

This is an SOP for failure of the app-interface qontract-reconcile-with-upstream-trigger-configs jenkins job.

## Content

If this job fails, it means that openshift-saas-deploy-trigger-configs job is failing. To debug this, try the following:

### Jenkins Job Builder - jobs and templates:
- [openshift-saas-deploy-trigger-configs in jobs](/data/services/app-interface/cicd/ci-int/jobs.yaml#L66)
- [qontract_reconcile_with-upstream in job-templates](/resources/jenkins/app-interface/jobs-templates.yaml#L98)
- [qontract_reconcile in base-templates](/resources/jenkins/global/base-templates.yaml#L384) 

### Run the integraions locally using this SOP:

[running-integrations-manually](/docs/app-sre/sop/running-integrations-manually.md)
