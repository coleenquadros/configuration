#!/usr/bin/env python

import json
import sys

import jinja2

REPORT_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <link rel='stylesheet' href='main.css'>
</head>
<body>

{% if schema_errors | length > 0 %}
<h1>Schema Errors</h1>
{% for error in schema_errors %}
    <h3>{{ error.filename }}</h3>
    <ul>
        <li><strong>REASON</strong>: <code>{{ error.result.reason }}</code></li>
        <li><strong>SCHEMA_URL</strong>: <code>{{ error.result.schema_url }}</code></li>
    </ul>
    <pre><code>{{ error.result.error | e }}</code></pre>
{% endfor %}
{% endif %}

{% if validation_errors | length > 0 %}
<h1>Validation Errors</h1>
{% for error in validation_errors %}
    <h3>{{ error.filename }}</h3>
    <ul>
        <li><strong>REASON</strong>: <code>{{ error.result.reason }}</code></li>
        <li><strong>SCHEMA_URL</strong>: <code>{{ error.result.schema_url }}</code></li>
    </ul>
    <pre><code>{{ error.result.error | e }}</code></pre>
{% endfor %}
{% endif %}

<h1>RAW report</h1>
<pre class="wrap"><code>{{ raw_report | safe }}</pre></code>
</body>
</html>
"""


def main():
    with open(sys.argv[1], 'r') as f:
        results = json.load(f)

    schema_errors = [
        i
        for i in results
        if i["result"]["status"] == "ERROR" and
        i["result"]["reason"] == "SCHEMA_ERROR"
    ]

    validation_errors = [
        i
        for i in results
        if i["result"]["status"] == "ERROR" and
        i["result"]["reason"] != "SCHEMA_ERROR"
    ]

    raw_report = json.dumps(results, indent=4, separators=(',', ': '))

    template = jinja2.Template(REPORT_TEMPLATE)
    print template.render(
        raw_report=raw_report,
        schema_errors=schema_errors,
        validation_errors=validation_errors
    )


if __name__ == '__main__':
    main()
