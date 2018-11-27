#!/usr/bin/env python2

# This script shouldn't be used in the long term. It's a hack to validate refs

import os
import sys
import anymarkup

PATH = sys.argv[1]

os.chdir(PATH)


def check_ref(f, ref):
    path = ref[1:]
    if not os.path.isfile(path):
        print [f, ref]
        return True
    return False


def check_bot(f, data):
    fail = False
    owner = data.get('owner')
    if owner:
        check_ref(f, owner['$ref'])

    roles = data.get('roles')
    if roles:
        for role in roles:
            fail = fail or check_ref(f, role['$ref'])

    return fail


def check_user(f, data):
    fail = False
    roles = data.get('roles')
    if roles:
        for role in roles:
            fail = fail or check_ref(f, role['$ref'])

    return fail


def check_role(f, data):
    fail = False
    permissions = data.get('permissions')
    if permissions:
        for permission in permissions:
            fail = fail or check_ref(f, permission['$ref'])
    return fail


def main():
    files = [
        "/".join(os.path.join(root, name).split('/')[1:])
        for root, dirs, files in os.walk(".", topdown=False)
        for name in files
        if name.endswith('.yml')
    ]

    fail = False

    for f in files:
        data = anymarkup.parse_file(f)
        schema = data["$schema"]

        if schema == "access/bot.yml":
            fail = fail or check_bot(f, data)
        elif schema == "access/user.yml":
            fail = fail or check_user(f, data)
        elif schema == "access/role.yml":
            fail = fail or check_role(f, data)

    if fail:
        sys.exit(1)


if __name__ == '__main__':
    main()
