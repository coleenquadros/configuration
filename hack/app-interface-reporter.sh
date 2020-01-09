#!/bin/bash

source ./.env

echo "$CONFIG_TOML" | base64 -d > config.toml

# clean reports
rm -rf reports; mkdir -p reports

# run reporter
docker run --rm \
    -u $(id -u):$(id -g) \
    -v $PWD/config.toml:/config.toml \
    -v $PWD/reports:/reports \
    $RECONCILE_IMAGE:$RECONCILE_IMAGE_TAG \
    app-interface-reporter \
    --config /config.toml \
    --gitlab-project-id 13582 \
    --reports-path /reports
