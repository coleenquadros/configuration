#!/usr/bin/env python

import glob
import logging
import os
import re
import sys


import anymarkup
import json
import jsonschema
import requests

APP_ROOT = os.environ['APP_ROOT']

logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.INFO)


class MissingSchemaFile(Exception):
    def __init__(self, path):
        self.path = path
        message = "file not found: {}".format(path)
        super(Exception, self).__init__(message)


class ValidationResult(object):
    def summary(self):
        status = 'OK' if self.status else 'ERROR'
        return "{}: {} ({})".format(status, self.filename, self.schema_url)


class ValidationOK(ValidationResult):
    status = True

    def __init__(self, filename, schema_url):
        self.filename = filename
        self.schema_url = schema_url

    def dump(self):
        return {
            "filename": self.filename,
            "result": {
                "summary": self.summary(),
                "status": "OK",
                "schema_url": self.schema_url,
            }
        }


class ValidationError(ValidationResult):
    status = False

    def __init__(self, filename, reason, error, schema_url=None):
        self.filename = filename
        self.reason = reason
        self.error = error
        self.schema_url = schema_url

    def dump(self):
        return {
            "filename": self.filename,
            "result": {
                "summary": self.summary(),
                "status": "ERROR",
                "schema_url": self.schema_url,
                "reason": self.reason,
                "error": self.error.__str__()
            }
        }

    def error_info(self):
        if self.error.message:
            msg = "{}\n{}".format(self.reason, self.error.message)
        else:
            msg = self.reason

        return msg


def validate_file(filename):
    logging.info('validating: {}'.format(filename))

    try:
        data = anymarkup.parse_file(filename)
    except anymarkup.AnyMarkupError as e:
        return ValidationError(filename, "FILE_PARSE_ERROR", e)

    try:
        schema_url = data[u'$schema']
    except KeyError as e:
        return ValidationError(filename, "MISSING_SCHEMA_URL", e)

    try:
        schema = fetch_schema(schema_url)
    except MissingSchemaFile as e:
        return ValidationError(filename, "MISSING_SCHEMA_FILE", e, schema_url)
    except requests.HTTPError as e:
        return ValidationError(filename, "HTTP_ERROR", e, schema_url)
    except anymarkup.AnyMarkupError as e:
        return ValidationError(filename, "SCHEMA_PARSE_ERROR", e, schema_url)

    try:
        jsonschema.validate(data, schema)
    except jsonschema.ValidationError as e:
        return ValidationError(filename, "VALIDATION_ERROR", e, schema_url)
    except jsonschema.SchemaError as e:
        return ValidationError(filename, "SCHEMA_ERROR", e, schema_url)

    return ValidationOK(filename, schema_url)


def fetch_schema(schema_url):
    if schema_url.startswith('http'):
        r = requests.get(schema_url)
        r.raise_for_status()
        schema = r.text
    else:
        schema = fetch_schema_file(schema_url)

    return anymarkup.parse(schema)


def fetch_schema_file(schema_url):
    schema_file = os.path.join(APP_ROOT, schema_url.lstrip('/'))

    if not os.path.isfile(schema_file):
        raise MissingSchemaFile(schema_file)

    with open(schema_file, 'r') as f:
        schema = f.read()

    return schema


def main():
    results = [
        validate_file(path).dump()
        for arg in sys.argv[1:]
        for path in glob.glob(arg)
        if os.path.isfile(path) and re.search("\.(json|ya?ml)$", path)
    ]

    errors = [
        r
        for r in results
        if r['result']['status'] == 'ERROR'
    ]

    print json.dumps(results)

    if len(errors) > 0:
        sys.exit(1)


if __name__ == '__main__':
    main()
