#!/bin/bash

set -e

usage() {
    echo "$0 SCHEMAS_DIR DATA_DIR [RESULTS_FILE]" >&1
    exit 1
}

SCHEMAS_DIR="$1"
[ -z "${SCHEMAS_DIR}" ] && usage

DATA_DIR="$2"
[ -z "${DATA_DIR}" ] && usage

RESULTS_FILE="$3"

TEMP_DIR=$(realpath -s ${TEMP_DIR:-./temp})

DATA_DIR=$(realpath -s $DATA_DIR)
SCHEMAS_DIR=$(realpath -s $SCHEMAS_DIR)

VALIDATOR_OPTS=${VALIDATOR_OPTS---only-errors}

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
