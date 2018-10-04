#!/bin/bash

rm -rf venv
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

APP_ROOT=$(pwd) python validator/validate.py 'services/**/*' > results.json
exit_status=$?

(
    echo "<html>"
    echo "<head><link rel='stylesheet' href='main.css'></head>"
    echo "<body>"

    if [ $exit_status -ne 0 ]; then
        ERRORS=$(jq -r '.[]|select(.result.status=="ERROR").filename' results.json)
        echo "<h1>Errors</h1>"
        for filename in "$ERRORS"; do
            echo "<h3>$filename</h3>"
            echo "<pre>"
            jq ".[]|select(.filename==\"$filename\").result" results.json
            echo "</pre>"
        done
    fi
    echo "<h1>All</h1>"
    echo "<pre>"
    jq . results.json
    echo "</pre>"

    echo "</body>"
    echo "</html>"
) > reports/index.html

exit $exit_status
