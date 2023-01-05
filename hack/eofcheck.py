#!/usr/bin/env python3

import logging
import os
import re
import sys

from binaryornot.check import is_binary

IGNORE_PATTERN = re.compile(r"^hack/new_osd_operator/.*\.tpl$")

logging.basicConfig(format="%(levelname)s: %(message)s")

error = False
for file_name in sys.stdin:
    file_name = file_name.strip()

    if is_binary(file_name):
        logging.info([file_name, "skipping binary file"])
        continue

    if re.search(IGNORE_PATTERN, file_name):
        logging.info([file_name, "skipping file matching IGNORE_PATTERN"])
        continue

    with open(file_name, "rb") as f:
        try:
            f.seek(-1, os.SEEK_END)
        except (OSError, IOError):
            logging.info([file_name, "could not read"])
            continue

        last_char = f.read()
        if last_char != b"\n":
            error = True
            logging.error([file_name, "no newline at EOF"])

if error:
    sys.exit(1)

sys.exit(0)
