"""Generate Deployment Validation Operator configs for a cluster."""

import logging
import os
from pathlib import Path
from typing import Dict, Any, Mapping, MutableMapping

from .common import STAGE, read_yaml_from_file, write_yaml_to_file, \
    get_base_yaml, cluster_config_exists

log = logging.getLogger(__name__)

DVO_FILENAME = 'openshift/{cluster}/namespaces/' \
               'deployment-validation-operator-per-cluster.yml'

CUSTOMER_MON_FILENAME = 'services/observability/namespaces/' \
                           'openshift-customer-monitoring.{cluster}.yml'

SAAS_FILENAME = 'services/deployment-validation-operator/cicd/saas.yaml'

MON_NAMESPACES_FILENAME = 'services/observability/roles/' \
                          'monitored-dvo-namespaces.yml'

DVO_TEMPLATE = """
---
$schema: /openshift/namespace-1.yml

labels: {{}}

name: deployment-validation-operator
description: namespace for the app-sre per-cluster Deployment Validation Operator

cluster:
  $ref: /openshift/{cluster}/cluster.yml

app:
  $ref: /services/deployment-validation-operator/app.yml

environment:
  $ref: /products/app-sre/environments/production.yml

networkPoliciesAllow:
- $ref: /openshift/{cluster}/namespaces/openshift-operator-lifecycle-manager.yml
- $ref: /services/observability/namespaces/openshift-customer-monitoring.{cluster}.yml

managedRoles: true

managedResourceTypes:
- ConfigMap
- Service

sharedResources:
- $ref: /services/deployment-validation-operator/shared-resources/dvo.yml
"""

SERVICE_MONITOR = """
- $ref: /services/observability/shared-resources/dvo.yml
- $ref: /services/observability/shared-resources/dvo-alerts.yml
"""

SAAS_TARGET_TEMPLATE = """
namespace:
  $ref: /openshift/{cluster}/namespaces/deployment-validation-operator-per-cluster.yml
ref: {commit_hash}
"""

SAAS_TARGET_STAGE_UPSTREAM = """\
upstream:
  instance:
    $ref: /dependencies/ci-int/ci-int.yml
  name: app-sre-deployment-validation-operator-gh-build-master
"""

MON_NAMESPACES_ACCESS = """
namespace:
  $ref: /openshift/{cluster}/namespaces/deployment-validation-operator-per-cluster.yml
role: view
"""


def create_dvo_per_cluster(cluster: str) -> Dict[str, Any]:
    """
    Generates the DVO configuration for a cluster.
    :param cluster: the cluster name
    :return: DVO configuration data for the cluster
    """

    yaml = get_base_yaml()
    dvo_template = yaml.load(
        DVO_TEMPLATE.format(cluster=cluster)
    )
    return dvo_template


def add_dvo_service_monitor(data: Mapping) -> bool:
    """
    Add a service monitor for DVO.
    :param data: cluster data
    :return: whether the resource changed or not
    """
    yaml = get_base_yaml()

    added = False

    if 'sharedResources' in data:
        for m in SERVICE_MONITOR:
            if m not in data['sharedResources']:
                data['sharedResources'].append(m)
                added = True
    else:
        data["sharedResources"] = yaml.load(SERVICE_MONITOR)
        added = True

    if added:
        log.info('Adding service monitor entry')
    else:
        log.info('No action required, service monitor entry already exists')
    
    return added


def add_saas_target(data: Mapping, cluster: str) -> bool:
    """
    Adds a target to the DVO SaaS configuration.
    :param data: SaaS configuration data
    :param cluster: cluster name
    :return: whether the data change or not
    """
    yaml = get_base_yaml()

    targets = data['resourceTemplates'][0]['targets']

    template = SAAS_TARGET_TEMPLATE
    commit_hashes = {t['ref'] for t in targets if t['ref'] != 'master'}

    # Currently production uses the same commit hash and stage uses
    # 'master', so we can easily detect this. New logic will need to be
    # implemented in the future if this isn't a safe assumption.
    if len(commit_hashes) > 1:
        raise ValueError('Could not determine which commit to use for '
                         'the SaaS target, more than one option: '
                         f'{commit_hashes}')

    commit_hash = commit_hashes.pop()

    saas_target_entry = yaml.load(template.format(
        cluster=cluster, commit_hash=commit_hash))

    if saas_target_entry in targets:
        log.info('No action required, SaaS target entry already exists')
        return False
    else:
        log.info('Adding SaaS target entry')
        targets.append(saas_target_entry)

        # Sort the targets now that the new entry has been added. This
        # shouldn't harm formatting because there aren't any commented
        # blocks in the list.
        data['resourceTemplates'][0]['targets'] = \
            sorted(targets, key=lambda k: k['namespace']['$ref'])
        return True


def grant_service_account_perms(data: MutableMapping, cluster: str) -> bool:
    """
    Grant the required permissions to the appropriate service accounts.
    :param data: Role configuration data
    :param cluster: cluster name
    :return: whether the data changed or not
    """
    yaml = get_base_yaml()
    namespace_entry = yaml.load(
        MON_NAMESPACES_ACCESS.format(cluster=cluster)
    )

    access = data['access']

    if namespace_entry in access:
        log.info('No action required, service account permissions already '
                 'added')
        return False
    else:
        log.info('Adding service account permissions')
        access.append(namespace_entry)

        # Sort the targets now that the new entry has been added.
        data['access'] = sorted(access, key=lambda k: k['namespace']['$ref'])
        return True


def main(data_dir: str, cluster: str) -> None:

    if not os.path.exists(data_dir):
        raise FileNotFoundError(f"{data_dir} does not exist")

    if not cluster_config_exists(data_dir, cluster):
        raise FileNotFoundError(f"Cluster configuration doesn't exist for "
                                f"{cluster}, check if the cluster name was "
                                f"mistyped")

    # Create the deployment-validation-operator-per-cluster.yml namespace file
    # for the cluster.
    log.info('Creating deployment-validation-operator-per-cluster.yml')
    dvo_per_cluster = create_dvo_per_cluster(cluster)
    dvo_cluster_path = Path(data_dir, DVO_FILENAME.format(cluster=cluster))
    write_yaml_to_file(str(dvo_cluster_path), dvo_per_cluster)

    # Add a service monitor to the cluster for DVO.
    customer_mon_path = Path(data_dir, CUSTOMER_MON_FILENAME.format(
        cluster=cluster))
    customer_mon_data = read_yaml_from_file(str(customer_mon_path))
    if add_dvo_service_monitor(customer_mon_data):
        write_yaml_to_file(str(customer_mon_path), customer_mon_data)

    # Update the DVO SaaS file to add the new namespace to the target
    # namespaces.
    saas_path = Path(data_dir, SAAS_FILENAME)
    saas_data = read_yaml_from_file(str(saas_path))
    if add_saas_target(saas_data, cluster):
        write_yaml_to_file(str(saas_path), saas_data)

    # Grant view permissions to the appropriate service accounts.
    mon_namespace_path = Path(data_dir, MON_NAMESPACES_FILENAME)
    mon_namespace_data = read_yaml_from_file(str(mon_namespace_path))
    if grant_service_account_perms(mon_namespace_data, cluster):
        write_yaml_to_file(str(mon_namespace_path), mon_namespace_data)
