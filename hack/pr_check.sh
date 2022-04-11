#!/bin/bash

set -exvo pipefail
CURRENT_DIR=$(dirname "$0")

GIT_DIFF_TREE="git diff-tree --name-status -r remotes/origin/master..HEAD -- *yml *yaml"

# Check EOF newline
pip install --user binaryornot
git ls-files | $CURRENT_DIR/eofcheck.py
if [ $? != 0 ]; then
    echo "Detected files that do not end with newline"
    exit 1
fi

if ! hash yamllint > /dev/null
then
    echo "YAML linter not available. Aborting PR check"
    exit 1
fi

if git diff-tree --name-only -r remotes/origin/master..HEAD|grep -q ' '
then
    echo "This patch introduces filenames with whitespaces. Aborting."
    exit 1
fi

lintyamls() {
    toplevel=$(git rev-parse --show-toplevel)
    # Find new or modified YAML files that are unlikely to be Jinja templates

    new=$($GIT_DIFF_TREE | awk -F'\t' '$1 ~/A/{print $2}'|grep -v '^resources/'
          true
       ) # To keep -o pipefail happy
    if [ -n "$new" ]
    then
        xargs -L1 ./hack/oh_noes_besteffort.py <<< "$new"
        xargs yamllint <<< "$new"
    fi

    changed=$($GIT_DIFF_TREE|awk -F'\t' '$1 ~ /M/{print $2}' | grep -v ^resources/
              true
           ) # This one to keep -o pipefail happy

    if [ -n "$changed" ]
    then
        xargs yamllint <<< "$changed"
    fi
}

lintyamls
# Setup vars and clean files
export TEMP_DIR=$(realpath -s temp)
rm -rf $TEMP_DIR; mkdir -p $TEMP_DIR

source ./.env

# Real data
IS_TEST_DATA="no"

# Setup
mkdir -p $TEMP_DIR/reports
cp ./$CURRENT_DIR/reports-main.css $TEMP_DIR/reports

# Variables
RESULTS=$TEMP_DIR/reports/results.json
REPORT=$TEMP_DIR/reports/index.html

# Run validator
OUTPUT_DIR=${TEMP_DIR}/validate make schemas bundle

set +e
OUTPUT_DIR=${TEMP_DIR}/validate make validate | tee ${RESULTS}
exit_status=$?
set -e

# Write report
python ./$CURRENT_DIR/gen-report.py ${RESULTS} > ${REPORT}
echo "Report written to: ${REPORT}"

# Exit if there was a validation error
[ "$exit_status" != "0" ] && exit $exit_status

# Validation worked, so we are good to run the integrations
echo "$CONFIG_TOML" | base64 -d > ${TEMP_DIR}/config.toml

./$CURRENT_DIR/manual_reconcile.sh ${TEMP_DIR}/validate/data.json ${TEMP_DIR}/config.toml ${IS_TEST_DATA} || exit_status=$?

# Write report
python ./$CURRENT_DIR/gen-report.py ${RESULTS} $TEMP_DIR/reports > ${REPORT}
echo "Report written to: ${REPORT}"

exit $exit_status
