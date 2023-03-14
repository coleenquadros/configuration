#!/bin/bash
set -x
ENV_FILE=".env"
SAAS_FILE="data/services/app-interface/go-qontract-reconcile/cicd/saas-go-qontract-reconcile.yaml"

if [ `uname` = "Darwin" ]; then
    SED_OPT=".bk"
fi

if [ -z "$1" ]; then
    NEW_SHA=$(curl -s -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/app-sre/go-qontract-reconcile/commits | \
        jq -r '.[0]|.sha')
else
    NEW_SHA="$1"
fi

NEW_COMMIT=${NEW_SHA::7}

OLD_COMMIT=$(awk -F "=" '{if ($1 == "export GO_RECONCILE_IMAGE_TAG" && $2 ~ /^[a-f0-9]{7}$/){print $2}}' $ENV_FILE)
if [ "$NEW_COMMIT" != "$OLD_COMMIT" ]; then
    sed -i$SED_OPT "s/$OLD_COMMIT/$NEW_COMMIT/" $ENV_FILE
fi

OLD_SHA=$(awk '{if ($1 == "ref:" && $2 ~ /^[a-f0-9]{40}$/){print $2}}' $SAAS_FILE | uniq)
if [ "$NEW_SHA" != "$OLD_SHA" ]; then
    sed -i$SED_OPT "s/$OLD_SHA/$NEW_SHA/" $SAAS_FILE
fi

if [ -n "$DO_COMMIT" ]; then
    git add $ENV_FILE $SAAS_FILE
    git commit -m "go-qontract-reconcile production promotion ${OLD_COMMIT} to ${NEW_COMMIT}"
    git --no-pager show -U0 HEAD
fi
