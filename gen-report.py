#!/usr/bin/env python

import json
import os
import sys

import jinja2

REPORT_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <link rel='stylesheet' href='main.css'>
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
<h2>Reconcile Reports</h2>
<ul>
<li><a href='reconcile-github.txt'>reconcile-github.txt</a></li>
</ul>
</body>
</html>
"""


def main():
    with open(sys.argv[1], 'r') as f:
        results = json.load(f)

    results_schemas = [
        i for i in results
        if i["kind"] == "SCHEMA"
    ]

    errors_schemas = [
        i for i in results_schemas
        if i["result"]["status"] == "ERROR"
    ]

    results_files = [
        i for i in results
        if i["kind"] == "FILE"
    ]

    errors_files = [
        i for i in results_files
        if i["result"]["status"] == "ERROR"
    ]

    template = jinja2.Template(REPORT_TEMPLATE)

    print template.render(
        results_schemas=results_schemas,
        errors_schemas=errors_schemas,
        results_files=results_files,
        errors_files=errors_files,
        description=os.environ.get('DESCRIPTION')
    )


if __name__ == '__main__':
    main()
