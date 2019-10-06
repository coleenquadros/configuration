#!/bin/bash

set -eo pipefail

VALIDATOR_OPTS=${VALIDATOR_OPTS---only-errors}

usage() {
    echo "$0 SCHEMAS_DIR GRAPHQL_DIR DATA_DIR RESOURCES_DIR [RESULTS_FILE]" >&1
    exit 1
}

SCHEMAS_DIR="$1"
GRAPHQL_DIR="$2"
DATA_DIR="$3"
RESOURCES_DIR="$4"
RESULTS_FILE="$5"

[ -z "${SCHEMAS_DIR}" ] && usage
[ -z "${GRAPHQL_DIR}" ] && usage
[ -z "${DATA_DIR}" ] && usage
[ -z "${RESOURCES_DIR}" ] && usage


TEMP_DIR=$(realpath -s ${TEMP_DIR:-./temp})
SCHEMAS_DIR=$(realpath -s $SCHEMAS_DIR)
GRAPHQL_DIR=$(realpath -s $GRAPHQL_DIR)
DATA_DIR=$(realpath -s $DATA_DIR)
RESOURCES_DIR=$(realpath -s $RESOURCES_DIR)

mkdir -p $TEMP_DIR/validate

docker run --rm \
  -v ${SCHEMAS_DIR}:/schemas:z \
  -v ${GRAPHQL_DIR}:/graphql-schemas:z \
  -v ${DATA_DIR}:/data:z \
  -v ${RESOURCES_DIR}:/resources:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /schemas /graphql-schemas/schema.yml /data /resources > $TEMP_DIR/validate/data.json

docker run --rm -v ${TEMP_DIR}/validate:/validate:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-validator $VALIDATOR_OPTS /validate/data.json \
  | tee $RESULTS_FILE

echo "No validation errors found." >&2

exit 0
