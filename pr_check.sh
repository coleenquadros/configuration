#!/bin/bash

export DESCRIPTION=$(
    curl -sk "$BUILD_URL/api/json" | \
    jq .description | \
    grep -o 'http[^\\]\+'
)

make build
make validate > reports/results.json

exit_status=$?

python gen_report.py reports/results.json > reports/index.html

exit $exit_status
