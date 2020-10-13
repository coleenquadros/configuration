# # Qontract Reconcile Timed Jobs debugging

## Background

The app-interface qontract-reconcile-timed jenkins jobs are executing the following:

```
#!/bin/bash

set -e -o pipefail -o errexit

# Write config.toml for reconcile tools
mkdir -p config
echo "$CONFIG_TOML" | base64 -d > config/config.toml
WORK_DIR=`pwd`

set -x
for integration in {integrations}; do
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
        {options} &
        pids+=($!)
done

for pid in "${{pids[@]}}"; do
    wait "$pid"
done
```
_Note:_ 
 - _{integrations} above is a variable replacement used with Jenkins Job Builder for integration run_
   - _Examples: gitlab-housekeeping, jenkins-job-builder, trigger-moving-commits, openshift-serviceaccount-tokens,  and slack-usergroups._
 - _{qontract-reconcile_image} above is a variable replacement used with Jenkins Job Builder for the image used._
 - _{options} above is a variable replacement used with Jenkins Job Builder for options passed to the integration._

## Purpose

This is an SOP for failure of the app-interface qontract-reconcile-timed jenkins jobs.

## Content

If this job fails, it means that one of the integrations is failing. To debug this, try the following:

### Jenkins Job Builder - jobs and templates:
[qontract_reconcile_timed jobs](/data/services/app-interface/cicd/ci-int/jobs.yaml#L72)
[qontract_reconcile_timed job-templates](/resources/jenkins/app-interface/jobs-templates.yaml#L125)
[qontract_reconcile base-templates](/resources/jenkins/global/base-templates.yaml#L384) 

### Run the integraions locally using this SOP:

[running-integrations-manually](/docs/app-sre/sop/running-integrations-manually.md)
