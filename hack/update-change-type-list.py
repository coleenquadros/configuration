#!/usr/bin/env python3

# list all files in current directory
import os
import yaml
import jinja2
from typing import Any

def path_of_current_file():
    return os.path.dirname(os.path.realpath(__file__))

app_interface_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
relative_change_type_dir = "/app-interface/changetype"

def load_change_types() -> dict[str, dict[str, Any]]:
    change_type_dir = f"{app_interface_dir}/data/{relative_change_type_dir}"
    change_types: dict[str, dict[str, Any]] = {}
    for file in os.listdir(change_type_dir):
        if file.endswith(".yml"):
            with open(os.path.join(change_type_dir, file)) as f:
                data = yaml.load(f, Loader=yaml.FullLoader)
                change_types[file] = data
    return change_types

tmpl_env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath="./"))
template = tmpl_env.get_template("available-change-types.md.j2")

# write string to file
with open(f"{app_interface_dir}/docs/app-sre/available-change-types.md", "w") as f:
    f.write(template.render({"relative_change_type_dir": relative_change_type_dir, "change_types": load_change_types()}))
    f.write("\n")
