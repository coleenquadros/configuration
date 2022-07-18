#!/bin/bash

set -o pipefail

usage() {
    echo "$0 DATAFILES_BUNDLE CONFIG_TOML IS_TEST_DATA" >&1
    exit 1
}

if [ `uname -s` = "Darwin" ]; then
  sha256sum() { shasum -a 256 "$@" ; }
  QONTRACT_SERVER_DOCKER_OPTS="-p 4000:4000"
fi

CURRENT_DIR=${CURRENT_DIR:-./hack}
TEMP_DIR=${TEMP_DIR:-./temp}
WORK_DIR=$(realpath -s $TEMP_DIR)

DATAFILES_BUNDLE="$1"
[ -z "${DATAFILES_BUNDLE}" ] && usage

CONFIG_TOML="$2"
[ -z "${CONFIG_TOML}" ] && usage

IS_TEST_DATA="$3"
[ -z "${IS_TEST_DATA}" ] && usage

DATAFILES_BUNDLE_BASENAME=$(basename ${DATAFILES_BUNDLE})
DATAFILES_BUNDLE_DIR=$(dirname $(realpath -s ${DATAFILES_BUNDLE}))

# download master bundle
MASTER_BRANCH_COMMIT_SHA=$(git rev-parse remotes/origin/master)
MASTER_BUNDLE_FILE=${DATAFILES_BUNDLE_DIR}/master.json
source $CURRENT_DIR/runners.sh
echo "loading master bundle from s3://${AWS_S3_BUCKET}/bundle-archive/${MASTER_BRANCH_COMMIT_SHA}.json"
download_s3 "${MASTER_BRANCH_COMMIT_SHA}" "${MASTER_BUNDLE_FILE}"
if [ $? -ne 0 ]; then
  export MASTER_BUNDLE_SHA256=""
  INIT_BUNDLES="fs:///validate/${DATAFILES_BUNDLE_BASENAME}"
  echo "unable to load master bundle... run qontract-server with only one bundle"
  echo " * integration early exit dry-run disabled"
  echo " * granular merge permissions disabled"
else
  export MASTER_BUNDLE_SHA256=$(sha256sum ${MASTER_BUNDLE_FILE} | awk '{print $1}')
  INIT_BUNDLES="fs:///validate/master.json,fs:///validate/${DATAFILES_BUNDLE_BASENAME}"
  echo "downloaded master branch bundle with SHA256 ${MASTER_BUNDLE_SHA256}"
fi

# write .env file
cat <<EOF >${WORK_DIR}/.qontract-server-env
AWS_S3_BUCKET=${AWS_S3_BUCKET}
AWS_REGION=${AWS_REGION}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
INIT_BUNDLES=${INIT_BUNDLES}
EOF

# start graphql-server locally
qontract_server=$(
  docker run --rm -d $QONTRACT_SERVER_DOCKER_OPTS \
    -v ${DATAFILES_BUNDLE_DIR}:/validate:z \
    --env-file=${WORK_DIR}/.qontract-server-env \
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

# Run integrations

DRY_RUN=true
[[ $IS_TEST_DATA == "yes" ]] && REPORTS_DIR=reports-test-data || REPORTS_DIR=reports

## Create directories for integrations
mkdir -p ${WORK_DIR}/config
mkdir -p ${WORK_DIR}/throughput
SUCCESS_DIR=${WORK_DIR}/${REPORTS_DIR}/reconcile_reports_success
FAIL_DIR=${WORK_DIR}/${REPORTS_DIR}/reconcile_reports_fail
rm -rf ${SUCCESS_DIR} ${FAIL_DIR}; mkdir -p ${SUCCESS_DIR} ${FAIL_DIR}

# Prepare to run integrations on production

## Write config.toml for reconcile tools
cat "$CONFIG_TOML" > ${WORK_DIR}/config/config.toml

[[ "$IS_TEST_DATA" == "no" ]] && {
# Gatekeeper. If this fails, we skip all the integrations.
run_int gitlab-fork-compliance $gitlabMergeRequestTargetProjectId $gitlabMergeRequestIid app-sre || exit 1

### gitlab-ci-skipper runs first to determine if other integrations should run
[[ "$(run_int gitlab-ci-skipper $gitlabMergeRequestTargetProjectId $gitlabMergeRequestIid)" == "yes" ]] && exit 0

## Run integrations on production
ALIAS=saas-file-owners-no-compare run_int saas-file-owners $gitlabMergeRequestTargetProjectId $gitlabMergeRequestIid --no-compare
}

# Prepare to run integrations on local server

## Wait until the service loads the data
SHA256=$(sha256sum ${DATAFILES_BUNDLE} | awk '{print $1}')
while [[ ${count} -lt 60 ]]; do
    docker logs ${qontract_server}
    let count++
    DEPLOYED_SHA256=$(curl -sf http://${CURL_IP}:4000/sha256)
    [[ "$DEPLOYED_SHA256" == "$SHA256" ]] && break || sleep 1
done

if [[ "$DEPLOYED_SHA256" != "$SHA256" ]]; then
  echo "Invalid SHA256" >&2
  exit 1
fi

## Write config.toml for reconcile tools
GRAPHQL_SERVER=http://$IP:4000/graphql
cat "$CONFIG_TOML" \
  | sed "s|https://app-interface.devshift.net/graphql|$GRAPHQL_SERVER|" \
  > ${WORK_DIR}/config/config.toml

## Run integrations on local server

### saas-file-owners runs first to determine how openshift-saas-deploy-wrappers should run
[[ "$IS_TEST_DATA" == "no" ]] && VALID_SAAS_FILE_CHANGES_ONLY=$(run_int saas-file-owners $gitlabMergeRequestTargetProjectId $gitlabMergeRequestIid) || VALID_SAAS_FILE_CHANGES_ONLY="no"

# run integrations based on their pr_check definitions
python $CURRENT_DIR/select-integrations.py ${DATAFILES_BUNDLE} ${VALID_SAAS_FILE_CHANGES_ONLY} ${IS_TEST_DATA} > $TEMP_DIR/integrations.sh
exit_status=$?
if [ $exit_status != 0 ]; then
  exit $exit_status
fi

echo "selected integrations:"
cat $TEMP_DIR/integrations.sh

echo "run selected integrations:"
source $TEMP_DIR/integrations.sh

wait

print_execution_times
update_pushgateway
check_results
