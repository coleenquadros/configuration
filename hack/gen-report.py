#!/usr/bin/env python3

import json
import os
import sys

from glob import glob

import jinja2

REPORT_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <link rel='stylesheet' href='reports-main.css'>
</head>
<body>
<h2>App-Interface Schema Validator</h2>
<p>Raw results: <a href='results.json'>results.json</a></p>
<h3>Summary:</h3>
<ul>
<li>Checked schemas: {{ results_schemas | length }}</li>
<li>Schema errors: {{ errors_schemas | length }}</li>
<li>Checked files: {{ results_files | length }}</li>
<li>File validation errors: {{ errors_files | length }}</li>
<li>Ref validation errors: {{ errors_refs | length }}</li>
{% if description %}
<li>MR: <a href="{{ description }}">{{ description }}</a></li>
{% endif %}
</ul>

{% if errors_schemas | length > 0 %}
<h2>Schema Errors</h2>
{% for error in errors_schemas %}
    <h3>{{ error.filename }}</h3>
    <ul>
        <li>REASON: <code>{{ error.result.reason }}</code></li>
    </ul>
    <pre><code>{{ error.result.error | e }}</code></pre>
{% endfor %}
{% endif %}

{% if errors_files | length > 0 %}
<h2>File Validation Errors</h2>
{% for error in errors_files %}
    <h3>{{ error.filename }}</h3>
    <ul>
        <li>REASON: <code>{{ error.result.reason }}</code></li>
        <li>SCHEMA_URL: <code>{{ error.result.schema_url }}</code></li>
    </ul>
    <pre><code>{{ error.result.error | e }}</code></pre>
{% endfor %}
{% endif %}

{% if errors_refs | length > 0 %}
<h2>Ref Validation Errors</h2>
{% for error in errors_refs %}
    <h3>{{ error.filename }}</h3>
    <ul>
        <li>REASON: <code>{{ error.result.reason }}</code></li>
        <li>REF: <code>{{ error.result.ref }}</code></li>
    </ul>
    <pre><code>{{ error.result.error | e }}</code></pre>
{% endfor %}
{% endif %}

{% if reconcile_success | length > 0 %}
<h2>Successful Reconcile Integrations</h2>
{% for report in reconcile_success %}
<h3>{{ report[0] }}</h3>
<pre><code>{{ report[1]|escape }}</pre></code>
{% endfor %}
{% endif %}

{% if reconcile_fail | length > 0 %}
<h2>Failed Reconcile Integrations</h2>
{% for report in reconcile_fail %}
<h3>{{ report[0] }}</h3>
<pre><code>{{ report[1]|escape }}</pre></code>
{% endfor %}
{% endif %}

</body>
</html>
"""


def report_tuple(path):
    """
    returns a tuple: (report_name, content)
    """

    report_name = os.path.basename(path)
    with open(path, "r") as f:
        content = f.read()

    return (report_name, content)


def main():
    results_json = sys.argv[1]

    try:
        reports_dir = sys.argv[2]
    except IndexError:
        reports_dir = None

    with open(results_json, "r") as f:
        results = json.load(f)

    results_schemas = [i for i in results if i["kind"] == "SCHEMA"]

    errors_schemas = [i for i in results_schemas if i["result"]["status"] == "ERROR"]

    results_files = [i for i in results if i["kind"] == "FILE"]

    errors_files = [i for i in results_files if i["result"]["status"] == "ERROR"]

    results_refs = [i for i in results if i["kind"] == "REF"]

    errors_refs = [i for i in results_refs if i["result"]["status"] == "ERROR"]

    template = jinja2.Template(REPORT_TEMPLATE)

    if reports_dir:
        success_glob = glob(reports_dir + "/reconcile_reports_success/*.txt")
        fail_glob = glob(reports_dir + "/reconcile_reports_fail/*.txt")
        reconcile_success = list(map(report_tuple, success_glob))
        reconcile_fail = list(map(report_tuple, fail_glob))
    else:
        reconcile_success = []
        reconcile_fail = []

    print(
        template.render(
            results_schemas=results_schemas,
            errors_schemas=errors_schemas,
            results_files=results_files,
            errors_files=errors_files,
            errors_refs=errors_refs,
            reconcile_success=reconcile_success,
            reconcile_fail=reconcile_fail,
            description=os.environ.get("DESCRIPTION"),
        )
    )


if __name__ == "__main__":
    main()
