#!/bin/bash

# Optional env vars:
# - SCHEMAS_DIR: overrides the path the checked out schemas. If not defined it
#   will download the schemas from GitHub.

set -e

usage() {
    echo "$0 DATA_DIR [RESULTS_FILE]" >&1
    exit 1
}

DATA_DIR="$1"
[ -z "${DATA_DIR}" ] && usage

RESULTS_FILE="$2"

VALIDATOR_OPTS=${VALIDATOR_OPTS---only-errors}
TEMP_DIR=$(realpath -s ${TEMP_DIR:-./temp})
DATA_DIR=$(realpath -s $DATA_DIR)

mkdir -p $TEMP_DIR

if [ -z "$SCHEMAS_DIR" ]; then
    # Download schemas
    rm -rf $TEMP_DIR/schemas
    curl -sL ${QONTRACT_SERVER_REPO}/archive/${QONTRACT_SERVER_IMAGE_TAG}.tar.gz | \
        tar -xz --strip-components=1 -C $TEMP_DIR/ -f - '*/schemas'
    SCHEMAS_DIR=$TEMP_DIR/schemas
fi

SCHEMAS_DIR=$(realpath -s $SCHEMAS_DIR)

mkdir -p $TEMP_DIR/validate

docker run --rm -v ${DATA_DIR}:/data:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /data > $TEMP_DIR/validate/data.json

docker run --rm -v ${SCHEMAS_DIR}:/schemas:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /schemas > $TEMP_DIR/validate/schemas.json

docker run --rm -v ${TEMP_DIR}/validate:/validate:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-validator $VALIDATOR_OPTS /validate/schemas.json /validate/data.json \
  | tee $RESULTS_FILE
