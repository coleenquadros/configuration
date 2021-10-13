#!/usr/bin/python
"""Receives a path to a user file in app-interface as an argument, and
some secret to be encrypted via stdin. Prints out the secret encrypted
with that user's public GPG key and encoded in base64, so that it can
be shared over email, slack or any other convenient but insecure
channel.

"""
import os
import base64
import subprocess
import sys
import tempfile
import yaml

filename = sys.argv[1]

if __name__ == '__main__':
    with tempfile.TemporaryDirectory() as d, \
         open(filename) as f:
        user = os.path.split(filename)[-1]
        # Remove the .yml suffix
        user = user[:-4]
        data = yaml.safe_load(f)
        key = base64.b64decode(data['public_gpg_key'])
        subprocess.run('gpg --import --homedir'.split() + [d],
                        input=key)

        out = subprocess.run(['gpg', '-r', user, '-e', '--homedir', d],
                             input=sys.stdin.buffer.read(),
                             capture_output=True)
        print(base64.b64encode(out.stdout).decode())
