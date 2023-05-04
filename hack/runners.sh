#!/bin/bash

run_int() {
  local rc

  INTEGRATION_NAME="${ALIAS:-$1}"
  [ -n "$DRY_RUN" ] && DRY_RUN_FLAG="--dry-run"
  [ -n "$SQS_GATEWAY" ] && GITLAB_PR_SUBMITTER_QUEUE_URL_ENV="-e gitlab_pr_submitter_queue_url=$gitlab_pr_submitter_queue_url"
  [ -n "$STATE" ] && APP_INTERFACE_STATE_ENV="-e APP_INTERFACE_STATE_BUCKET=$app_interface_state_bucket -e APP_INTERFACE_STATE_BUCKET_ACCOUNT=$app_interface_state_bucket_account"
  [ -n "$NO_GQL_SHA_URL" ] && NO_GQL_SHA_URL_FLAG="--no-gql-sha-url"
  [ -n "$NO_VALIDATE" ] && NO_VALIDATE="--no-validate-schemas"
  [ -z "$IMAGE" ] && IMAGE="$RECONCILE_IMAGE_TAG"
  if [ -n "$EARLY_EXIT" ] && [ -n "$MASTER_BUNDLE_SHA256" ]; then
    EARLY_EXIT_ENV="-e EARLY_EXIT_COMPARE_SHA=$MASTER_BUNDLE_SHA256"
  fi
  [ -n "$CHECK_ONLY_AFFECTED_SHARDS" ] && CHECK_ONLY_AFFECTED_SHARDS_ENV="-e CHECK_ONLY_AFFECTED_SHARDS=true"

  echo "INTEGRATION $INTEGRATION_NAME" >&2

  STARTTIME=$(date +%s)
  docker run --rm \
    -v ${WORK_DIR}/config:/config:z \
    -v /etc/pki:/etc/pki:z \
    -v ${WORK_DIR}/throughput:/throughput:z \
    -v /var/tmp/.cache:/root/.cache:z \
    -e GITHUB_API=$GITHUB_API \
    -e UNLEASH_API_URL=$UNLEASH_API_URL \
    -e UNLEASH_CLIENT_ACCESS_TOKEN=$UNLEASH_CLIENT_ACCESS_TOKEN \
    -e REQUESTS_CA_BUNDLE=/etc/pki/tls/cert.pem \
    $GITLAB_PR_SUBMITTER_QUEUE_URL_ENV \
    $APP_INTERFACE_STATE_ENV \
    $EARLY_EXIT_ENV \
    $CHECK_ONLY_AFFECTED_SHARDS_ENV \
    -e CHANGE_TYPE_PROCESSING_MODE=${CHANGE_TYPE_PROCESSING_MODE:-"limited"} \
    -e RECONCILE_IMAGE_TAG=$IMAGE \
    -w / \
    --memory 5g \
    ${RECONCILE_IMAGE}:${IMAGE} \
    qontract-reconcile --config /config/config.toml $NO_VALIDATE $DRY_RUN_FLAG $NO_GQL_SHA_URL_FLAG --no-gql-url-print $@ \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-${INTEGRATION_NAME}.txt

  rc="$?"
  ENDTIME=$(date +%s)

  duration="app_interface_int_execution_duration_seconds{integration=\"$INTEGRATION_NAME\"} $((ENDTIME - STARTTIME))"
  echo $duration >> "${SUCCESS_DIR}/int_execution_duration_seconds.txt"

  if [ -d "$LOG_DIR" ] && [ -s "${SUCCESS_DIR}/reconcile-${INTEGRATION_NAME}.txt" ];then
    setting=${-//[^x]/}
    [ -n "$setting" ] && set +x
    echo "[" > ${LOG_DIR}/${INTEGRATION_NAME}.log

    while read line
    do
      if [ "$line" ];then
      message=$(echo $line|sed 's/\"/\\\"/g')
      cat >> ${LOG_DIR}/${INTEGRATION_NAME}.log <<EOF
  {
    "timestamp": $(date +%s000),
    "message": "$message"
  },
EOF
      fi
    done < ${SUCCESS_DIR}/reconcile-${INTEGRATION_NAME}.txt

    sed -i '$d' ${LOG_DIR}/${INTEGRATION_NAME}.log
    cat >> ${LOG_DIR}/${INTEGRATION_NAME}.log <<EOF
  }
]
EOF
  [ -n "$setting" ] && set -x
  fi

  if [ "$rc" != "0" ]; then
    echo "INTEGRATION FAILED: $1" >&2
    mv ${SUCCESS_DIR}/reconcile-${INTEGRATION_NAME}.txt ${FAIL_DIR}/reconcile-${INTEGRATION_NAME}.txt
  fi

  return $rc
}

