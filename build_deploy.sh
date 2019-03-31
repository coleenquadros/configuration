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

curl "https://${USERNAME}:${PASSWORD}@app-interface.staging.devshift.net/reload"

wait_response \
    "https://${USERNAME}:${PASSWORD}@app-interface.staging.devshift.net/sha256" \
    "$SHA256"

# Upload to prodution and reload

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

SUCCESS_DIR=reports/reconcile_reports_success
FAIL_DIR=reports/reconcile_reports_fail
rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

set +e

run_int() {
  echo "INTEGRATION $1" >&2

  STARTTIME=$(date +%s)
  docker run --rm \
    -v `pwd`/config:/config:z \
    ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
    qontract-reconcile --config /config/config.toml $1 \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-${1}.txt
  EXIT_STATUS=$?
  ENDTIME=$(date +%s)

  echo "$1 $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/run_int_execution_times.txt"

  if [ "$EXIT_STATUS" != "0" ]; then
    mv ${SUCCESS_DIR}/reconcile-${1}.txt ${FAIL_DIR}/reconcile-${1}.txt
    return 1
  fi

  return 0
}

run_vault_reconcile_integration() {
  echo "INTEGRATION vault" >&2

  STARTTIME=$(date +%s)
  docker run --rm -t \
    -e GRAPHQL_SERVER=https://app-interface.devshift.net/graphql \
    -e GRAPHQL_USERNAME=$USERNAME_PRODUCTION \
    -e GRAPHQL_PASSWORD=$PASSWORD_PRODUCTION \
    -e VAULT_ADDR=https://vault.devshift.net \
    -e VAULT_AUTHTYPE=approle \
    -e VAULT_ROLE_ID=${VAULT_MANAGER_ROLE_ID} \
    -e VAULT_SECRET_ID=${VAULT_MANAGER_SECRET_ID} \
    ${VAULT_RECONCILE_IMAGE}:${VAULT_RECONCILE_IMAGE_TAG} \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-vault.txt
  EXIT_STATUS=$?
  ENDTIME=$(date +%s)

  echo "vault $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/run_int_execution_times.txt"

  if [ "$EXIT_STATUS" != "0" ]; then
    mv ${SUCCESS_DIR}/reconcile-${1}.txt ${FAIL_DIR}/reconcile-vault.txt
    return 1
  fi

  return 0
}

run_int github &
run_int openshift-rolebinding &
run_int openshift-resources &
run_int quay-membership &
run_int quay-repos &
run_int ldap-users &
run_vault_reconcile_integration &

wait

echo
echo "Execution times for integrations that were executed"
(
  echo "Integration Seconds"
  sort -nr -k2 "${SUCCESS_DIR}/run_int_execution_times.txt"
) | column -t
echo

FAILED_INTEGRATIONS=$(ls ${FAIL_DIR} | wc -l)

if [ "$FAILED_INTEGRATIONS" != "0" ]; then
  exit 1
fi

exit 0
