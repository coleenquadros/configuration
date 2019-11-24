#!/bin/bash

set -exvo pipefail

CURRENT_DIR=$(dirname "$0")
source ./.env
source $CURRENT_DIR/runners.sh

# Setup
mkdir -p validate reports

# Create data bundle
cp -r docs/ resources/ && find resources/docs/ -type f -exec file {} \; | grep text -v | cut -d: -f1 | xargs rm
docker run --rm \
  -v `pwd`/schemas:/schemas:z \
  -v `pwd`/graphql-schemas:/graphql-schemas:z \
  -v `pwd`/data:/data:z \
  -v `pwd`/resources:/resources:z \
  ${VALIDATOR_IMAGE}:${VALIDATOR_IMAGE_TAG} \
  qontract-bundler /schemas /graphql-schemas/schema.yml /data /resources > validate/data.json

upload_s3 validate/data.json
echo "bundle uploaded to $ENVIRONMENT" > reports/report
