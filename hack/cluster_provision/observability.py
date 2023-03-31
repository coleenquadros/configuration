"""Generate Observability configs for a cluster."""
import logging
import os
from contextlib import contextmanager
from typing import Any, Dict, Mapping, MutableMapping
from urllib.parse import urlparse

from .common import cluster_config_exists
from .common import create_file_from_template
from .common import get_yaml_attribute
from .common import read_yaml_from_file
from .common import write_yaml_to_file

log = logging.getLogger(__name__)

# DNS
DNS_FILE_CONFIG_PATH = "{data_dir}/aws/app-sre/dns/devshift.net.yaml"
DNS_OBSERVABILTY_RECORDS = ["prometheus.{cluster}", "alertmanager.{cluster}"]


# LOGGING
LOGGING_NS_TEMPLATE = "openshift-logging.tpl"
EVENT_ROUTER_NS_TEMPLATE = "app-sre-event-router.tpl"

LOGGING_NS_PATH = (
    "{data_dir}/openshift/{cluster}/namespaces/openshift-logging.yaml"
)

EVENT_ROUTER_NS_PATH = (
    "{data_dir}/openshift/{cluster}/namespaces/app-sre-event-router.yaml"
)

EVENT_ROUTER_SAAS_FILE = "{data_dir}/services/observability/cicd/saas/saas-event-router.yaml"

# CUSTOMER_MONITORING
CUSTOMER_MON_NS_TEMPLATE = "openshift-customer-monitoring.CLUSTERNAME.tpl"

CUSTOMER_MON_NS_PATH = (
    "{data_dir}/services/observability/namespaces/"
    "openshift-customer-monitoring.{cluster}.yml"
)

CUSTOMER_MON_JIRA_PHASE = {
    "integration": "app-sre-stage",
    "stage": "app-sre-stage",
    "production": "app-sre",
}

OBSERVABILITY_SAAS_ENVIRONMENTS = {
    "integration": "integration",
    "stage": "staging",
    "production": "production",
}

# OBSERVABILITY
OBSERVABILITY_ROLE_PATH = (
    "{data_dir}/services/observability/roles/"
    "app-sre-osdv4-monitored-clusters-view.yml"
)
OBSERVABILITY_SAAS_FILE = (
    "{data_dir}/services/observability/cicd/saas/" "saas-observability-per-cluster.yaml"
)

# APPSRE OBSERVABILTY NS
APPSRE_OBSERVABILITY_NS_PATH = (
    "{data_dir}/openshift/{cluster}/namespaces/" "app-sre-observability-per-cluster.yml"
)
APPSRE_OBSERVABILITY_NS_TEMPLATE = "app-sre-observability-per-cluster.tpl"
APPSRE_OBSERVABILITY_NS_ROLE = (
    "{data_dir}/services/observability/roles/observability-access-elevated.yml"
)
NGINX_SAAS_FILE = "{data_dir}/services/observability/cicd/saas/" "saas-nginx-proxy.yaml"

# GRAFANA
GRAFANA_SHARED_RESOURCES_PATH = "{data_dir}/services/observability/shared-resources/grafana.yml"
GRAFANA_CLUSTERS_SOURCE_PATH = "{data_dir}/openshift"


def _check_data_and_cluster_exists(data_dir: str, cluster: str) -> None:
    if not os.path.exists(data_dir):
        raise FileNotFoundError(f"{data_dir} does not exist")

    if not cluster_config_exists(data_dir, cluster):
        raise FileNotFoundError(
            f"Cluster configuration doesn't exist for "
            f"{cluster}, check if the cluster name was "
            f"mistyped"
        )


def _add_entry_to_role_access(role_path: str, entry: Mapping[str, Any]) -> bool:
    """Funtion to add a cluster/namespace entry to role permissions (access)"""
    if "cluster" in entry:
        etype = "cluster"
    elif "namespace" in entry:
        etype = "namespace"
    else:
        raise Exception(
            "Access element to role not supported, " "should be cluster or namespace"
        )
    role_data = read_yaml_from_file(role_path)
    element_ref = entry[etype]["$ref"]
    for _ns in role_data["access"]:
        ref = _ns[etype]["$ref"]
        if ref == element_ref:
            log.info(
                "Ref %s already set in role %s -- skipping", element_ref, role_path
            )
            return False
    role_data["access"].append(entry)
    write_yaml_to_file(role_path, role_data)
    log.info("Ref %s set sucessfully in %s", element_ref, role_path)
    return True


