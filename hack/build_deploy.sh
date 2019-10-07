#!/bin/bash

set -exvo pipefail

source ./.env

wait_response() {
    local count=0
    local max=10

    URL=$1
    EXPECTED_RESPONSE=$2

    while [[ ${count} -lt ${max} ]]; do
        let count++ || :
        RESPONSE=$(curl -s $URL)
        [[ "$EXPECTED_RESPONSE" == "$RESPONSE" ]] && break || sleep 10
    done

    if [[ "$EXPECTED_RESPONSE" != "$RESPONSE" ]]; then
      echo "Invalid response." >&2
      echo "Expecting:\n$EXPECTED_RESPONSE" >&2
      echo "Got:\n$RESPONSE" >&2
      exit 1
    fi
}

SCHEMAS_DIR=schemas

# Create data bundle
mkdir -p validate

docker run --rm \
  -v `pwd`/schemas:/schemas:z \
  -v `pwd`/graphql-schemas:/graphql-schemas:z \
  -v `pwd`/data:/data:z \
  -v `pwd`/resources:/resources:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /schemas /graphql-schemas/schema.yml /data /resources > validate/data.json

SHA256=$(sha256sum validate/data.json | awk '{print $1}')

# Upload to staging and reload

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_STAGING
export AWS_REGION=$AWS_REGION_STAGING
export AWS_S3_BUCKET=$AWS_S3_BUCKET_STAGING
export AWS_S3_KEY=$AWS_S3_KEY_STAGING
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_STAGING

export USERNAME=$USERNAME_STAGING
export PASSWORD=$PASSWORD_STAGING

aws s3 cp validate/data.json s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}

curl "https://${USERNAME}:${PASSWORD}@app-interface.stage.devshift.net/reload"

wait_response \
    "https://${USERNAME}:${PASSWORD}@app-interface.stage.devshift.net/sha256" \
    "$SHA256"

# Upload to production and reload

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID_PRODUCTION
export AWS_REGION=$AWS_REGION_PRODUCTION
export AWS_S3_BUCKET=$AWS_S3_BUCKET_PRODUCTION
export AWS_S3_KEY=$AWS_S3_KEY_PRODUCTION
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY_PRODUCTION

export USERNAME=$USERNAME_PRODUCTION
export PASSWORD=$PASSWORD_PRODUCTION

aws s3 cp validate/data.json s3://${AWS_S3_BUCKET}/${AWS_S3_KEY}

curl "https://${USERNAME}:${PASSWORD}@app-interface.devshift.net/reload"

wait_response \
    "https://${USERNAME}:${PASSWORD}@app-interface.devshift.net/sha256" \
    "$SHA256"

# Run integrations

# Write config.toml for reconcile tools
mkdir -p config
echo "$CONFIG_TOML" | base64 -d > config/config.toml

# Create directory for throughput between integrations
mkdir -p throughput

SUCCESS_DIR=reports/reconcile_reports_success
FAIL_DIR=reports/reconcile_reports_fail
rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

set +e

GRAPHQL_SERVER=https://app-interface.devshift.net/graphql

WORK_DIR=`pwd`
CURRENT_DIR=$(dirname "$0")
source $CURRENT_DIR/runners.sh

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

run_int openshift-namespaces

run_int openshift-rolebinding &
run_int openshift-resources &
run_int openshift-network-policies &
run_int terraform-resources &
run_int terraform-users &

wait

echo
echo "Execution times for integrations that were executed"
(
  echo "Integration Seconds"
  sort -nr -k2 "${SUCCESS_DIR}/int_execution_duration_seconds.txt"
) | column -t
echo

# Set Pushgateway credentials
export PUSHGW_CREDS_PROD=$PUSH_GATEWAY_CREDENTIALS_PROD
export PUSHGW_URL_PROD=$PUSH_GATEWAY_URL_PROD
export PUSHGW_CREDS_STAGE=$PUSH_GATEWAY_CREDENTIALS_STAGE
export PUSHGW_URL_STAGE=$PUSH_GATEWAY_URL_STAGE

echo "Sending Integration execution times to Push Gateway"

(echo '# TYPE app_interface_int_execution_duration_seconds gauge'; \
  echo '# HELP app_interface_int_execution_duration_seconds App-interface integration run times in seconds'; \
  cat ${SUCCESS_DIR}/int_execution_duration_seconds.txt) | \
  tee >(curl -X POST -s -H "Authorization: Basic ${PUSHGW_CREDS_PROD}" --data-binary @- $PUSHGW_URL_PROD/metrics/job/$JOB_NAME) \
      >(curl -X POST -s -H "Authorization: Basic ${PUSHGW_CREDS_STAGE}" --data-binary @- $PUSHGW_URL_STAGE/metrics/job/$JOB_NAME)

FAILED_INTEGRATIONS=$(ls ${FAIL_DIR} | wc -l)

if [ "$FAILED_INTEGRATIONS" != "0" ]; then
  exit 1
fi

exit 0
