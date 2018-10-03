#!/bin/bash

rm -rf venv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

mkdir -p reports

APP_ROOT=$(pwd) python validator/validate.py 'services/**/*' > reports.json
exit_status=$?

echo '<pre>' > reports/index.html
jq . reports.json >> reports/index.html
echo '</pre>' >> reports/index.html

rm reports.json

exit $exit_status
