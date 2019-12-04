#!/bin/bash

set -exvo pipefail

CURRENT_DIR=$(dirname "$0")
source ./.env
source $CURRENT_DIR/runners.sh

# Setup
mkdir -p validate reports

# Create data bundle
OUTPUT_DIR=validate make bundle validate

upload_s3 validate/data.json
echo "bundle uploaded to $ENVIRONMENT" > reports/report
