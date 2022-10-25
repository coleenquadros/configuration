#!/usr/bin/env python

import os
import sys
import json

from cluster_provision.common import read_yaml_from_file
from cluster_provision.common import write_yaml_to_file

dir_path = os.path.dirname(os.path.realpath(__file__))


USER_ROLE_FILE = """
---
$schema: /access/role-1.yml
labels:
  origin: generated
name: generated-user-role-{}

permissions: []

self_service:
- change_type:
    $ref: /app-interface/changetype/manage-own-user.yml
  datafiles:
  - $ref: {}
"""


def get_objects(data, schema):
    results = {}
    for df_path, df in data['data'].items():
        if df['$schema'] == schema:
            df['path'] = df_path
            results[df['name']] = df

    return results


def get_users(data):
    return get_objects(data, '/access/user-1.yml')


def main():
    # chdir to git root
    os.chdir('{}/..'.format(dir_path))

    # grab data
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)

    users = get_users(data)
    for user in users.values():
        user_org_username = user['org_username']
        user_file_path = user['path']
        # write role file
        role_dst_path = f"/generated/roles/manage-own-user/{user_org_username}.yml"
        with open(f"./data{role_dst_path}", 'w') as f:
            f.write(USER_ROLE_FILE.format(user_org_username, user_file_path))
        # update user file
        content = read_yaml_from_file(f"./data/{user_file_path}")
        role_to_add = {'$ref': role_dst_path}
        if role_to_add not in content['roles']:
            content['roles'].insert(0, role_to_add)
        write_yaml_to_file(f"./data/{user_file_path}", content)


if __name__ == '__main__':
    main()
