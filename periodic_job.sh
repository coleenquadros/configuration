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

run_int() {
  echo "INTEGRATION $1" >&2

  STARTTIME=$(date +%s)
  docker run --rm \
    -v `pwd`/config:/config:z \
    -w / \
    ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
    qontract-reconcile --config /config/config.toml $@ \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-${1}.txt
  EXIT_STATUS=$?
  ENDTIME=$(date +%s)

  echo "$1 $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/int_execution_duration_seconds.txt"

  if [ "$EXIT_STATUS" != "0" ]; then
    mv ${SUCCESS_DIR}/reconcile-${1}.txt ${FAIL_DIR}/reconcile-${1}.txt
    return 1
  fi

  return 0
}

APP_INTERFACE_PROJECT_ID=13582
HOUSEKEEPING_PROJECT_ID=4713

run_int slack-usergroups &
run_int github-users $APP_INTERFACE_PROJECT_ID &
run_int github-repo-invites &
run_int gitlab-housekeeping $APP_INTERFACE_PROJECT_ID &
run_int gitlab-housekeeping $HOUSEKEEPING_PROJECT_ID &
run_int gitlab-permissions &
run_int ldap-users $APP_INTERFACE_PROJECT_ID &
run_int aws-garbage-collector &

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
