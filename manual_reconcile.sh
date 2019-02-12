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

  docker run --rm \
    -v ${TEMP_DIR}/config:/config:z \
    ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG} \
    qontract-reconcile --config /config/config.toml $1 --dry-run \
    2>&1 | tee ${SUCCESS_DIR}/reconcile-${1}.txt

  status="$?"

  if [ "$status" != "0" ]; then
    echo "INTEGRATION FAILED: $1" >&2
    mv ${SUCCESS_DIR}/reconcile-${1}.txt ${FAIL_DIR}/reconcile-${1}.txt
  fi

  return $status
}

docker pull ${RECONCILE_IMAGE}:${RECONCILE_IMAGE_TAG}

integration_status=0
run_int github || integration_status=1
run_int openshift-rolebinding || integration_status=1
run_int quay-membership || integration_status=1
run_int quay-repos || integration_status=1
run_int ldap-users || integration_status=1

exit $integration_status
