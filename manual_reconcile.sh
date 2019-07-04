#!/bin/bash

set -o pipefail

usage() {
    echo "$0 DATAFILES_BUNDLE [CONFIG_TOML]" >&1
    exit 1
}

if [ `uname -s` = "Darwin" ]; then
  sha256sum() { shasum -a 256 "$@" ; }
  QONTRACT_SERVER_DOCKER_OPTS="-p 4000:4000"
fi

TEMP_DIR=${TEMP_DIR:-./temp}
TEMP_DIR=$(realpath -s $TEMP_DIR)

DATAFILES_BUNDLE="$1"
[ -z "${DATAFILES_BUNDLE}" ] && usage

CONFIG_TOML="$2"
[ -z "${CONFIG_TOML}" ] && usage

DATAFILES_BUNDLE_BASENAME=$(basename ${DATAFILES_BUNDLE})
DATAFILES_BUNDLE_DIR=$(dirname $(realpath -s ${DATAFILES_BUNDLE}))

# write .env file
cat <<EOF >${TEMP_DIR}/.qontract-server-env
LOAD_METHOD=fs
DATAFILES_FILE=/validate/${DATAFILES_BUNDLE_BASENAME}
EOF

# start graphql-server locally
qontract_server=$(
  docker run --rm -d $QONTRACT_SERVER_DOCKER_OPTS \
    -v ${DATAFILES_BUNDLE_DIR}:/validate:z \
    --env-file=${TEMP_DIR}/.qontract-server-env \
    ${QONTRACT_SERVER_IMAGE}:${QONTRACT_SERVER_IMAGE_TAG}
)

if [ -z "$qontract_server" ]; then
  echo "Could not start qontract server" >&2
  exit 1
fi

# Setup trap to execute after the script exits
trap "docker stop $qontract_server >/dev/null" EXIT

# get network conf
IP=$(docker inspect \
      -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
      ${qontract_server})

if [ `uname -s` = 'Darwin' ]; then
  CURL_IP=localhost
else
  CURL_IP=$IP
fi

# Write config.toml for reconcile tools
mkdir -p ${TEMP_DIR}/config
cat "$CONFIG_TOML" \
  | sed "s|https://app-interface.devshift.net/graphql|http://$IP:4000/graphql|" \
  > ${TEMP_DIR}/config/config.toml

# Create directory for throughput between integrations
mkdir -p ${TEMP_DIR}/throughput

# wait until the service loads the data
SHA256=$(sha256sum ${DATAFILES_BUNDLE} | awk '{print $1}')
while [[ ${count} -lt 20 ]]; do
    let count++
    DEPLOYED_SHA256=$(curl -sf http://${CURL_IP}:4000/sha256)
    [[ "$DEPLOYED_SHA256" == "$SHA256" ]] && break || sleep 1
done

if [[ "$DEPLOYED_SHA256" != "$SHA256" ]]; then
  echo "Invalid SHA256" >&2
  exit 1
fi

# run integrations

SUCCESS_DIR=${TEMP_DIR}/reports/reconcile_reports_success
FAIL_DIR=${TEMP_DIR}/reports/reconcile_reports_fail
rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

run_int() {
  local status

  echo "INTEGRATION $1" >&2

  STARTTIME=$(date +%s)
  docker run --rm \
    -v ${TEMP_DIR}/config:/config:z \
    -v /etc/pki:/etc/pki:z \
    -e REQUESTS_CA_BUNDLE=/etc/pki/tls/cert.pem \
    -v ${TEMP_DIR}/throughput:/throughput:z \
    -w / \
    ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
    qontract-reconcile --config /config/config.toml --dry-run $1 \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-${1}.txt

  status="$?"
  ENDTIME=$(date +%s)

  echo "$1 $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/run_int_execution_times.txt"

  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: $1" >&2
    mv ${SUCCESS_DIR}/reconcile-${1}.txt ${FAIL_DIR}/reconcile-${1}.txt
  fi

  return $status
}

run_vault_reconcile_integration() {
  local status

  echo "INTEGRATION vault" >&2

  STARTTIME=$(date +%s)
  docker run --rm -t \
    -e GRAPHQL_SERVER=http://$IP:4000/graphql \
    -e VAULT_ADDR=https://vault.devshift.net \
    -e VAULT_AUTHTYPE=approle \
    -e VAULT_ROLE_ID=${VAULT_MANAGER_ROLE_ID} \
    -e VAULT_SECRET_ID=${VAULT_MANAGER_SECRET_ID} \
    ${VAULT_RECONCILE_IMAGE}:${VAULT_RECONCILE_IMAGE_TAG} -dry-run \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-vault.txt

  status="$?"
  ENDTIME=$(date +%s)

  echo "vault $((ENDTIME - STARTTIME))" >> "${SUCCESS_DIR}/run_int_execution_times.txt"


  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: vault" >&2
    mv ${SUCCESS_DIR}/reconcile-vault.txt ${FAIL_DIR}/reconcile-vault.txt
  fi

  return $status
}

docker pull ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG}
docker pull ${VAULT_RECONCILE_IMAGE}:${VAULT_RECONCILE_IMAGE_TAG}

run_int github &
run_int github-users &
run_int github-repo-invites &
run_int quay-membership &
run_int quay-repos &
run_vault_reconcile_integration &
run_int openshift-groups &
run_int jenkins-plugins &
run_int jenkins-roles &
run_int aws-iam-keys &
run_int slack-usergroups &
run_int gitlab-permissions &
run_int openshift-namespaces &
run_int openshift-rolebinding &
run_int openshift-resources &
run_int terraform-resources &
run_int terraform-users &

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