def _add_target_to_resource_template(
    saas_path: str,
    rt_name: str,
    entry: MutableMapping[str, Any],
    get_ref_from_last=False,
) -> None:
    saas_data = read_yaml_from_file(saas_path)
    resource_templates = saas_data["resourceTemplates"]
    ns_ref = entry["namespace"]["$ref"]
    rts = list(filter(lambda rt: rt["name"] == rt_name, resource_templates))
    if len(rts) == 0:
        raise Exception(
            f"No resource template with name {rt_name} in " f"{saas_path} saas file"
        )
    else:
        dest_rt = rts[0]
    dest_rt_targets = dest_rt["targets"]
    for target in dest_rt_targets:
        if target["namespace"]["$ref"] == ns_ref:
            log.info("Namespace %s already set in %s -- skipping", ns_ref, saas_path)
            return
    if get_ref_from_last:
        entry["ref"] = dest_rt_targets[-1].get("ref", "")
    dest_rt_targets.append(entry)
    write_yaml_to_file(saas_path, saas_data)
    log.info("Namespace %s set sucessfully in %s", ns_ref, saas_path)


def _get_cluster_yaml_attribute(data_dir: str, cluster: str, attr: str) -> Any:
    path = f"{data_dir}/openshift/{cluster}/cluster.yml"
    data = get_yaml_attribute(path, attr)
    return data


def create_dns_records(data_dir: str, cluster: str) -> None:
    """Create cluster observability dns records"""
    _check_data_and_cluster_exists(data_dir, cluster)
    dns_file = DNS_FILE_CONFIG_PATH.format(data_dir=data_dir)
    data = read_yaml_from_file(dns_file)

    new_records = []
    if not data:
        raise ValueError(f"No data read from {dns_file}")

    existent_dns_records = [r["name"] for r in data["records"]]

    for _r in DNS_OBSERVABILTY_RECORDS:
        record_name = _r.format(cluster=cluster)
        if record_name in existent_dns_records:
            log.info("%s dns record already exists -- skipping", record_name)
        else:
            log.info("Adding %s dns record", record_name)
            record = {
                "name": record_name,
                "type": "CNAME",
                "_target_cluster": {"$ref": f"/openshift/{cluster}/cluster.yml"},
            }
            new_records.append(record)

    if len(new_records) > 1:
        data["records"].extend(new_records)
        write_yaml_to_file(dns_file, data)


def create_customer_monitoring_ns(
    data_dir: str, cluster: str, environment: str
) -> None:
    """Function to create the customer monitoring namespace"""
    ns_path = CUSTOMER_MON_NS_PATH.format(data_dir=data_dir, cluster=cluster)
    create_file_from_template(
        ns_path,
        CUSTOMER_MON_NS_TEMPLATE,
        cluster=cluster,
        environment=environment,
        phase=CUSTOMER_MON_JIRA_PHASE[environment]
    )


def configure_customer_monitoring_ns(
    data_dir: str, cluster: str, environment: str
) -> None:
    """Function that does the required configuration for the
    customer monitoring namespace
    """
    _configure_cluster_for_customer_monitoring(data_dir, cluster)
    _add_customer_monitoring_ns_to_observability_saas(data_dir, cluster, OBSERVABILITY_SAAS_ENVIRONMENTS[environment])


def _configure_cluster_for_customer_monitoring(data_dir: str, cluster: str) -> None:
    """Function to configure cluster.yml manifest to enable customer
    monitoring
    """
    cluster_path = f"{data_dir}/openshift/{cluster}/cluster.yml"
    cluster_data = read_yaml_from_file(cluster_path)
    cluster_data["managedClusterRoles"] = True
    cluster_data["observabilityNamespace"] = {
        "$ref": (
            "/services/observability/namespaces"
            f"/openshift-customer-monitoring.{cluster}.yml"
        )
    }
    write_yaml_to_file(cluster_path, cluster_data)


