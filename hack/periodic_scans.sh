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

run_int github-scanner $APP_INTERFACE_PROJECT_ID &
run_int aws-support-cases-sos $APP_INTERFACE_PROJECT_ID &

wait

print_execution_times
check_integration_results
