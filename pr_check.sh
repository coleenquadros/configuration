#!/bin/bash

export DESCRIPTION=$(
    curl -sk "$BUILD_URL/api/json" | \
    jq .description | \
    grep -o 'http[^\\]\+'
)

rm -rf venv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

APP_ROOT=$(pwd) python validator/validate.py \
    --metaschema metaschema.json \
    --schemas-root schemas \
    'services/**/*' > reports/results.json

exit_status=$?

python gen_report.py reports/results.json > reports/index.html

exit $exit_status