def _add_customer_monitoring_ns_to_observability_saas(
    data_dir: str, cluster: str, environment: str
) -> None:
    """Function to add customer monitoring namespace target in the
    observability saas manifest
    """

    saas_path = OBSERVABILITY_SAAS_FILE.format(data_dir=data_dir)
    ns_ref = (
        "/services/observability/namespaces/"
        f"openshift-customer-monitoring.{cluster}.yml"
    )
    prom_entry = {
        "namespace": {
            "$ref": ns_ref,
        },
        "parameters": {
            "CLUSTER_LABEL": f"{cluster}",
            "ENVIRONMENT": f"{environment}",
            "EXTERNAL_URL": f"https://prometheus.{cluster}.devshift.net",
        },
    }
    am_entry = {
        "namespace": {
            "$ref": ns_ref,
        },
        "parameters": {
            "ENVIRONMENT": f"{environment}",
            "EXTERNAL_URL": f"https://alertmanager.{cluster}.devshift.net",
        },
    }
    _add_target_to_resource_template(saas_path, "prometheus", prom_entry, True)
    _add_target_to_resource_template(saas_path, "alertmanager", am_entry, True)


def add_cluster_to_observability_role(data_dir: str, cluster: str) -> None:
    """Function to add the cluster reference to the observability role"""
    role_path = OBSERVABILITY_ROLE_PATH.format(data_dir=data_dir)
    entry = {
        "cluster": {"$ref": f"/openshift/{cluster}/cluster.yml"},
        "clusterRole": "cluster-monitoring-view",
    }
    _add_entry_to_role_access(role_path, entry)


def create_appsre_observability_ns(data_dir: str, cluster: str, environment: str) -> None:
    """Function to create the AppSre monitoring namespace"""
    ns_path = APPSRE_OBSERVABILITY_NS_PATH.format(data_dir=data_dir, cluster=cluster)
    create_file_from_template(
        ns_path, APPSRE_OBSERVABILITY_NS_TEMPLATE, cluster=cluster, environment=environment
    )


def configure_appsre_observability_ns(data_dir: str, cluster: str) -> None:
    """Function to configure the AppSre monitoring namespace in the required
    roles and saas files
    """
    entry = {
        "namespace": {
            "$ref": (
                f"/openshift/{cluster}/namespaces/"
                "app-sre-observability-per-cluster.yml"
            )
        },
        "role": "view",
    }
    role_path = APPSRE_OBSERVABILITY_NS_ROLE.format(data_dir=data_dir)
    _add_entry_to_role_access(role_path, entry)
    _add_appsre_observability_ns_to_nginx_saas(data_dir, cluster)


def _add_appsre_observability_ns_to_nginx_saas(data_dir: str, cluster: str) -> None:
    entry = {
        "namespace": {
            "$ref": (
                f"/openshift/{cluster}/namespaces/"
                "app-sre-observability-per-cluster.yml"
            )
        },
        "ref": "master",
        "parameters": {
            "ALERTMANAGER_SERVER_NAME": f"alertmanager.{cluster}.devshift.net",
            "PROMETHEUS_SERVER_NAME": f"prometheus.{cluster}.devshift.net",
        },
    }

    saas_path = NGINX_SAAS_FILE.format(data_dir=data_dir)
    _add_target_to_resource_template(saas_path, "nginx-proxy", entry)


def _get_slug_from_console_url(console_url: str) -> str:
    if not console_url:
        raise Exception(
            "Can not find consoleUrl in cluster.yml. Is the cluster"
            "provisioned successfully?"
        )
    hostname = urlparse(console_url).hostname
    return ".".join(hostname.split(".")[2:5])


def _get_cluster_name_slugs(clusters_source_path: str) -> Dict[str, str]:
    filepaths = []
    for path, _, filenames in os.walk(clusters_source_path):
        for filename in filenames:
            filepaths.append(os.path.join(path, filename))

    name_slugs = {}
    for file in filepaths:
        content = read_yaml_from_file(file)
        if content["$schema"] == "/openshift/cluster-1.yml":
            name = content["name"]
            slug = _get_slug_from_console_url(content["consoleUrl"])
            name_slugs[name] = slug
    return name_slugs


@contextmanager
def _patch_grafana_shared_resources_clusters(grafana_shared_resources_path: str) -> None:
    grafana_shared_resources = read_yaml_from_file(grafana_shared_resources_path)
    for resource in grafana_shared_resources["openshiftResources"]:
        if resource["path"] == "/observability/grafana/grafana-datasources.secret.yaml":
            yield resource["variables"]["clusters"]
            break
    write_yaml_to_file(grafana_shared_resources_path, grafana_shared_resources)


