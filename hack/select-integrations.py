#!/usr/bin/env python

import os
import re
import sys
from glob import glob
from subprocess import check_output
import json

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


def print_pr_check_cmds(integrations, selected=None, select_all=False):
    if selected is None:
        selected = []

    for int_name, integration in integrations.items():
        if int_name not in selected and not select_all:
            continue

        pr = integration.get('pr_check')
        if not pr or pr.get('disabled'):
            continue

        cmd = ""
        if pr.get('state'):
            cmd = "STATE=true "
        cmd += "run_int " + pr['cmd'] + ' &'

        print(cmd)


def main():
    # chdir to git root
    os.chdir('{}/..'.format(dir_path))

    # grab data
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)

    integrations = get_integrations(data)
    modified_files = get_modified_files()

    def any_modified(func):
        return any([func(p) for p in modified_files])

    def all_modified(func):
        return all([func(p) for p in modified_files])

    if all_modified(lambda p: re.match(r'^docs/', p)):
        # only docs: no need to run pr check
        return

    if any_modified(lambda p: not re.match(r'^(data|resources)/', p)):
        # unknow case: we run all integrations
        print_pr_check_cmds(integrations, select_all=True)
        return

    selected = set()

    # list of integrations based on the datafiles that are changed
    modified_schemas = get_modified_schemas(data, modified_files)
    for schema in modified_schemas:
        schema_integrations = get_integrations_by_schema(integrations, schema)
        selected = selected.union(schema_integrations)

    # list of integrations based on resources/
    # TEMPORARY PATH BASED HACK
    if any_modified(lambda p: re.match(r'^resources/terraform/', p)):
        selected.add('qontract-reconcile terraform-resources')
    if any_modified(lambda p: re.match(r'^resources/jenkins/', p)):
        selected.add('qontract-reconcile jenkins-job-builder')
    if any_modified(lambda p: not re.match(r'resources/(terraform|jenkins)/', p)):
        selected.add('qontract-reconcile openshift-routes')
        selected.add('qontract-reconcile openshift-resources')

    print_pr_check_cmds(integrations, selected=selected)

if __name__ == '__main__':
    main()
