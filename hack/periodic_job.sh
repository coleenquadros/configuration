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

CURRENT_DIR=$(dirname "$0")
source $CURRENT_DIR/runners.sh

APP_INTERFACE_PROJECT_ID=13582
HOUSEKEEPING_PROJECT_ID=4713

run_int github-users $APP_INTERFACE_PROJECT_ID &
run_int gitlab-housekeeping $APP_INTERFACE_PROJECT_ID &
run_int gitlab-housekeeping $HOUSEKEEPING_PROJECT_ID &
run_int gitlab-permissions &
run_int ldap-users $APP_INTERFACE_PROJECT_ID &

wait

echo
echo "Execution times for integrations that were executed"
(
  echo "Integration Seconds"
  sort -nr -k2 "${SUCCESS_DIR}/int_execution_duration_seconds.txt"
) | column -t
echo

FAILED_INTEGRATIONS=$(ls ${FAIL_DIR} | wc -l)

if [ "$FAILED_INTEGRATIONS" != "0" ]; then
  exit 1
fi

exit 0
