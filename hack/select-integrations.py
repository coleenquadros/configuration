#!/usr/bin/env python

import os
import re
import sys
from glob import glob
from subprocess import check_output
import json
# from enum import Enum

import yaml


dir_path = os.path.dirname(os.path.realpath(__file__))


def get_integrations(data):
    integrations = {}
    for df_path, df in data['data'].items():
        if df['$schema'] == '/app-sre/integration-1.yml':
            integrations[df['name']] = df

    return integrations


def get_modified_files():
    return check_output(['git', 'diff', 'origin', '--name-only']).split()


def get_schema(data, f):
    """ get the schema of a file. If the file does not exist, it has been deleted, so get it from git """
    if f in data['data']:
        data['data'][f]
    else:
        data = check_output(['git', 'show', 'origin:{}'.format(f)])

    datafile = yaml.safe_load(data)
    return datafile['$schema']


def get_modified_schemas(data, modified_files):
    schemas = set()
    for f in modified_files:
        if f.startswith("data/"):
            schemas.add(get_schema(data, f))
    return schemas


def get_integrations_by_schema(integrations, schema):
    matches = set()
    for int_name, integration in integrations.items():
        if schema in integration['schemas']:
            matches.add(int_name)
    return matches


def print_integration_cmds(integrations, selected=None, select_all=False):
    if selected is None:
        selected = []

    for int_name, integration in integrations.items():
        pr = integration.get('pr_check')

        if int_name not in selected and not select_all:
            continue

        if not pr:
            continue

        if pr.get('disabled'):
            continue

        cmd = ""
        if pr.get('state'):
            cmd = "STATE=true "
        cmd += pr['cmd'] + ' &'

        print(cmd)


def main():
    # chdir to git root
    os.chdir('{}/..'.format(dir_path))

    # grab data
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)

    integrations = get_integrations(data)
    modified_files = get_modified_files()

    if all([re.match(r'^(data|resources)/', p) for p in modified_files]):
        # only changes in data/ or resources/
        selected = set()

        modified_schemas = get_modified_schemas(data, modified_files)
        for schema in modified_schemas:
            selected = selected.union(
                get_integrations_by_schema(integrations, schema))

        print_integration_cmds(integrations, selected=selected)
    elif all([re.match(r'^docs/', p) for p in modified_files]):
        # only docs: no need to run pr check
        pass
    else:
        # unknown case: we run all integrations
        print_integration_cmds(integrations, select_all=True)


if __name__ == '__main__':
    main()
