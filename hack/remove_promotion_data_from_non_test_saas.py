import os

from ruamel.yaml import YAML
from ruamel.yaml.compat import StringIO


yml = YAML(typ="rt", pure=True)


def remove_prom_data_from_target(content):
    if not content:
        return False
    promotion = content.get("promotion")
    if not promotion:
        return False
    if "promotion_data" in promotion:
        promotion.pop("promotion_data")
        return True
    return False


def handle_content(content):
    if not content:
        return False
    if content["$schema"] == "/app-sre/saas-file-target-1.yml":
        return remove_prom_data_from_target(content)
    elif content["$schema"] == "/app-sre/saas-file-2.yml":
        changed = False
        for rt in content.get("resourceTemplates", []):
            for target in rt.get("targets", []):
                changed |= remove_prom_data_from_target(target)
        return changed
    return False


for root, dirs, files in os.walk("data/services/"):
    for file in files:
        file_path = f"{root}/{file}"
        with open(file_path, "r") as f:            
            content = yml.load(f.read())
        if not content:
            continue
        if content.get("$schema") not in {"/app-sre/saas-file-target-1.yml", "/app-sre/saas-file-2.yml"}:
            continue
        if content.get("publishJobLogs", False):
            continue
        if not handle_content(content):
            continue
        new_content = "---\n"
        with StringIO() as stream:
            yml.dump(content, stream)
            new_content += stream.getvalue()
        with open(file_path, "w") as f:
            f.write(new_content)
