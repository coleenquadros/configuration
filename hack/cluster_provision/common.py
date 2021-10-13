from pathlib import Path
from typing import Mapping

from ruamel.yaml import YAML


def get_base_yaml() -> YAML:
    """Create a YAML object with the minimal required options for all files."""
    yaml = YAML()
    yaml.explicit_start = True
    return yaml


def read_yaml_from_file(path: str):
    """Convenience function for reading data from a YAML file."""
    yaml = get_base_yaml()
    with open(path, mode='r', encoding='utf-8') as yaml_file:
        contents = yaml.load(yaml_file)
    return contents


def write_yaml_to_file(path: str, contents: Mapping, overwrite=True) -> None:
    """Convenience function for writing YAML to a file."""
    path = Path(path)

    if path.exists() and not overwrite:
        raise FileExistsError(f"{path} already exists and overwrite="
                              f"{overwrite}")

    path.parent.mkdir(parents=True, exist_ok=True)

    with open(path, mode='w', encoding="utf8") as f:
        yaml = get_base_yaml()
        yaml.dump(contents, f)
