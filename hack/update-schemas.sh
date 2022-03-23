#!/bin/bash

SCHEMAS_REPO="app-sre/qontract-schemas"
ENV_FILE=".env"

NEW_SHA=$(curl -s -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/${SCHEMAS_REPO}/commits | \
    jq -r '.[0]|.sha')

if sed --version &> /dev/null
then
    # GNU sed
    sed -i "s/SCHEMAS_IMAGE_TAG=.*/SCHEMAS_IMAGE_TAG=${NEW_SHA::7}/" $ENV_FILE
else
    # BSD sed (MacOS)
    sed -i '' "s/SCHEMAS_IMAGE_TAG=.*/SCHEMAS_IMAGE_TAG=${NEW_SHA::7}/" $ENV_FILE
fi
