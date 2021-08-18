#!/usr/bin/env python3

import jinja2
import sys
import yaml
import copy
import subprocess
import tempfile
import os
import pathlib
import re
import argparse

PROMTOOL_VERSION = "2.26.0"

def parse_equals(string):
    return re.split(',\s*', string.replace('\\"', ''))


def print_parsed_failed_promtool_test(output):
    line_to_format_re = re.compile(
        r'(exp|got):"\[Labels:{(.*)} Annotations:{(.*)}\]"')

    tplt = jinja2.Template('''\
        {{result}}
            Labels:
                {% for label in labels -%}
                {{label}}
                {% endfor %}
            Annotations:
                {% for annotation in annotations -%}
                {{annotation}}
                {% endfor %}''')

    for line in output.split('\n'):
        m = line_to_format_re.search(line)
        if m:
            result = "Expected:" if m.group(1) == "exp" else "Got:"
            print(tplt.render(result=result,
                              labels=parse_equals(m.group(2)),
                              annotations=parse_equals(m.group(3))))
        else:
            print(line)

parser = argparse.ArgumentParser()
parser.add_argument("test_file", help="Prometheus test file")
parser.add_argument("-v", "--vars-file",
                    help="File with variables in yaml format")
parser.add_argument("-p", "--pretty-print", action="store_true",
                    help="Pretty print prometheus test errors")
parser.add_argument("-k", "--keep-temp-files", action="store_true",
                    help="Pretty print prometheus test errors")
args = parser.parse_args()

jinja2_vars = {}
if args.vars_file:
    with open(args.vars_file, 'r') as f:
        vars_yaml = yaml.safe_load(f)
        try:
            jinja2_vars = vars_yaml['variables']
        except KeyError:
            print("vars_file must be a yaml file with the resource-template "
                  "variables parameter copied as-is")
            raise

# Check we have promtool installed and it matches the desired version
result = subprocess.run(['promtool', '--version'], stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE, check=True)
if f"promtool, version {PROMTOOL_VERSION}" not in result.stdout.decode():
    print(f"promtool version must be {PROMTOOL_VERSION}")
    sys.exit(1)

# Rules and tests are extracurlyjinja2 templates
extra_curly_env = {
    'block_start_string': '{{%',
    'block_end_string': '%}}',
    'variable_start_string': '{{{',
    'variable_end_string': '}}}',
    'comment_start_string': '{{#',
    'comment_end_string': '#}}'
}
env = jinja2.Environment(undefined=jinja2.StrictUndefined, **extra_curly_env)

with open(args.test_file, 'r') as f:
    test_file_body = f.read()

test_yaml = yaml.safe_load(env.from_string(test_file_body).render(jinja2_vars))

root = pathlib.Path(__file__).parent.absolute() / '..'
bundle_rule_path = pathlib.Path(test_yaml['rule_files'][0]).relative_to('/')
rule_file = root / 'resources' / bundle_rule_path
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

try:
    # check rule syntax
    check = subprocess.run(['promtool', 'check', 'rules', temp_rule_file_name],
                           stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE,
                           check=True)
except subprocess.CalledProcessError as e:
    print(e.stdout.decode(), end='')
    print(e.stderr.decode(), end='')
    if not args.keep_temp_files:
        os.unlink(temp_rule_file_name)
        os.unlink(temp_test_file_name)
    sys.exit(1)

print(check.stdout.decode(), end='')

try:
    # run tests
    result = subprocess.run(['promtool', 'test', 'rules', temp_test_file_name],
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE,
                            check=True)
except subprocess.CalledProcessError as e:
    print(e.stdout.decode(), end='')
    print_parsed_failed_promtool_test(e.stderr.decode()) \
        if args.pretty_print else print(e.stderr.decode())
    sys.exit(1)
finally:
    if not args.keep_temp_files:
        os.unlink(temp_rule_file_name)
        os.unlink(temp_test_file_name)

print(result.stdout.decode(), end='')
