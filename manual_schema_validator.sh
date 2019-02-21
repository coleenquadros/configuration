#!/bin/bash

# Optional env vars:
# - SCHEMAS_DIR: overrides the path the checked out schemas. If not defined it
#   will download the schemas from GitHub.

set -eo pipefail

usage() {
    echo "$0 DATA_DIR [RESULTS_FILE]" >&1
    exit 1
}

DATA_DIR="$1"
RESOURCES_DIR="$2"
RESULTS_FILE="$3"

[ -z "${DATA_DIR}" ] && usage
[ -z "${RESOURCES_DIR}" ] && usage

VALIDATOR_OPTS=${VALIDATOR_OPTS---only-errors}
TEMP_DIR=$(realpath -s ${TEMP_DIR:-./temp})
DATA_DIR=$(realpath -s $DATA_DIR)
RESOURCES_DIR=$(realpath -s $RESOURCES_DIR)

mkdir -p $TEMP_DIR

# Download schemas
if [ -z "$SCHEMAS_DIR" ]; then
    rm -rf $TEMP_DIR/schemas
    curl -sL ${QONTRACT_SERVER_REPO}/archive/${QONTRACT_SERVER_IMAGE_TAG}.tar.gz | \
        tar -xz --strip-components=1 -C $TEMP_DIR/ -f - '*/assets/schemas'
    SCHEMAS_DIR=$TEMP_DIR/assets/schemas
fi
SCHEMAS_DIR=$(realpath -s $SCHEMAS_DIR)

mkdir -p $TEMP_DIR/validate

docker run --rm \
  -v ${SCHEMAS_DIR}:/schemas:z \
  -v ${DATA_DIR}:/data:z \
  -v ${RESOURCES_DIR}:/resources:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /schemas /data /resources > $TEMP_DIR/validate/data.json

docker run --rm -v ${TEMP_DIR}/validate:/validate:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-validator $VALIDATOR_OPTS /validate/data.json \
  | tee $RESULTS_FILE

echo "No validation errors found." >&2

exit 0
