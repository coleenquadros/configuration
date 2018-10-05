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
<h1>App-interface schema validator</h1>
<ul>
<li><strong>Checked files</strong>: {{ results | length }}</li>
<li><strong>Errors</strong>: {{ errors | length }}</li>
<li><a href='results.json'>results.json</a></li>
</ul>

{% if errors | length > 0 %}
<h2>Validation Errors</h2>
{% for error in errors %}
    <h3>{{ error.filename }}</h3>
    <ul>
        <li><strong>REASON</strong>: <code>{{ error.result.reason }}</code></li>
        <li><strong>SCHEMA_URL</strong>: <code>{{ error.result.schema_url }}</code></li>
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
    )


if __name__ == '__main__':
    main()
