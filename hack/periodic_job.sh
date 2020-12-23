#!/bin/bash

set -exvo pipefail

source ./.env

# Run integrations

# Write config.toml for reconcile tools
mkdir -p config
echo "$CONFIG_TOML" | base64 -d > config/config.toml

SUCCESS_DIR=reports/reconcile_reports_success
FAIL_DIR=reports/reconcile_reports_fail
LOG_DIR=logs
rm -rf ${SUCCESS_DIR} ${FAIL_DIR} ${LOG_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR} ${LOG_DIR}

set +e

WORK_DIR=`pwd`
CURRENT_DIR=$(dirname "$0")
source $CURRENT_DIR/runners.sh

APP_INTERFACE_PROJECT_ID=13582

GRAPHQL_SERVER=https://${GRAPHQL_SERVER_BASE_URL}/graphql

run_int gitlab-projects

# TODO: move vault integration to run in a pod
run_vault_reconcile_integration &

# run_int jenkins-plugins &
run_int jenkins-roles &
run_int jenkins-webhooks &
run_int jenkins-webhooks-cleaner &
run_int gitlab-members &
run_int gitlab-permissions &
run_int gitlab-integrations &
run_int ldap-users $APP_INTERFACE_PROJECT_ID &
# run_int slack-usergroups &
run_int openshift-resources --internal &
run_int openshift-vault-secrets --internal &
# run_int terraform-resources --internal --light --vault-output-path app-sre/integrations-output &

SQS_GATEWAY=true run_int gitlab-mr-sqs-consumer $APP_INTERFACE_PROJECT_ID &

wait

print_execution_times
update_pushgateway
check_results
