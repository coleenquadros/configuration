#!/bin/bash

ENV_FILE=".env"
JENKINS_FILE="resources/jenkins/global/defaults.yaml"
TEKTON_TEMPLATE="data/services/app-interface/shared-resources/app-sre-pipelines.yml \
data/services/telemeter-ocp-dashboards/namespaces/telemeter-ocp-dashboards-pipelines.appsrep05ue1.yaml \
data/services/github-mirror/shared-resources/github-mirror-pipelines.yml"
SAAS_FILE="data/services/app-interface/cicd/ci-ext/saas-qontract-reconcile.yaml"
SAAS_FILE_INT="data/services/app-interface/cicd/ci-int/saas-qontract-reconcile-int.yaml"

if [ `uname` = "Darwin" ]; then
    SED_OPT=".bk"
fi

if [ -z "$1" ]; then
    NEW_SHA=$(curl -s -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/app-sre/qontract-reconcile/commits | \
        jq -r '.[0]|.sha')
else
    NEW_SHA="$1"
fi

NEW_COMMIT=${NEW_SHA::7}

TAG_STATUS=$(curl -s https://quay.io/api/v1/repository/app-sre/qontract-reconcile/tag/$NEW_COMMIT/images | \
    jq .status)

if [ "$TAG_STATUS" = "404" ]; then
    echo "quay.io/app-sre/qontract-reconcile:$NEW_COMMIT not found"
    exit 1
fi

OLD_COMMIT=$(awk '{gsub("\047", "", $2); if ($1 == "qontract_reconcile_image_tag:" && $2 ~ /^[a-f0-9]{7}$/){print $2}}' $JENKINS_FILE)
if [ "$NEW_COMMIT" != "$OLD_COMMIT" ]; then
    sed -i$SED_OPT "s/$OLD_COMMIT/$NEW_COMMIT/" $JENKINS_FILE
fi

for template in $TEKTON_TEMPLATE; do
    OLD_COMMIT=$(awk '{gsub("\047", "", $2); if ($1 == "qontract_reconcile_image_tag:" && $2 ~ /^[a-f0-9]{7}$/){print $2}}' $template)
    if [ "$NEW_COMMIT" != "$OLD_COMMIT" ]; then
        sed -i$SED_OPT "s/$OLD_COMMIT/$NEW_COMMIT/" $template
    fi
done

OLD_COMMIT=$(awk -F "=" '{if ($1 == "export RECONCILE_IMAGE_TAG" && $2 ~ /^[a-f0-9]{7}$/){print $2}}' $ENV_FILE)
if [ "$NEW_COMMIT" != "$OLD_COMMIT" ]; then
    sed -i$SED_OPT "s/$OLD_COMMIT/$NEW_COMMIT/" $ENV_FILE
fi

OLD_SHA=$(awk '{if ($1 == "ref:" && $2 ~ /^[a-f0-9]{40}$/){print $2}}' $SAAS_FILE)
if [ "$NEW_SHA" != "$OLD_SHA" ]; then
    sed -i$SED_OPT "s/$OLD_SHA/$NEW_SHA/" $SAAS_FILE
fi

OLD_SHA=$(awk '{if ($1 == "ref:" && $2 ~ /^[a-f0-9]{40}$/){print $2}}' $SAAS_FILE_INT)
if [ "$NEW_SHA" != "$OLD_SHA" ]; then
    sed -i$SED_OPT "s/$OLD_SHA/$NEW_SHA/" $SAAS_FILE_INT
fi

if [ -n "$DO_COMMIT" ]; then
    git add $ENV_FILE $JENKINS_FILE $SAAS_FILE $SAAS_FILE_INT
    for template in $TEKTON_TEMPLATE; do
        git add $template
    done
    git commit -m "qontract production promotion ${OLD_COMMIT} to ${NEW_COMMIT}"
    git --no-pager show -U0 HEAD
fi
