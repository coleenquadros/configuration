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
    pass


class InvalidSchemaUrl(Exception):
    pass


class ValidationResult(object):
    def summary(self):
        status = 'OK' if self.status else 'ERROR'
        return "%s: %s (%s)" % (status, self.filename, self.schema_url)


class ValidationResultOK(ValidationResult):
    status = True

    def __init__(self, filename, schema_url):
        self.filename = filename
        self.schema_url = schema_url

    def dump_obj(self):
        return {
            self.filename: {
                "status": "OK",
                "schema_url": self.schema_url,
            }
        }


class ValidationResultError(ValidationResult):
    status = False

    def __init__(self, filename, schema_url, reason, error):
        self.filename = filename
        self.schema_url = schema_url
        self.reason = reason
        self.error = error

    def error_info(self):
        if self.error.message:
            msg = "%s\n%s" % (self.reason, self.error.message)
        else:
            msg = self.reason

        return msg

    def dump_obj(self):
        return {
            self.filename: {
                "status": "ERROR",
                "schema_url": self.schema_url,
                "reason": self.reason,
                "error": self.error.message
            }
        }


class ValidateFile(object):

    """path to the filename to validate"""
    filename = None

    """schema url as it appears in the file to validate"""
    schema_url = None

    def __init__(self, filename):
        self.filename = filename

    def validate(self):
        try:
            data = anymarkup.parse_file(self.filename)
        except anymarkup.AnyMarkupError as e:
            return self._error("FILE_PARSE_ERROR", e)

        try:
            self.schema_url = data[u'$schema']
        except KeyError as e:
            return self._error("MISSING_SCHEMA_URL", e)

        try:
            schema = self.get_schema()
        except MissingSchemaFile as e:
            return self._error("MISSING_SCHEMA_FILE", e)
        except requests.HTTPError as e:
            return self._error("HTTP_ERROR", e)
        except anymarkup.AnyMarkupError as e:
            return self._error("SCHEMA_PARSE_ERROR", e)

        try:
            jsonschema.validate(data, schema)
        except jsonschema.ValidationError as e:
            return self._error("VALIDATION_ERROR", e)

        return self._ok()

    def get_schema(self):
        if self.schema_url[0] == '/':
            schema_url = self.schema_url[1:]
            schema_file = os.path.join(APP_ROOT, schema_url)

            if not os.path.isfile(schema_file):
                raise MissingSchemaFile()

            with open(schema_file, 'r') as f:
                schema = f.read()
        elif schema_url.startswith('http'):
            r = requests.get(schema_url)
            r.raise_for_status()
            schema = r.text
        else:
            raise InvalidSchemaUrl()

        return anymarkup.parse(schema)

    def _error(self, reason, error):
        return ValidationResultError(self.filename, self.schema_url, reason,
                                     error)

    def _ok(self):
        return ValidationResultOK(self.filename, self.schema_url)


def main():
    filenames = []
    for arg in sys.argv[1:]:
        filenames.extend(glob.glob(arg))

    results = []
    results_error_output = []
    for filename in filenames:
        is_file = os.path.isfile(filename)
        is_markup = re.search("\.(json|ya?ml)$", filename)

        if is_file and is_markup:
            v = ValidateFile(filename)
            validation_result = v.validate()
            logging.info(validation_result.summary())
            results.append(validation_result)

            if not validation_result.status:
                results_error_output.append(validation_result.dump_obj())

    if len(results_error_output) == 0:
        sys.exit(0)
    else:
        print json.dumps(results_error_output)
        sys.exit(1)


if __name__ == '__main__':
    main()
