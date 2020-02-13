#!/bin/bash

set -exvo pipefail

CURRENT_DIR=$(dirname "$0")

# Setup vars and clean files
export TEMP_DIR=$(realpath -s temp)
rm -rf $TEMP_DIR; mkdir -p $TEMP_DIR $TEMP_DIR/reports
cp ./$CURRENT_DIR/reports-main.css $TEMP_DIR/reports

source ./.env

# Variables
RESULTS=$TEMP_DIR/reports/results.json
REPORT=$TEMP_DIR/reports/index.html

# Check that app-sre bot has permissions on fork
# and that the PR's source branch is not master (unable to rebase)
./$CURRENT_DIR/test_fork.sh
exit_status=$?

# Exit if app-sre bot is not a member
[ "$exit_status" != "0" ] && exit $exit_status

# Run validator
OUTPUT_DIR=${TEMP_DIR}/validate make bundle
OUTPUT_DIR=${TEMP_DIR}/validate make validate | tee ${RESULTS}
exit_status=$?

# Write report
python ./$CURRENT_DIR/gen-report.py ${RESULTS} > ${REPORT}
echo "Report written to: ${REPORT}"

# Exit if there was a validation error
[ "$exit_status" != "0" ] && exit $exit_status

# Validation worked, so we are good to run the integrations
echo "$CONFIG_TOML" | base64 -d > ${TEMP_DIR}/config.toml

./$CURRENT_DIR/manual_reconcile.sh ${TEMP_DIR}/validate/data.json ${TEMP_DIR}/config.toml || exit_status=$?

# Write report
python ./$CURRENT_DIR/gen-report.py ${RESULTS} $TEMP_DIR/reports > ${REPORT}
echo "Report written to: ${REPORT}"

exit $exit_status
