#!/bin/bash

source ./.env

echo "$CONFIG_TOML" | base64 -d > config.toml

docker run --rm -v $PWD/config.toml:/config.toml \
    $RECONCILE_IMAGE:$RECONCILE_IMAGE_TAG \
    app-interface-reporter \
    --config /config.toml \
    --gitlab-project-id 13582 \
    --reports-path reports
