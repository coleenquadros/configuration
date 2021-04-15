#!/usr/bin/env python3

import jinja2
import sys
import yaml
import copy
import subprocess
import tempfile
import os

if len(sys.argv) < 2:
    print(f'Usage: {sys.argv[0]} test_file <variables>')
    sys.exit(1)

test_file = sys.argv[1]

jinja2_vars = {}
if len(sys.argv) > 2:
    vars_file = sys.argv[2]
    with open(vars_file, 'r') as f:
        vars_yaml = yaml.safe_load(f)
        try:
            jinja2_vars = vars_yaml['variables']
        except KeyError:
            print("vars_file must be a yaml file with the resource-template "
                  "variables parameter copied as-is")
            raise

extra_curly_env = {
    'block_start_string': '{{%',
    'block_end_string': '%}}',
    'variable_start_string': '{{{',
    'variable_end_string': '}}}',
    'comment_start_string': '{{#',
    'comment_end_string': '#}}'
}
env = jinja2.Environment(undefined=jinja2.StrictUndefined, **extra_curly_env)


with open(test_file, 'r') as f:
    test_file_body = f.read()

test_yaml = yaml.safe_load(env.from_string(test_file_body).render(jinja2_vars))

rule_file = f"resources/{test_yaml['rule_files'][0]}"
with open(rule_file, 'r') as f:
    rule_file_body = f.read()

rule_yaml = yaml.safe_load(env.from_string(rule_file_body).render(jinja2_vars))

with tempfile.NamedTemporaryFile(delete=False) as rp:
    rp.write(yaml.dump(rule_yaml['spec']).encode())
    temp_rule_file_name = rp.name

with tempfile.NamedTemporaryFile(delete=False) as tp:
    copy_test_yaml = copy.deepcopy(test_yaml)
    del copy_test_yaml['$schema']
    copy_test_yaml['rule_files'] = [temp_rule_file_name]
    tp.write(yaml.dump(copy_test_yaml).encode())
    temp_test_file_name = tp.name

# check rule syntax
cmd = ['promtool', 'check', 'rules', temp_rule_file_name]
result = subprocess.run(cmd, check=True)

# run test
cmd = ['promtool', 'test', 'rules', temp_test_file_name]
result = subprocess.run(cmd, check=True)

os.unlink(temp_rule_file_name)
os.unlink(temp_test_file_name)
