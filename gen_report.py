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
<h1>App-Interface Schema Validator</h1>
<p>Raw results: <a href='results.json'>results.json</a></p>
<p>Summary:</p>
<ul>
<li>Checked files: {{ results | length }}</li>
<li>Errors: {{ errors | length }}</li>
{% if description %}
<li>MR: <a href="{{ description }}">{{ description }}</a></li>
{% endif %}
</ul>

{% if errors | length > 0 %}
<h2>Validation Errors</h2>
{% for error in errors %}
    <h3>{{ error.filename }}</h3>
    <ul>
        <li>REASON: <code>{{ error.result.reason }}</code></li>
        <li>SCHEMA_URL: <code>{{ error.result.schema_url }}</code></li>
    </ul>
    <pre><code>{{ error.result.error | e }}</code></pre>
{% endfor %}
{% endif %}

</body>
</html>
"""


def main():
    with open(sys.argv[1], 'r') as f:
        results = json.load(f)

    errors = [
        i
        for i in results
        if i["result"]["status"] == "ERROR"
    ]

    template = jinja2.Template(REPORT_TEMPLATE)

    print template.render(
        results=results,
        errors=errors,
        description=os.environ.get('DESCRIPTION')
    )


if __name__ == '__main__':
    main()
