#!/bin/bash

set -e
set -o nounset
set -o pipefail

usage() {
    cat <<EOF
    usage: $0 [ OPTION ]
    Options - The following argument is required 
    -n         Namespace - Operator namespace where OLM components are installed
EOF
}

# Set delete default to false
DELETE=false

if ( ! getopts ":n:dh" opt); then
    echo ""
    echo "    $0 requries an argument!"
    usage
    exit 1 
fi

while getopts ":n:dh" opt; do
    case $opt in
        n)
            NAMESPACE="$OPTARG"
            ;;
        d)
            DELETE=true
            ;;
        h)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1
            ;;
        :)
            echo "$0 Requires an argument" >&2
            usage
            exit 1
            ;;
    esac
done

if [ -z "$NAMESPACE" ]; then
    usage
    exit 1
fi

"$DELETE" || echo "Not going to delete resources"

SUBSCRIPTION=$(oc get sub -n ${NAMESPACE} -o jsonpath={.items[].metadata.name} | grep hive)
CATALOG_SOURCE=$(oc get catalogsource -n ${NAMESPACE} -o jsonpath={.items[].metadata.name} | grep hive)
OPERATOR_GROUP=$(oc get og -n ${NAMESPACE} -o jsonpath={.items[].metadata.name} | grep hive)

if $DELETE; then
  echo "Deteting subscription: ${SUBSCRIPTION}"
  oc delete sub "${SUBSCRIPTION}" -n "${NAMESPACE}"
  echo "Deteting subscription: ${CATALOG_SOURCE}"
  oc delete catalogsource "${CATALOG_SOURCE}" -n "${NAMESPACE}" 
  echo "Deteting subscription: ${SUBSCRIPTION}"
  oc delete og ${OPERATOR_GROUP} -n "${NAMESPACE}" 
else
  echo "Will detete subscription: ${SUBSCRIPTION}"
  echo "Will detete catalogSource: ${CATALOG_SOURCE}"
  echo "Will detete operatorGroup: ${SUBSCRIPTION}"
fi

$DELETE || echo "Will detete CSVs:"
for csv in $(oc get csv -n "${NAMESPACE}" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep hive)
do
  if $DELETE; then
    echo "Deteting CSV: ${csv}"
    oc delete csv $csv -n "${NAMESPACE}"
  else
    echo -e "\t${csv}"
  fi
done

