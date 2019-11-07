#!/bin/bash

set -exvo pipefail

WORK_DIR=`pwd`
CURRENT_DIR=$(dirname "$0")
source ./.env
source $CURRENT_DIR/runners.sh

SCHEMAS_DIR=schemas

# Setup
mkdir -p validate config throughput reports

# Create data bundle

docker run --rm \
  -v `pwd`/schemas:/schemas:z \
  -v `pwd`/graphql-schemas:/graphql-schemas:z \
  -v `pwd`/data:/data:z \
  -v `pwd`/resources:/resources:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /schemas /graphql-schemas/schema.yml /data /resources > validate/data.json

upload_s3 validate/data.json

if [ "$ENVIRONMENT" != "production" ]; then echo "bundle uploaded to $ENVIRONMENT" > reports/report; exit 0; fi

# Run integrations

# Write config.toml for reconcile tools

echo "$CONFIG_TOML" | base64 -d > config/config.toml

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
run_int aws-iam-keys &

run_int openshift-namespaces

run_int openshift-rolebindings &
run_int openshift-resources &
run_int openshift-network-policies &
run_int openshift-acme &
run_int openshift-limitranges &
run_int terraform-users &

run_int terraform-resources

# 2nd run is to delete disabled keys,
# has to run after terraform-resources is complete.
# can be removed once this goes back to running on the cluster.
ALIAS=aws-iam-keys-delete-service-account-tokens run_int aws-iam-keys &

wait

print_execution_times
update_pushgateway
check_integration_results
