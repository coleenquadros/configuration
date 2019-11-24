#!/bin/bash

set -exvo pipefail

source ./.env

# Run integrations

# Write config.toml for reconcile tools
mkdir -p config
echo "$CONFIG_TOML" | base64 -d > config/config.toml

SUCCESS_DIR=reports/reconcile_reports_success
FAIL_DIR=reports/reconcile_reports_fail
rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

set +e

WORK_DIR=`pwd`
CURRENT_DIR=$(dirname "$0")
source $CURRENT_DIR/runners.sh

APP_INTERFACE_PROJECT_ID=13582
HOUSEKEEPING_PROJECT_ID=4713

run_int gitlab-housekeeping $APP_INTERFACE_PROJECT_ID &
run_int gitlab-housekeeping $HOUSEKEEPING_PROJECT_ID &
run_int gitlab-permissions &
run_int ldap-users $APP_INTERFACE_PROJECT_ID &
run_int slack-usergroups &

SQS_GATEWAY=true run_int gitlab-pr-submitter $APP_INTERFACE_PROJECT_ID &

wait

print_execution_times
update_pushgateway
check_integration_results
