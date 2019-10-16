#!/bin/bash

set -exvo pipefail

WORK_DIR=`pwd`
CURRENT_DIR=$(dirname "$0")
source ./.env
source $CURRENT_DIR/runners.sh

SCHEMAS_DIR=schemas

# Create data bundle
mkdir -p validate

docker run --rm \
  -v `pwd`/schemas:/schemas:z \
  -v `pwd`/graphql-schemas:/graphql-schemas:z \
  -v `pwd`/data:/data:z \
  -v `pwd`/resources:/resources:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /schemas /graphql-schemas/schema.yml /data /resources > validate/data.json

SHA256=$(sha256sum validate/data.json | awk '{print $1}')

# Upload to s3

aws s3 cp validate/data.json s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}

# wait for data to reload
wait_response \
    "https://${GRAPHQL_USERNAME}:${GRAPHQL_PASSWORD}@${GRAPHQL_SERVER_BASE_URL}/sha256" \
    "$SHA256"

if [ "$ENVIRONMENT" != "production" ]; then exit 0; fi

# Run integrations

# Write config.toml for reconcile tools
mkdir -p config
echo "$CONFIG_TOML" | base64 -d > config/config.toml

# Create directory for throughput between integrations
mkdir -p throughput

SUCCESS_DIR=reports/reconcile_reports_success
FAIL_DIR=reports/reconcile_reports_fail
rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

set +e

GRAPHQL_SERVER=https://${GRAPHQL_SERVER_BASE_URL}/graphql

run_int quay-repos &
run_vault_reconcile_integration &
run_int openshift-groups &
run_int openshift-users &
run_int jenkins-plugins &
run_int jenkins-roles &
run_int jenkins-job-builder &
run_int jenkins-webhooks &
run_int gitlab-members &
run_int gitlab-permissions &

run_int openshift-namespaces

run_int openshift-rolebinding &
run_int openshift-resources &
run_int openshift-network-policies &
run_int terraform-resources &
run_int terraform-users &

wait

print_execution_times
update_pushgateway

FAILED_INTEGRATIONS=$(ls ${FAIL_DIR} | wc -l)
if [ "$FAILED_INTEGRATIONS" != "0" ]; then
  exit 1
fi