run_vault_reconcile_integration() {
  local status

  [ -n "$DRY_RUN" ] && DRY_RUN_FLAG="-dry-run"
  echo "INTEGRATION vault" >&2

  STARTTIME=$(date +%s)
  docker run --rm -t \
    -e GRAPHQL_SERVER=${GRAPHQL_SERVER} \
    -e GRAPHQL_USERNAME=${GRAPHQL_USERNAME} \
    -e GRAPHQL_PASSWORD=${GRAPHQL_PASSWORD} \
    -e VAULT_ADDR=https://vault.devshift.net \
    -e VAULT_AUTHTYPE=approle \
    -e VAULT_ROLE_ID=${VAULT_MANAGER_ROLE_ID} \
    -e VAULT_SECRET_ID=${VAULT_MANAGER_SECRET_ID} \
    ${VAULT_RECONCILE_IMAGE}:${VAULT_RECONCILE_IMAGE_TAG} $DRY_RUN_FLAG \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-vault.txt

  status="$?"
  ENDTIME=$(date +%s)

  # Add integration run durations to a file
  echo "app_interface_int_execution_duration_seconds{integration=\"vault\"} $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/int_execution_duration_seconds.txt"

  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: vault" >&2
    mv ${SUCCESS_DIR}/reconcile-vault.txt ${FAIL_DIR}/reconcile-vault.txt
  fi

  return $status
}

run_git_partition_sync_integration() {
  local status

  echo "INTEGRATION git-partition-sync" >&2

  STARTTIME=$(date +%s)
  docker run --rm -t \
    -v /etc/pki:/etc/pki:z \
    -e DRY_RUN=true \
    -e RUN_ONCE=true \
    -e GRAPHQL_SERVER=${GRAPHQL_SERVER} \
    -e GRAPHQL_USERNAME=${GRAPHQL_USERNAME} \
    -e GRAPHQL_PASSWORD=${GRAPHQL_PASSWORD} \
    -e AWS_ACCESS_KEY_ID=${GIT_SYNC_AWS_ACCESS_KEY_ID} \
    -e AWS_SECRET_ACCESS_KEY=${GIT_SYNC_AWS_SECRET_ACCESS_KEY} \
    -e AWS_REGION=${GIT_SYNC_AWS_REGION} \
    -e AWS_GIT_SYNC_BUCKET=${GIT_SYNC_AWS_S3_BUCKET} \
    -e GITLAB_BASE_URL=${GIT_SYNC_GITLAB_BASE_URL}\
    -e GITLAB_USERNAME=${GIT_SYNC_GITLAB_USERNAME} \
    -e GITLAB_TOKEN=${GIT_SYNC_GITLAB_TOKEN} \
    -e PUBLIC_KEY=${GIT_SYNC_PUBLIC_KEY} \
    -e WORKDIR=git-partition-sync \
    ${GO_RECONCILE_IMAGE}:${GO_RECONCILE_IMAGE_TAG} git-partition-sync-producer \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-git-partition-sync.txt

  status="$?"
  ENDTIME=$(date +%s)

  # Add integration run durations to a file
  echo "app_interface_int_execution_duration_seconds{integration=\"git-partition-sync\"} $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/int_execution_duration_seconds.txt"

  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: git-partition-sync" >&2
    mv ${SUCCESS_DIR}/reconcile-git-partition-sync.txt ${FAIL_DIR}/reconcile-git-partition-sync.txt
  fi

  return $status
}

