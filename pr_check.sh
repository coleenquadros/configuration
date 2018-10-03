#!/bin/bash

rm -rf venv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

APP_ROOT=$(pwd) python validator/validate.py 'services/**/*'
