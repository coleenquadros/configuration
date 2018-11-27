#!/bin/bash

REPORT="reports/index.html"

export DESCRIPTION=$(
    curl -sk "$BUILD_URL/api/json" | \
    jq .description | \
    grep -o 'http[^\\]\+'
)

make validate > reports/results.json

exit_status=$?

python gen_report.py reports/results.json > reports/index.html
echo "Report written to: ${REPORT}"

exit $exit_status
