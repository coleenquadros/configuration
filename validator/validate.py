#!/usr/bin/env python

import argparse
import glob
import logging
import os
import re
import sys

import anymarkup
import json
import jsonschema
import requests


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

    def __init__(self, kind, filename, schema_url):
        self.kind = kind
        self.filename = filename
        self.schema_url = schema_url

    def dump(self):
        return {
            "filename": self.filename,
            "kind": self.kind,
            "result": {
                "summary": self.summary(),
                "status": "OK",
                "schema_url": self.schema_url,
            }
        }


class ValidationError(ValidationResult):
    status = False

    def __init__(self, kind, filename, reason, error, schema_url=None):
        self.kind = kind
        self.filename = filename
        self.reason = reason
        self.error = error
        self.schema_url = schema_url

    def dump(self):
        return {
            "filename": self.filename,
            "kind": self.kind,
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


def validate_schema(schemas_root, filename, metaschema):
    kind = "SCHEMA"

    logging.info('validating schema: {}'.format(filename))

    schema_url = 'META_SCHEMA'

    try:
        data = anymarkup.parse_file(filename)
    except anymarkup.AnyMarkupError as e:
        return ValidationError(kind, filename, "FILE_PARSE_ERROR", e)

    try:
        jsonschema.Draft4Validator.check_schema(data)
        jsonschema.Draft4Validator(metaschema).validate(data)
    except jsonschema.ValidationError as e:
        return ValidationError(kind, filename, "VALIDATION_ERROR", e,
                               schema_url)
    except jsonschema.SchemaError as e:
        return ValidationError(kind, filename, "SCHEMA_ERROR", e, schema_url)

    return ValidationOK(kind, filename, schema_url)


def validate_file(schemas_root, filename):
    kind = "FILE"

    logging.info('validating file: {}'.format(filename))

    try:
        data = anymarkup.parse_file(filename)
    except anymarkup.AnyMarkupError as e:
        return ValidationError(kind, filename, "FILE_PARSE_ERROR", e)

    try:
        schema_url = data[u'$schema']
    except KeyError as e:
        return ValidationError(kind, filename, "MISSING_SCHEMA_URL", e)

    try:
        schema = fetch_schema(schemas_root, schema_url)
    except MissingSchemaFile as e:
        return ValidationError(kind, filename, "MISSING_SCHEMA_FILE", e,
                               schema_url)
    except requests.HTTPError as e:
        return ValidationError(kind, filename, "HTTP_ERROR", e, schema_url)
    except anymarkup.AnyMarkupError as e:
        return ValidationError(kind, filename, "SCHEMA_PARSE_ERROR", e,
                               schema_url)

    try:
        schema_path = "file://" + os.path.abspath(schemas_root) + '/'
        resolver = jsonschema.RefResolver(schema_path, schema)
        jsonschema.Draft4Validator(schema, resolver=resolver).validate(data)
    except jsonschema.ValidationError as e:
        return ValidationError(kind, filename, "VALIDATION_ERROR", e, schema_url)
    except jsonschema.SchemaError as e:
        return ValidationError(kind, filename, "SCHEMA_ERROR", e, schema_url)

    return ValidationOK(kind, filename, schema_url)


def fetch_schema(schemas_root, schema_url):
    if schema_url.startswith('http'):
        r = requests.get(schema_url)
        r.raise_for_status()
        schema = r.text
    else:
        schema = fetch_schema_file(schemas_root, schema_url)

    return anymarkup.parse(schema)


def fetch_schema_file(schemas_root, schema_url):
    schema_file = os.path.join(schemas_root, schema_url)

    if not os.path.isfile(schema_file):
        raise MissingSchemaFile(schema_file)

    with open(schema_file, 'r') as f:
        schema = f.read()

    return schema


def main():
    # Parser
    parser = argparse.ArgumentParser(
        description='App-Interface Schema Validator')

    parser.add_argument('--metaschema', required=True,
                        help='Path to the metaschema file')

    parser.add_argument('--schemas-root', required=True,
                        help='Root directory of the schemas')

    parser.add_argument('files', nargs='+',
                        help='List files to validate. Supports globbing.')

    args = parser.parse_args()

    # Metaschema
    schemas_root = args.schemas_root
    metaschema = fetch_schema(schemas_root, args.metaschema)
    jsonschema.Draft4Validator.check_schema(metaschema)

    # Find schemas
    schemas = [
        os.path.join(dirpath, filename)
        for dirpath, dirnames, filenames in os.walk(schemas_root)
        for filename in filenames
        if re.search("\.(json|ya?ml)$", filename)
    ]

    # Validate schemas
    results_schemas = [
        validate_schema(schemas_root, path, metaschema).dump()
        for path in schemas
        if os.path.isfile(path) and re.search("\.(json|ya?ml)$", path)
    ]

    # Validate files
    results_files = [
        validate_file(schemas_root, path).dump()
        for arg in args.files
        for path in glob.glob(arg)
        if os.path.isfile(path) and re.search("\.(json|ya?ml)$", path)
    ]

    # Calculate errors
    results = results_schemas + results_files

    errors = [
        r
        for r in results
        if r['result']['status'] == 'ERROR'
    ]

    # Output
    print json.dumps(results)

    if len(errors) > 0:
        sys.exit(1)


if __name__ == '__main__':
    main()
