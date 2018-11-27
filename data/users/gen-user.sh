#!/bin/bash

set -o pipefail

LDAP_USERNAME=$1
GH_USERNAME=$2

usage() {
    echo "$0 LDAP_USERNAME GH_USERNAME"
    exit 1
}

[[ -z "$LDAP_USERNAME" || -z "$GH_USERNAME" ]] && usage

NAME=$(
    ldapsearch -x -LLL -b "dc=redhat,dc=com" -H 'ldap://ldap.rdu.redhat.com' "uid=$LDAP_USERNAME" cn | \
    grep ^cn: | \
    cut -d' ' -f2-
)

if [[ $? != 0 || -z "$NAME" ]]; then
    echo "LDAP_USERNAME $LDAP_USERNAME not found"
    exit 1
fi

echo "Output written to ${LDAP_USERNAME}.yml:"
echo
cat <<EOF | tee ${LDAP_USERNAME}.yml
---
\$schema: users/user.yml
labels: {}
name: $NAME
redhat_username: $LDAP_USERNAME
github_username: $GH_USERNAME
EOF
