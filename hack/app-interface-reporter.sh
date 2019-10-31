#!/bin/bash

echo "$CONFIG_TOML" | base64 -d > config.toml

docker run --rm -v $PWD/config.toml:/config.toml \
    quay.io/app-sre/qontract-reconcile:latest \
    app-interface-reporter \
    --config /config.toml \
    --gitlab-project-id 13582