def refresh_grafana_datasources(data_dir: str) -> None:
    """Refresh grafana datasources"""
    clusters_source_path = GRAFANA_CLUSTERS_SOURCE_PATH.format(data_dir=data_dir)
    name_slugs = _get_cluster_name_slugs(clusters_source_path)
    grafana_shared_resources_path = GRAFANA_SHARED_RESOURCES_PATH.format(data_dir=data_dir)

    with _patch_grafana_shared_resources_clusters(grafana_shared_resources_path) as clusters:
        for c in clusters:
            c["slug"] = name_slugs[c["name"]]

    log.info("Grafana datasources refreshed successfully")


def configure_grafana_datasources(data_dir: str, cluster: str) -> None:
    """Configures grafana datasources"""
    _check_data_and_cluster_exists(data_dir, cluster)

    console_url = _get_cluster_yaml_attribute(data_dir, cluster, "consoleUrl")
    slug = _get_slug_from_console_url(console_url)
    grafana_shared_resources_path = GRAFANA_SHARED_RESOURCES_PATH.format(data_dir=data_dir)

    with _patch_grafana_shared_resources_clusters(grafana_shared_resources_path) as clusters:
        for c in clusters:
            if c["name"] == cluster:
                c["slug"] = slug
                break
        else:
            clusters.append({"name": cluster, "slug": slug})

    log.info("Grafana datasources for %s cluster added successfully", cluster)


def configure_customer_monitoring(
    data_dir: str, cluster: str, environment: str
) -> None:
    """Configure customer monitoring namespace"""
    _check_data_and_cluster_exists(data_dir, cluster)

    if not os.path.exists(data_dir):
        raise FileNotFoundError(f"{data_dir} does not exist")

    if not cluster_config_exists(data_dir, cluster):
        raise FileNotFoundError(
            f"Cluster configuration doesn't exist for "
            f"{cluster}, check if the cluster name was "
            f"mistyped"
        )

    create_customer_monitoring_ns(data_dir, cluster, environment)
    configure_customer_monitoring_ns(data_dir, cluster, environment)
    create_appsre_observability_ns(data_dir, cluster, environment)
    configure_appsre_observability_ns(data_dir, cluster)
    add_cluster_to_observability_role(data_dir, cluster)



def create_logging_stack_ns(
    data_dir: str, cluster: str, environment: str
) -> None:
    """Function to create the customer monitoring namespace"""
    ns_path = LOGGING_NS_PATH.format(data_dir=data_dir, cluster=cluster)
    create_file_from_template(
        ns_path, LOGGING_NS_TEMPLATE, cluster=cluster, environment=environment
    )

def create_event_router_ns(
    data_dir: str, cluster: str, environment: str
) -> None:
    """Function to create the customer monitoring namespace"""
    ns_path = EVENT_ROUTER_NS_PATH.format(data_dir=data_dir, cluster=cluster)
    create_file_from_template(
        ns_path, EVENT_ROUTER_NS_TEMPLATE, cluster=cluster, environment=environment
    )


def add_event_router_entry_to_saas(
    data_dir: str, cluster: str
) -> None:
    """Function to add customer monitoring namespace target in the
    observability saas manifest
    """

    saas_path = EVENT_ROUTER_SAAS_FILE.format(data_dir=data_dir)
    entry = {
        "namespace": {
            "$ref": f"/openshift/{cluster}/namespaces/app-sre-event-router.yaml",
        },
    }
    _add_target_to_resource_template(saas_path, "event-router", entry, True)


def configure_cluster_logging(
    data_dir: str, cluster: str, environment: str
) -> None:
    """Configure customer monitoring namespace"""
    _check_data_and_cluster_exists(data_dir, cluster)

    if not os.path.exists(data_dir):
        raise FileNotFoundError(f"{data_dir} does not exist")

    if not cluster_config_exists(data_dir, cluster):
        raise FileNotFoundError(
            f"Cluster configuration doesn't exist for "
            f"{cluster}, check if the cluster name was "
            f"mistyped"
        )

    create_logging_stack_ns(data_dir, cluster, environment)
    create_event_router_ns(data_dir, cluster, environment)
    add_event_router_entry_to_saas(data_dir, cluster)
