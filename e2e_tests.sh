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

run_test() {
  echo "TEST $1" >&2

  STARTTIME=$(date +%s)
  docker run --rm \
    -v `pwd`/config:/config:z \
    -v /etc/pki:/etc/pki:z \
    -v `pwd`/throughput:/throughput:z \
    -w / \
    -e REQUESTS_CA_BUNDLE=/etc/pki/tls/cert.pem \
    ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
    e2e-tests --config /config/config.toml $@ \
    2>&1 | tee ${SUCCESS_DIR}/e2e-test-${1}.txt
  EXIT_STATUS=$?
  ENDTIME=$(date +%s)

  echo "$1 $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/test_execution_duration_seconds.txt"

  if [ "$EXIT_STATUS" != "0" ]; then
    mv ${SUCCESS_DIR}/e2e-test-${1}.txt ${FAIL_DIR}/e2e-test-${1}.txt
    return 1
  fi

  return 0
}

run_test create-namespace &
run_test dedicated-admin-rolebindings &

wait

echo
echo "Execution times for tests that were executed"
(
  echo "Tests Seconds"
  sort -nr -k2 "${SUCCESS_DIR}/test_execution_duration_seconds.txt"
) | column -t
echo

FAILED_TESTS=$(ls ${FAIL_DIR} | wc -l)

if [ "$FAILED_TESTS" != "0" ]; then
  exit 1
fi

exit 0