run_account_notifier() {
  local status

  STARTTIME=$(date +%s)
  [ -n "$STATE" ] && APP_INTERFACE_STATE_ENV="-e APP_INTERFACE_STATE_BUCKET=$app_interface_state_bucket -e APP_INTERFACE_STATE_BUCKET_ACCOUNT=$app_interface_state_bucket_account"

  docker run --rm -t \
    -v ${WORK_DIR}/config:/config:z \
    -e GRAPHQL_SERVER=${GRAPHQL_SERVER} \
    -e DRY_RUN=true \
    $APP_INTERFACE_STATE_ENV \
    -e RUN_ONCE=true \
    ${GO_RECONCILE_IMAGE}:${GO_RECONCILE_IMAGE_TAG} account-notifier -c /config/config.toml \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-account-notifier.txt

  status="$?"
  ENDTIME=$(date +%s)

  # Add integration run durations to a file
  echo "app_interface_int_execution_duration_seconds{integration=\"account-notifier\"} $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/int_execution_duration_seconds.txt"

  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: account-notifier" >&2
    mv ${SUCCESS_DIR}/reconcile-account-notifier.txt ${FAIL_DIR}/reconcile-account-notifier.txt
  fi

  return $status
}


run_user_validator() {
  local status

  STARTTIME=$(date +%s)

  docker run --rm -t \
    -e GRAPHQL_SERVER=${GRAPHQL_SERVER} \
    -e GRAPHQL_USERNAME=${GRAPHQL_USERNAME} \
    -e GRAPHQL_PASSWORD=${GRAPHQL_PASSWORD} \
    -e GITHUB_API=${GITHUB_API} \
    -e RUNNER_USE_FEATURE_TOGGLE=true \
    -e VAULT_SERVER=https://vault.devshift.net \
    -e VAULT_AUTHTYPE=approle \
    -e VAULT_ROLE_ID=${USER_VALIDATOR_ROLE_ID} \
    -e UNLEASH_API_URL=$UNLEASH_API_URL \
    -e UNLEASH_CLIENT_ACCESS_TOKEN=$UNLEASH_CLIENT_ACCESS_TOKEN \
    -e VAULT_SECRET_ID=${USER_VALIDATOR_SECRET_ID} \
    ${GO_RECONCILE_IMAGE}:${GO_RECONCILE_IMAGE_TAG} user-validator \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-user-validator.txt

  status="$?"
  ENDTIME=$(date +%s)

  # Add integration run durations to a file
  echo "app_interface_int_execution_duration_seconds{integration=\"user-validator\"} $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/int_execution_duration_seconds.txt"

  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: user-validator" >&2
    mv ${SUCCESS_DIR}/reconcile-user-validator.txt ${FAIL_DIR}/reconcile-user-validator.txt
  fi

  return $status
}

