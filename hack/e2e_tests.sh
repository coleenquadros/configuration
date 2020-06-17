#!/bin/bash

set -exvo pipefail

source ./.env

# Run tests

# Write config.toml for e2e tests
mkdir -p config
echo "$CONFIG_TOML" | base64 -d > config/config.toml

SUCCESS_DIR=reports/e2e_tests_reports_success
FAIL_DIR=reports/e2e_tests_reports_fail
rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

set +e

WORK_DIR=`pwd`
CURRENT_DIR=$(dirname "$0")
source $CURRENT_DIR/runners.sh

run_test create-namespace --thread-pool-size 1 &
run_test dedicated-admin-rolebindings --thread-pool-size 1 &
run_test default-project-labels --thread-pool-size 1 &
run_test default-network-policies --thread-pool-size 1 &

wait

echo
echo "Execution times for tests that were executed"
(
  echo "Tests Seconds"
  sort -nr -k2 "${SUCCESS_DIR}/test_execution_duration_seconds.txt"
) | column -t
echo

check_results
