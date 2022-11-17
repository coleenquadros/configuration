#!/usr/bin/env python3
"""Utility to generate Operator lifecycle manager configuration
for App-Interface. This script takes a cluster-name as an
argument and generates the manifest file under
app-interface/data/openshift/<cluster>/namespaces/openshift-operator-lifecycle-manager.yml
"""

import logging

from pathlib import Path
from ruamel.yaml import YAML

log = logging.getLogger(__name__)

MANIFEST = "openshift-operator-lifecycle-manager.yml"

TEMPLATE = """\
$schema: /openshift/namespace-1.yml

labels: {{}}

name: openshift-operator-lifecycle-manager

cluster:
  $ref: /openshift/{cluster}/cluster.yml

app:
  $ref: /services/app-sre/app.yml

environment:
  $ref: /products/app-sre/environments/production.yml

description: openshift-operator-lifecycle-manager namespace
"""


def create_namespace(data_dir: str, cluster: str) -> None:
    """Generates the OLM namespace manifest into the data directory"""
    cluster_path = Path(data_dir, "openshift", cluster)

    if not cluster_path.exists():
        log.error("%s does not exist", cluster_path)
        raise FileNotFoundError(f"{cluster_path} does not exist")

    yaml = YAML()
    yaml.explicit_start = True
    code = yaml.load(TEMPLATE.format(cluster=cluster))
    manifest = Path(cluster_path, "namespaces", MANIFEST)
    if manifest.exists():
        log.error("%s already exists", manifest)
        raise FileExistsError(f"{manifest} already exists")

    manifest.parent.mkdir(parents=True, exist_ok=True)
    with open(manifest, mode="w", encoding="utf8") as out:
        yaml.dump(code, out)

    log.info("%s created succesfully", manifest)
