#!/bin/bash

# Required environment variables:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - AWS_REGION
# - AWS_S3_BUCKET
# - AWS_S3_KEY

set -exvo pipefail

CURRENT_DIR=$(dirname "$0")
source ./.env
source $CURRENT_DIR/runners.sh

# Setup
mkdir -p validate reports

# Create data bundle
OUTPUT_DIR=validate make schemas bundle validate

upload_s3 validate/data.json $(git rev-parse HEAD)
echo "bundle uploaded to $ENVIRONMENT" > reports/report
