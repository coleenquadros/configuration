#!/bin/bash

rm -rf venv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

APP_ROOT=$(pwd) python validator/validate.py 'schemas/**/*' 'services/**/*' > results.json
exit_status=$?

python gen_report.py results.json > reports/index.html

exit $exit_status
