#!/bin/bash

ENV_FILE=".env"

if [ `uname` = "Darwin" ]; then
    SED_OPT=".bk"
fi

if [ -z "$1" ]; then
    NEW_SHA=$(curl -s -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/app-sre/user-validator/commits | \
        jq -r '.[0]|.sha')
else
    NEW_SHA="$1"
fi

NEW_COMMIT=${NEW_SHA::7}

OLD_COMMIT=$(awk -F "=" '{if ($1 == "export USER_VALIDATOR_IMAGE_TAG" && $2 ~ /^[a-f0-9]{7}$/){print $2}}' $ENV_FILE)
if [ "$NEW_COMMIT" != "$OLD_COMMIT" ]; then
    sed -i$SED_OPT "s/$OLD_COMMIT/$NEW_COMMIT/" $ENV_FILE
fi


if [ -n "$DO_COMMIT" ]; then
    git add $ENV_FILE $JENKINS_FILE $SAAS_FILE $SAAS_FILE_INT $TEKTON_GLOBAL_DEFAULTS
    git commit -m "user-validator production promotion ${OLD_COMMIT} to ${NEW_COMMIT}"
    git --no-pager show -U0 HEAD
fi
