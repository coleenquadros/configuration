#!/usr/bin/env python

import os
import re
import sys
from subprocess import check_output
import json

import yaml

dir_path = os.path.dirname(os.path.realpath(__file__))

ORIGIN_BRANCH = os.getenv('ORIGIN_BRANCH', 'remotes/origin/master')


def get_integrations(data):
    integrations = {}
    for df_path, df in data['data'].items():
        if df['$schema'] == '/app-sre/integration-1.yml':
            integrations[df['name']] = df

    return integrations


def get_modified_files():
    return check_output(['git', 'diff', ORIGIN_BRANCH, '--name-only']).split()


def get_data_schema(data, modified_file):
    """ get the schema of a file coming from data dir. If the file does not
    exist, it has been deleted, so get it from git """

    # modified_file represents the git path, but not the keys of data['data']
    # because the leading `data` or `test_data` has been stripped. We need to calculate it
    # here to be able to fetch it from data
    data_path = modified_file[modified_file.find(os.path.sep):]

    if data_path in data['data']:
        # file is present in data.json, we can obtain it from there
        datafile = data['data'][data_path]
    else:
        # file has been deleted, we need to obtain it from git history
        datafile_raw = check_output(
            ['git', 'show', '{}:{}'.format(ORIGIN_BRANCH, modified_file)])
        datafile = yaml.safe_load(datafile_raw)

    return datafile['$schema']


def get_resource_schema(data, modified_file):
    """ get the schema of a file coming from resources dir. If the file does
    not exist, it has been deleted, so get it from git """

    # modified_file represents the git path, but not the keys of
    # data['resources'] because the leading `resources` has been stripped. We
    # need to calculate it here to be able to fetch it from data
    data_path = modified_file[len('resources'):]

    schema = None
    if data_path in data['resources']:
        # file is present in data.json, we can obtain it from there
        schema = data['resources'][data_path]['$schema']
    else:
        # file has been deleted, we need to obtain it from git history
        datafile_raw = check_output(
            ['git', 'show', '{}:{}'.format(ORIGIN_BRANCH, modified_file)])
        schema_re = re.compile(r'^\$schema: (?P<schema>.+\.ya?ml)$',
                               re.MULTILINE)
        s = schema_re.search(datafile_raw)
        if s:
            schema = s.group('schema')

    return schema


def get_modified_schemas(data, modified_files, is_test_data):
    data_path = "test_data/" if is_test_data else "data/"
    schemas = set()
    for modified_file in modified_files:
        if modified_file.startswith(data_path):
            schemas.add(get_data_schema(data, modified_file))

        if modified_file.startswith("resources/"):
            schema = get_resource_schema(data, modified_file)
            if schema:
                schemas.add(schema)

    return schemas


def get_integrations_by_schema(integrations, schema):
    matches = set()
    for int_name, integration in integrations.items():
        if schema in integration['schemas']:
            matches.add(int_name)
    return matches


def print_pr_check_cmds(integrations, selected=None, select_all=False,
                        valid_saas_file_changes=False):
    if selected is None:
        selected = []

    for int_name, integration in integrations.items():
        pr = integration.get('pr_check')
        if not pr or pr.get('disabled'):
            continue

        always_run = pr.get('always_run')
        if int_name not in selected and not select_all and not always_run:
            continue

        run_for_valid_saas_file_changes = pr.get('run_for_valid_saas_file_changes')
        if valid_saas_file_changes and run_for_valid_saas_file_changes is False:
            continue

        cmd = ""
        if pr.get('state'):
            cmd += "STATE=true "
        if pr.get('sqs'):
            cmd += "SQS_GATEWAY=true "
        if pr.get('no_validate_schemas'):
            cmd += "NO_VALIDATE=true "

        if int_name == "vault-manager":
            cmd += 'run_vault_reconcile_integration &'
        elif int_name == "user-validator":
            cmd += 'run_user_validator &'
        else:
            cmd += "run_int " + pr['cmd'] + ' &'

        print(cmd)


def main():
    # chdir to git root
    os.chdir('{}/..'.format(dir_path))

    # grab data
    with open(sys.argv[1], 'r') as f:
        data = json.load(f)

    valid_saas_file_changes_only = True if sys.argv[2] == "yes" else False
    is_test_data = True if sys.argv[3] == "yes" else False

    integrations = get_integrations(data)
    modified_files = get_modified_files()

    def any_modified(func):
        return any([func(p) for p in modified_files])

    def all_modified(func):
        return all([func(p) for p in modified_files])

    if all_modified(lambda p: re.match(r'^docs/', p)):
        # only docs: no need to run pr check
        return

    if any_modified(lambda p: not re.match(r'^(data|resources|docs|test_data)/', p)):
        # unknow case: we run all integrations
        print_pr_check_cmds(integrations, select_all=True)
        return

    selected = set()

    # list of integrations based on the datafiles that are changed
    modified_schemas = get_modified_schemas(data, modified_files, is_test_data)
    for schema in modified_schemas:
        schema_integrations = get_integrations_by_schema(integrations, schema)
        selected = selected.union(schema_integrations)

    # list of integrations based on resources/
    # TEMPORARY PATH BASED HACK
    if any_modified(lambda p: re.match(r'^resources/terraform/', p)):
        selected.add('terraform-resources')
    if any_modified(lambda p: re.match(r'^resources/jenkins/', p)):
        selected.add('jenkins-job-builder')
        selected.add('jenkins-job-cleaner')
    if any_modified(lambda p: re.match(r'^resources/', p) \
            and not re.match(r'resources/(terraform|jenkins)/', p)):
        selected.add('openshift-routes')
        selected.add('openshift-resources')
        selected.add('openshift-tekton-resources')

    print_pr_check_cmds(integrations, selected=selected,
                        valid_saas_file_changes=valid_saas_file_changes_only)


if __name__ == '__main__':
    main()
