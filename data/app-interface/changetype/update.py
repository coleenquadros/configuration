#!/usr/bin/env python3

# list all files in current directory
import os
import yaml
import jinja2
from typing import Any

def load_change_types() -> dict[str, dict[str, Any]]:
    change_types: dict[str, dict[str, Any]] = {}
    for file in os.listdir("."):
        if file.endswith(".yml"):
            print(os.path.join(".", file))
            with open(file) as f:
                data = yaml.load(f, Loader=yaml.FullLoader)
                change_types[file] = data
    return change_types

tmpl_env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath="./"))
template = tmpl_env.get_template("README.md.j2")

# write string to file
with open("README.md", "w") as f:
    f.write(template.render({"change_types": load_change_types()}))
