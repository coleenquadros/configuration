"""Generate Container Security Operator configs for a cluster."""
import logging
import os
from pathlib import Path
from typing import Dict, Any, Mapping

from .common import (
    get_base_yaml,
    write_yaml_to_file,
    cluster_config_exists,
    read_yaml_from_file,
)

log = logging.getLogger(__name__)

CSO_FILENAME = "openshift/{cluster}/namespaces/app-sre-cso-per-cluster.yml"

SAAS_FILENAME = "services/container-security-operator/cicd/saas.yaml"

CSO_TEMPLATE = """
---
$schema: /openshift/namespace-1.yml

labels: {{}}

name: container-security-operator
description: namespace for the app-sre per-cluster Container Security Operator

cluster:
  $ref: /openshift/{cluster}/cluster.yml

app:
  $ref: /services/container-security-operator/app.yml

environment:
  $ref: /products/dashdot/environments/production.yml

networkPoliciesAllow:
- $ref: /openshift/{cluster}/namespaces/openshift-operator-lifecycle-manager.yml
"""

SAAS_TARGET_TEMPLATE = """
namespace:
  $ref: /openshift/{cluster}/namespaces/app-sre-cso-per-cluster.yml
ref: {commit_hash}
"""


def create_cso_per_cluster(cluster: str) -> Dict[str, Any]:
    """
    Generates the CSO configuration for a cluster.
    :param cluster: the cluster name
    :return: CSO configuration data for the cluster
    """
    yaml = get_base_yaml()
    cso_template = yaml.load(CSO_TEMPLATE.format(cluster=cluster))
    return cso_template


def add_saas_target(data: Mapping, cluster: str) -> bool:
    """
    Adds a target to the CSO SaaS configuration.
    :param data: SaaS configuration data
    :param cluster: cluster name
    :return: whether the data change or not
    """
    yaml = get_base_yaml()

    targets = data["resourceTemplates"][0]["targets"]

    commit_hashes = {t["ref"] for t in targets if t["ref"] != "master"}

    # Currently production uses the same commit hash and stage uses
    # 'master', so we can easily detect this. New logic will need to be
    # implemented in the future if this isn't a safe assumption.
    if len(commit_hashes) > 1:
        raise ValueError(
            "Could not determine which commit to use for "
            "the SaaS target, more than one option: "
            f"{commit_hashes}"
        )

    commit_hash = commit_hashes.pop()

    saas_target_entry = yaml.load(
        SAAS_TARGET_TEMPLATE.format(cluster=cluster, commit_hash=commit_hash)
    )

    if saas_target_entry in targets:
        log.info("No action required, SaaS target entry already exists")
        return False
    else:
        log.info("Adding SaaS target entry")
        targets.append(saas_target_entry)

        # Sort the targets now that the new entry has been added. This
        # shouldn't harm formatting because there aren't any commented
        # blocks in the list.
        data["resourceTemplates"][0]["targets"] = sorted(
            targets, key=lambda k: k["namespace"]["$ref"]
        )
        return True


def main(data_dir: str, cluster: str) -> None:

    if not os.path.exists(data_dir):
        raise FileNotFoundError(f"{data_dir} does not exist")

    if not cluster_config_exists(data_dir, cluster):
        raise FileNotFoundError(
            f"Cluster configuration doesn't exist for "
            f"{cluster}, check if the cluster name was "
            f"mistyped"
        )

    # Create the app-sre-cso-per-cluster.yml namespace file for the cluster.
    logging.info("Creating app-sre-cso-per-cluster.yml")
    cso_per_cluster = create_cso_per_cluster(cluster)
    cso_cluster_path = Path(data_dir, CSO_FILENAME.format(cluster=cluster))
    write_yaml_to_file(str(cso_cluster_path), cso_per_cluster)

    # Update the CSO SaaS file to add the new namespace to the target
    # namespaces.
    saas_path = Path(data_dir, SAAS_FILENAME)
    saas_data = read_yaml_from_file(str(saas_path))
    if add_saas_target(saas_data, cluster):
        write_yaml_to_file(str(saas_path), saas_data)
