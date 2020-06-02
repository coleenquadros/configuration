#!/usr/bin/env python

import logging
import os
import sys

SKIP_EXTS = [
    ".png",
    ".jpg",
    ".drawio",
    ".gif",
]

logging.basicConfig(format='%(levelname)s: %(message)s')

error = False
for file_name in sys.stdin:
    file_name = file_name.strip()

    if os.path.splitext(file_name)[1] in SKIP_EXTS:
        logging.info([file_name, "skipping file (extension)"])
        continue

    with open(file_name, 'rb') as f:
        try:
            f.seek(-1, os.SEEK_END)
        except (OSError, IOError):
            logging.info([file_name, "could not read"])
            continue

        last_char = f.read()
        if last_char != b'\n':
            error = True
            logging.error([file_name, "no newline at EOF"])

if error:
    sys.exit(1)

sys.exit(0)
