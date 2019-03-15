#!/bin/bash

# Setup vars and clean files
export TEMP_DIR=$(realpath -s temp)
rm -rf $TEMP_DIR; mkdir -p $TEMP_DIR $TEMP_DIR/reports
cp reports-main.css $TEMP_DIR/reports

source ./.env

# Variables
RESULTS=$TEMP_DIR/reports/results.json
REPORT=$TEMP_DIR/reports/index.html

# Run validator
mkdir -p $(dirname $RESULTS)
./manual_schema_validator.sh schemas graphql-schemas data resources $RESULTS
exit_status=$?

# Write report
python gen-report.py ${RESULTS} > ${REPORT}
echo "Report written to: ${REPORT}"

# Exit if there was a validation error
[ "$exit_status" != "0" ] && exit $exit_status

# Validation worked, so we are good to run the integrations
echo "$CONFIG_TOML" | base64 -d > ${TEMP_DIR}/config.toml

./manual_reconcile.sh ${TEMP_DIR}/validate/data.json ${TEMP_DIR}/config.toml
exit_status=$?

# Write report
python gen-report.py ${RESULTS} $TEMP_DIR/reports > ${REPORT}
echo "Report written to: ${REPORT}"

exit $exit_status