send_log() {
  BUILDTIME=$(date -d "$BUILD_TIMESTAMP" +%s000)

  if [ -d "$LOG_DIR" ];then
    for file in ${LOG_DIR}/*
    do
      INTEGRATION_NAME=$(basename ${file} .log)
      log_stream=$(aws logs describe-log-streams --log-group-name $LOG_GROUP_NAME|grep \"$INTEGRATION_NAME\"|cut -d'"' -f4)
      [ -z "$log_stream" ] && aws logs create-log-stream --log-group-name $LOG_GROUP_NAME --log-stream-name $INTEGRATION_NAME
      Token=$(aws logs describe-log-streams --log-group-name $LOG_GROUP_NAME --log-stream-name-prefix $INTEGRATION_NAME|grep Token|cut -d'"' -f4)
      [ -z "$Token" ] && Token=$(aws logs put-log-events --log-group-name $LOG_GROUP_NAME --log-stream-name $INTEGRATION_NAME --log-events timestamp=$BUILDTIME,message="$JOB_URL"|grep Token|cut -d'"' -f4)
      aws logs put-log-events --log-group-name $LOG_GROUP_NAME --log-stream-name $INTEGRATION_NAME --sequence-token $Token --log-events file://$file &
    done
  fi
}

print_execution_times() {
    echo
    echo "Execution times for integrations that were executed"
    (
      echo "Integration Seconds"
      sort -nr -k2 "${SUCCESS_DIR}/int_execution_duration_seconds.txt"
    ) | column -t
    echo
}

check_results() {
    FAILED_COUNT=$(ls ${FAIL_DIR} | wc -l)

    if [ "$FAILED_COUNT" != "0" ]; then
      CONFLICT=$(find ${FAIL_DIR} -type f -exec cat {} + | grep -e "409: Conflict" -e "Data changed during execution. This is fine." | wc -l)
      RATE_LIMITED=$(find ${FAIL_DIR} -type f -exec cat {} + | grep "ratelimited" | wc -l)
      [ "$CONFLICT" == "0" ] && [ "$RATE_LIMITED" == "0" ] && FAIL_EXIT_STATUS=1 || FAIL_EXIT_STATUS=80
      exit $FAIL_EXIT_STATUS
    fi
}

wait_response() {
    local count=1
    local max=10

    URL=$1
    EXPECTED_RESPONSE=$2

    while [[ ${count} -le ${max} ]]; do
        let count++ || :
        RESPONSE=$(curl -s $URL)
        [[ "$EXPECTED_RESPONSE" == "$RESPONSE" ]] && break || sleep $count
    done

    if [[ "$EXPECTED_RESPONSE" != "$RESPONSE" ]]; then
      echo "Invalid response." >&2
      echo "Expecting:\n$EXPECTED_RESPONSE" >&2
      echo "Got:\n$RESPONSE" >&2
      exit 1
    fi
}

upload_s3() {
    INPUT_FILE=$1
    GIT_COMMIT=$2

    SHA256=$(sha256sum $INPUT_FILE | awk '{print $1}')
    aws s3 cp $INPUT_FILE s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}
    aws s3 cp s3://${AWS_S3_BUCKET}/${AWS_S3_KEY} s3://${AWS_S3_BUCKET}/bundle-archive/${GIT_COMMIT}.json
    wait_response \
        "https://${GRAPHQL_USERNAME}:${GRAPHQL_PASSWORD}@${GRAPHQL_SERVER_BASE_URL}/sha256" \
        "$SHA256"
}


download_s3() {
    GIT_COMMIT=$1
    OUTPUT_FILE=$2
    S3_PATH="s3://${AWS_S3_BUCKET}/bundle-archive/${GIT_COMMIT}.json"
    echo "wait 30s for ${S3_PATH} to exist"
    timeout 30 aws s3api wait object-exists --bucket ${AWS_S3_BUCKET} --key bundle-archive/${GIT_COMMIT}.json
    if [ $? -ne 0 ]; then
      echo "master bundle ${S3_PATH} does not exit"
      return 1
    fi
    aws s3 cp --quiet ${S3_PATH} ${OUTPUT_FILE}
    if [ $? -ne 0 ]; then
      echo "failed to download bundle ${S3_PATH}"
      return 2
    fi
    return 0
}

update_pushgateway() {
    echo "Sending Integration execution times to Push Gateway"

    (echo '# TYPE app_interface_int_execution_duration_seconds gauge'; \
      echo '# HELP app_interface_int_execution_duration_seconds App-interface integration run times in seconds'; \
      cat ${SUCCESS_DIR}/int_execution_duration_seconds.txt) | \
      curl -v -X POST -s -H "Authorization: Basic ${PUSHGW_CREDS}" --data-binary @- $PUSHGW_URL/metrics/job/$JOB_NAME
}
