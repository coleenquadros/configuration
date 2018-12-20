#!/bin/bash

set -xvo pipefail

source ./.env

# variables
RESULTS=reports/results.json
REPORT=reports/index.html

# Download schemas
rm -rf schemas
curl -sL ${QONTRACT_SERVER_REPO}/archive/${QONTRACT_SERVER_IMAGE_TAG}.tar.gz | \
  tar -xz --strip-components=1 -f - '*/schemas'

# Run validation and generate report
mkdir -p validate

docker run --rm -v `pwd`/data:/data:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /data > validate/data.json

docker run --rm -v `pwd`/schemas:/schemas:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /schemas > validate/schemas.json

docker run --rm -v `pwd`/validate:/validate:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-validator /validate/schemas.json /validate/data.json \
  > ${RESULTS}

exit_status=$?

# Write report
python gen-report.py ${RESULTS} > ${REPORT}
echo "Report written to: ${REPORT}"

# Exit if there was a validation error
[ "$exit_status" != "0" ] && exit $exit_status

# Validation worked, so we are good to run the integrations

# write .env file
cat <<EOF > .env
LOAD_METHOD=fs
DATAFILES_FILE=/validate/data.json
EOF

# start graphql-server locally
qontract_server=$(
  docker run --rm -d \
    -v `pwd`/validate:/validate:z \
    --env-file=.env \
    ${QONTRACT_SERVER_IMAGE}:${QONTRACT_SERVER_IMAGE_TAG}
)

if [ -z "$qontract_server" ]; then
  echo "Could not start qontract server" >&2
  exit 1
fi

# Setup trap to execute after the script exits
trap "docker stop $qontract_server" EXIT

# get network conf
IP=$(docker inspect \
      -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
      ${qontract_server})

# Write config.toml for reconcile tools
mkdir -p config
echo "$CONFIG_TOML" | base64 -d | sed "s/localhost/$IP/" > config/config.toml

# wait until the service loads the data
count=0
max=10
SHA256=$(sha256sum validate/data.json | awk '{print $1}')
while [[ ${count} -lt ${max} ]]; do
    let count++
    DEPLOYED_SHA256=$(curl -sf http://${IP}:4000/sha256)
    [[ "$DEPLOYED_SHA256" == "$SHA256" ]] && break || sleep 10
done

if [[ "$DEPLOYED_SHA256" != "$SHA256" ]]; then
  echo "Invalid SHA256" >&2
  exit 1
fi

# run integrations

SUCCESS_DIR=reports/reconcile_reports_success
FAIL_DIR=reports/reconcile_reports_fail

RECONCILE_SUCCESS=true

rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

# GITHUB

docker run --rm \
  -v `pwd`/config:/config:z \
  ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
  qontract-reconcile --config /config/config.toml github --dry-run \
  |& tee ${SUCCESS_DIR}/reconcile-github.txt

if [ "$?" != "0" ]; then
  mv ${SUCCESS_DIR}/reconcile-github.txt ${FAIL_DIR}/reconcile-github.txt
  RECONCILE_SUCCESS=false
fi

# OPENSHIFT-ROLEBINDING

docker run --rm \
  -v `pwd`/config:/config:z \
  ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
  qontract-reconcile --config /config/config.toml openshift-rolebinding --dry-run \
  |& tee ${SUCCESS_DIR}/reconcile-openshift-rolebinding.txt

if [ "$?" != "0" ]; then
  mv ${SUCCESS_DIR}/reconcile-openshift-rolebinding.txt ${FAIL_DIR}/reconcile-openshift-rolebinding.txt
  RECONCILE_SUCCESS=false
fi

# Rewrite report with the generated reconcile reports
python gen-report.py ${RESULTS} > ${REPORT}
echo "Report written to: ${REPORT}"

if [ "$RECONCILE_SUCCESS" != "true" ]; then
  echo "Some reconcile jobs failed" >&2
  exit 1
fi

exit 0
