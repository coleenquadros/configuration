#!/usr/bin/python
import base64
import subprocess
import sys
import tempfile
import yaml


if __name__ == '__main__':
    with tempfile.TemporaryDirectory() as d, \
         open(sys.argv[1]) as f:
        data = yaml.safe_load(f)
        key = base64.b64decode(data['public_gpg_key'])
        subprocess.run('gpg --import --homedir'.split() + [d],
                        input=key)
        subprocess.run('gpg --list-keys --homedir'.split() + [d])
