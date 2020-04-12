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

GRAPHQL_SERVER=https://${GRAPHQL_SERVER_BASE_URL}/graphql

STATE=true run_int openshift-saas-deploy &

wait

send_log
print_execution_times
update_pushgateway
check_results
