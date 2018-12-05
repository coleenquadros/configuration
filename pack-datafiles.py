#!/usr/bin/env python2

import os
import re
import sys

import anymarkup
import json

datadir = sys.argv[1]

if datadir[-1] != "/":
    datadir += "/"

datafiles = []

for root, dirs, files in os.walk(datadir, topdown=False):
    for name in files:
        if re.search(r'\.(ya?ml|json)$', name):
            path = os.path.join(root, name)
            sys.stderr.write("Processing: {}\n".format(path))

            data = anymarkup.parse_file(path)

            datafile = path[len(datadir):]
            datafiles.append([datafile, data])


print(json.dumps(datafiles, indent=4))
