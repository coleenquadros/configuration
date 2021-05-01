#!/bin/bash

ENV_FILE=".env"
JENKINS_FILE="resources/jenkins/global/defaults.yaml"
SAAS_FILE="data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml"
SAAS_FILE_INT="data/services/app-interface/cicd/ci-int/saas-qontract-reconcile-int.yaml"

if [ `uname` = "Darwin" ]; then
    SED_OPT=".bk"
fi

if [ -z "$1" ]; then
    NEW_SHA=$(curl -s -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/app-sre/qontract-reconcile/commits | \
        jq -r '.[1]|.sha')
else
    NEW_SHA="$1"
fi

NEW_COMMIT=${NEW_SHA::7}
OLD_SHA=$(awk '{if ($1 == "ref:" && $2 ~ /^[a-f0-9]{40}$/){print $2}}' $SAAS_FILE)

TAG_STATUS=$(curl -s https://quay.io/api/v1/repository/app-sre/qontract-reconcile/tag/$NEW_COMMIT/images | \
    jq .status)

if [ "$TAG_STATUS" = "404" ]; then
    echo "quay.io/app-sre/qontract-reconcile:$NEW_COMMIT not found"
    exit 1
fi

sed -i$SED_OPT "s/^export RECONCILE_IMAGE_TAG=.*$/export RECONCILE_IMAGE_TAG=$NEW_COMMIT/" $ENV_FILE
sed -E -i$SED_OPT "s/^(\s+qontract_reconcile_image_tag:).*$/\1 '$NEW_COMMIT'/" $JENKINS_FILE

if [ "$NEW_SHA" != "$OLD_SHA" ]; then
    sed -i$SED_OPT "s/$OLD_SHA/$NEW_SHA/" $SAAS_FILE $SAAS_FILE_INT
fi

if [ -n "$DO_COMMIT" ]; then
    git add $ENV_FILE $SAAS_FILE $JENKINS_FILE
    git commit -m "qontract production promotion ${OLD_COMMIT} to ${NEW_COMMIT}"
    git --no-pager show -U0 HEAD
fi
