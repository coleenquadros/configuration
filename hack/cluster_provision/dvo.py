"""Generate Deployment Validation Operator configs for a cluster."""

import logging
import os
from pathlib import Path
from typing import Dict, Any, Mapping, MutableMapping

from .common import (
    STAGE,
    read_yaml_from_file,
    write_yaml_to_file,
    get_base_yaml,
    cluster_config_exists,
)

log = logging.getLogger(__name__)

DVO_FILENAME = (
    "openshift/{cluster}/namespaces/" "openshift-deployment-validation-operator.yml"
)

CUSTOMER_MON_FILENAME = (
    "services/observability/namespaces/" "openshift-customer-monitoring.{cluster}.yml"
)

MON_NAMESPACES_FILENAME = "services/observability/roles/" "monitored-dvo-namespaces.yml"

DVO_TEMPLATE = """
---
$schema: /openshift/namespace-1.yml

labels: {{}}

name: openshift-deployment-validation-operator
description: namespace for the OSD Deployment Validation Operator

cluster:
  $ref: /openshift/{cluster}/cluster.yml

app:
  $ref: /services/osd-operators/deployment-validation-operator/app.yml

environment:
  $ref: /products/app-sre/environments/production.yml

clusterAdmin: true

managedRoles: true

networkPoliciesAllow:
- $ref: /services/observability/namespaces/openshift-customer-monitoring.{cluster}.yml
"""

SERVICE_MONITOR = """
- $ref: /services/observability/shared-resources/dvo-openshift.yml
- $ref: /services/observability/shared-resources/dvo-alerts.yml
"""

MON_NAMESPACES_ACCESS = """
namespace:
  $ref: /openshift/{cluster}/namespaces/openshift-deployment-validation-operator.yml
role: view
"""


def create_dvo_per_cluster(cluster: str) -> Dict[str, Any]:
    """
    Generates the DVO configuration for a cluster.
    :param cluster: the cluster name
    :return: DVO configuration data for the cluster
    """

    yaml = get_base_yaml()
    dvo_template = yaml.load(DVO_TEMPLATE.format(cluster=cluster))
    return dvo_template


def add_dvo_service_monitor(data: Mapping) -> bool:
    """
    Add a service monitor for DVO.
    :param data: cluster data
    :return: whether the resource changed or not
    """
    yaml = get_base_yaml()

    added = False

    if "sharedResources" in data:
        for m in SERVICE_MONITOR:
            if m not in data["sharedResources"]:
                data["sharedResources"].append(m)
                added = True
    else:
        data["sharedResources"] = yaml.load(SERVICE_MONITOR)
        added = True

    if added:
        log.info("Adding service monitor entry")
    else:
        log.info("No action required, service monitor entry already exists")

    return added


def grant_service_account_perms(data: MutableMapping, cluster: str) -> bool:
    """
    Grant the required permissions to the appropriate service accounts.
    :param data: Role configuration data
    :param cluster: cluster name
    :return: whether the data changed or not
    """
    yaml = get_base_yaml()
    namespace_entry = yaml.load(MON_NAMESPACES_ACCESS.format(cluster=cluster))

    access = data["access"]

    if namespace_entry in access:
        log.info("No action required, service account permissions already " "added")
        return False
    else:
        log.info("Adding service account permissions")
        access.append(namespace_entry)

        # Sort the targets now that the new entry has been added.
        data["access"] = sorted(access, key=lambda k: k["namespace"]["$ref"])
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

    # Create the openshift-deployment-validation-operator.yml namespace file
    # for the cluster.
    log.info("Creating openshift-deployment-validation-operator.yml")
    dvo_per_cluster = create_dvo_per_cluster(cluster)
    dvo_cluster_path = Path(data_dir, DVO_FILENAME.format(cluster=cluster))
    write_yaml_to_file(str(dvo_cluster_path), dvo_per_cluster)

    # Add a service monitor to the cluster for DVO.
    customer_mon_path = Path(data_dir, CUSTOMER_MON_FILENAME.format(cluster=cluster))
    customer_mon_data = read_yaml_from_file(str(customer_mon_path))
    if add_dvo_service_monitor(customer_mon_data):
        write_yaml_to_file(str(customer_mon_path), customer_mon_data)

    # Grant view permissions to the appropriate service accounts.
    mon_namespace_path = Path(data_dir, MON_NAMESPACES_FILENAME)
    mon_namespace_data = read_yaml_from_file(str(mon_namespace_path))
    if grant_service_account_perms(mon_namespace_data, cluster):
        write_yaml_to_file(str(mon_namespace_path), mon_namespace_data)
