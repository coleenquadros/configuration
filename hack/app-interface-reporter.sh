#!/bin/bash

source ./.env

echo "$CONFIG_TOML" | base64 -d > config.toml

# clean reports
mkdir -p reports
docker run --rm -v $PWD/reports:/reports busybox find /reports -mindepth 1 -delete

# run reporter
docker run --rm \
    -v $PWD/config.toml:/config.toml \
    -v $PWD/reports:/reports \
    $RECONCILE_IMAGE:$RECONCILE_IMAGE_TAG \
    app-interface-reporter \
    --config /config.toml \
    --gitlab-project-id 13582 \
    --reports-path /reports
