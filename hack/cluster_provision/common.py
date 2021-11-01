from pathlib import Path
from typing import Mapping

from ruamel.yaml import YAML


CLUSTER_CONFIG_FILENAME = 'openshift/{cluster}/cluster.yml'

PRODUCTION = 'production'
STAGE = 'stage'


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
    cluster_config = Path(data_dir,
                          CLUSTER_CONFIG_FILENAME.format(cluster=cluster))

    if cluster_config.exists():
        return True
    else:
        return False


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
