#!/bin/bash

rm -rf venv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

SCHEMAS_ROOT=$(pwd) python validator/validate.py 'services/**/*'
