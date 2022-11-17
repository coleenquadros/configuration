import os
import logging
from pathlib import Path
from typing import Any, Mapping

from ruamel.yaml import YAML


CLUSTER_CONFIG_FILENAME = "openshift/{cluster}/cluster.yml"

PRODUCTION = "production"
STAGE = "stage"


def cluster_config_exists(data_dir: str, cluster: str) -> bool:
    """
    Checks whether a cluster config exists. This config is the first step in
    cluster creation, so if it doesn't exist, nothing else will work. It
    also provides a basic check for cases where cluster args have been
    mistyped.

    :param data_dir: the directory that contains app-interface data
    :param cluster: the cluster name
    :return: whether the config exists or not
    """
    cluster_config = Path(data_dir, CLUSTER_CONFIG_FILENAME.format(cluster=cluster))

    if cluster_config.exists():
        return True
    else:
        return False


def get_base_yaml() -> YAML:
    """Create a YAML object with the minimal required options for all files."""
    yaml = YAML()
    yaml.explicit_start = True
    yaml.preserve_quotes = True
    return yaml


def read_yaml_from_file(path: str):
    """Convenience function for reading data from a YAML file."""
    yaml = get_base_yaml()
    with open(path, mode="r", encoding="utf-8") as yaml_file:
        contents = yaml.load(yaml_file)
    return contents


def write_yaml_to_file(_path: str, contents: Mapping, overwrite=True) -> None:
    """Convenience function for writing YAML to a file."""
    path = Path(_path)

    if path.exists() and not overwrite:
        raise FileExistsError(f"{path} already exists and overwrite=" f"{overwrite}")

    path.parent.mkdir(parents=True, exist_ok=True)

    with open(path, mode="w", encoding="utf8") as f:
        yaml = get_base_yaml()
        yaml.dump(contents, f)


def render_template_as_str(template: str, **kwargs) -> str:
    """Function to format a template with data and return a yaml object"""
    _cd = Path(__file__).parent.resolve()
    template_path = f"{_cd}/templates/{template}"
    with open(template_path, mode="r", encoding="utf-8") as f:
        content = f.read()
    data = content.format(**kwargs)
    return data


def render_template_as_yaml(template: str, **kwargs) -> Mapping:
    data = render_template_as_str(template, **kwargs)
    yamlobj = get_base_yaml().load(data)
    return yamlobj


def get_yaml_attribute(file_path: str, attribute: str) -> Any:
    """Gets an attribute from a yaml file"""
    obj = read_yaml_from_file(file_path)
    return obj.get(attribute, None)


def create_file_from_template(path: str, template: str, **data) -> None:
    """Creates a file from a template formatted with data"""
    if os.path.exists(path):
        logging.info("File %s already exists -- skipping", path)
        return

    yaml_obj = render_template_as_yaml(template, **data)
    write_yaml_to_file(path, yaml_obj)
    logging.info("File %s wrote successfully with %s template data", path, template)
