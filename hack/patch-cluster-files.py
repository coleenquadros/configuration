#!/usr/bin/env python

from typing import Generator, OrderedDict, Tuple
from ruamel.yaml import YAML
from pathlib import Path

yaml = YAML()
yaml.preserve_quotes = True  # type: ignore
yaml.explicit_start = True  # type: ignore
APP_INTERFACE_PATH = Path(__file__).parent.parent


def get_files_by_schema(schema) -> Generator[Tuple[Path, OrderedDict], None, None]:
    for i in (APP_INTERFACE_PATH / "data").glob("**/*"):
        if not i.is_file():
            continue

        try:
            content = i.read_text()
        except UnicodeDecodeError:
            # not a text file
            continue

        if "$schema: " not in content:
            # not a schema file
            continue

        for line in content.splitlines():
            if not line.startswith("$schema: "):
                continue
            if schema in line:
                yield i, yaml.load(content)
                # next file please
                break


def run():
    for cluster_file, cluster in get_files_by_schema(schema="/openshift/cluster-1.yml"):
        if "auth" not in cluster:
            # no auth attribute
            print(f"{cluster_file.relative_to(APP_INTERFACE_PATH)}: setting 'auth: []'")
            cluster["auth"] = []
            yaml.dump(cluster, cluster_file)
        elif not isinstance(cluster["auth"], list):
            # convert to list
            print(
                f"{cluster_file.relative_to(APP_INTERFACE_PATH)}: converting existing auth attribute to a list"
            )
            cluster["auth"] = [cluster["auth"]]
            yaml.dump(cluster, cluster_file)


if __name__ == "__main__":
    run()
