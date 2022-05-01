"""Generate Observability configs for a cluster."""
from io import StringIO
import os
import sys
import logging
import json
from typing import Any, Mapping, MutableMapping

from .common import cluster_config_exists
from .common import get_base_yaml
from .common import render_template_as_str
from .common import read_yaml_from_file
from .common import write_yaml_to_file
from .common import get_yaml_attribute
from .common import create_file_from_template

log = logging.getLogger(__name__)

# DNS
DNS_FILE_CONFIG_PATH = "{data_dir}/aws/app-sre/dns/devshift.net.yaml"
DNS_OBSERVABILTY_RECORDS = ["prometheus.{cluster}", "alertmanager.{cluster}"]

# CUSTOMER_MONITORING
CUSTOMER_MON_NS_TEMPLATE = \
    "openshift-customer-monitoring.CLUSTERNAME.tpl"

CUSTOMER_MON_NS_PATH = (
    "{data_dir}/services/observability/namespaces/"
    "openshift-customer-monitoring.{cluster}.yml"
)

CUSTOMER_MON_ENV_STAGE = "staging"
CUSTOMER_MON_ENV_PROD = "production"
CUSTOMER_MON_JIRA_STAGE = "app-sre-stage"
CUSTOMER_MON_JIRA_PROD = "app-sre"

# OBSERVABILITY
OBSERVABILITY_ROLE_PATH = (
    "{data_dir}/services/observability/roles/"
    "app-sre-osdv4-monitored-clusters-view.yml"
)
OBSERVABILITY_SAAS_FILE = (
    "{data_dir}/services/observability/cicd/saas/"
    "saas-observability-per-cluster.yaml"
)

# APPSRE OBSERVABILTY NS
APPSRE_OBSERVABILITY_NS_PATH = (
    "{data_dir}/openshift/{cluster}/namespaces/"
    "app-sre-observability-per-cluster.yml"
)
APPSRE_OBSERVABILITY_NS_TEMPLATE = (
    "app-sre-observability-per-cluster.tpl"
)
APPSRE_OBSERVABILITY_NS_ROLE = (
    "{data_dir}/services/observability/roles/observability-access-elevated.yml"
)
NGINX_SAAS_FILE = (
    "{data_dir}/services/observability/cicd/saas/"
    "saas-nginx-proxy.yaml"
)
ACME_SAAS_FILE = (
    "{data_dir}/services/app-sre/cicd/ci-int/"
    "saas-openshift-acme.yaml"
)

# GRAFANA
GRAFANA_DATASOURCES_PATH = (
    "{data_dir}/../resources/observability/grafana/"
    "grafana-datasources.secret.yaml"
)


def _check_data_and_cluster_exists(data_dir: str, cluster: str) -> None:
    if not os.path.exists(data_dir):
        raise FileNotFoundError(f"{data_dir} does not exist")

    if not cluster_config_exists(data_dir, cluster):
        raise FileNotFoundError(f"Cluster configuration doesn't exist for "
                                f"{cluster}, check if the cluster name was "
                                f"mistyped")


def _add_entry_to_role_access(role_path: str,
                              entry: Mapping[str, Any]) -> bool:
    """ Funtion to add a cluster/namespace entry to role permissions (access)
    """
    if "cluster" in entry:
        etype = "cluster"
    elif "namespace" in entry:
        etype = "namespace"
    else:
        raise Exception(
            "Access element to role not supported, "
            "should be cluster or namespace"
        )
    role_data = read_yaml_from_file(role_path)
    element_ref = entry[etype]["$ref"]
    for _ns in role_data["access"]:
        ref = _ns[etype]["$ref"]
        if ref == element_ref:
            log.info(
                "Ref %s already set in role %s -- skipping",
                element_ref, role_path
            )
            return False
    role_data["access"].append(entry)
    write_yaml_to_file(role_path, role_data)
    log.info(
        "Ref %s set sucessfully in %s",
        element_ref, role_path
    )
    return True


def _add_target_to_resource_template(
        saas_path: str, rt_name: str, entry: MutableMapping[str, Any],
        get_ref_from_last=False) -> None:
    saas_data = read_yaml_from_file(saas_path)
    resource_templates = saas_data["resourceTemplates"]
    ns_ref = entry["namespace"]["$ref"]
    rts = list(filter(
        lambda rt: rt["name"] == rt_name,
        resource_templates
    ))
    if len(rts) == 0:
        raise Exception(
            f"No resource template with name {rt_name} in "
            f"{saas_path} saas file"
        )
    else:
        dest_rt = rts[0]
    dest_rt_targets = dest_rt["targets"]
    for target in dest_rt_targets:
        if target["namespace"]["$ref"] == ns_ref:
            log.info(
                "Namespace %s already set in %s -- skipping",
                ns_ref,
                saas_path
            )
            return
    if get_ref_from_last:
        entry["ref"] = dest_rt_targets[-1].get("ref", "")
    dest_rt_targets.append(entry)
    write_yaml_to_file(saas_path, saas_data)
    log.info(
        "Namespace %s set sucessfully in %s",
        ns_ref,
        saas_path
    )


def _get_cluster_yaml_attribute(data_dir: str, cluster: str, attr: str) -> Any:
    path = f"{data_dir}/openshift/{cluster}/cluster.yml"
    data = get_yaml_attribute(path, attr)
    return data


def _cluster_is_private(data_dir: str, cluster: str) -> bool:
    spec = _get_cluster_yaml_attribute(data_dir, cluster, "spec")
    return spec.get("private", False)


def _cluster_console_url(data_dir: str, cluster) -> str:
    # https://console-openshift-console.apps.app-sre-prod-01.i7w5.p1.openshiftapps.com
    data = _get_cluster_yaml_attribute(data_dir, cluster, "consoleUrl")
    data = data.removeprefix("https://console-openshift-console.")
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
                "_target_cluster": {
                    "$ref": f"/openshift/{cluster}/cluster.yml"
                }
            }
            new_records.append(record)

    if len(new_records) > 1:
        data["records"].extend(new_records)
        write_yaml_to_file(dns_file, data)


def create_customer_monitoring_ns(
        data_dir: str, cluster: str, environment: str) -> None:
    """ Function to create the customer monitoring namespace
    """
    ns_path = CUSTOMER_MON_NS_PATH.format(data_dir=data_dir,
                                          cluster=cluster)
    phase = {
        CUSTOMER_MON_ENV_PROD: CUSTOMER_MON_JIRA_PROD,
        CUSTOMER_MON_ENV_STAGE: CUSTOMER_MON_JIRA_STAGE
    }
    create_file_from_template(ns_path, CUSTOMER_MON_NS_TEMPLATE,
                              cluster=cluster, phase=phase[environment])


def configure_customer_monitoring_ns(
        data_dir: str, cluster: str, environment: str) -> None:
    """ Function that does the required configuration for the
        customer monitoring namespace
    """
    _configure_cluster_for_customer_monitoring(data_dir, cluster)
    _add_customer_monitoring_ns_to_observability_saas(data_dir, cluster,
                                                      environment)


def _configure_cluster_for_customer_monitoring(
        data_dir: str, cluster: str) -> None:
    """ Function to configure cluster.yml manifest to enable customer
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
        data_dir: str, cluster: str, environment: str) -> None:
    """ Function to add customer monitoring namespace target in the
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
            "EXTERNAL_URL": f"https://prometheus.{cluster}.devshift.net"
        }
    }
    am_entry = {
        "namespace": {
            "$ref": ns_ref,
        },
        "parameters": {
            "ENVIRONMENT": f"{environment}",
            "EXTERNAL_URL": f"https://alertmanager.{cluster}.devshift.net"
        }

    }
    _add_target_to_resource_template(saas_path, "prometheus", prom_entry, True)
    _add_target_to_resource_template(saas_path, "alertmanager", am_entry, True)


def add_cluster_to_observability_role(data_dir: str, cluster: str) -> None:
    """ Function to add the cluster reference to the observability role
    """
    role_path = OBSERVABILITY_ROLE_PATH.format(data_dir=data_dir)
    entry = {
        "cluster": {
            "$ref": f"/openshift/{cluster}/cluster.yml"
        },
        "clusterRole": "cluster-monitoring-view"
    }
    _add_entry_to_role_access(role_path, entry)


def create_appsre_observability_ns(data_dir: str, cluster: str) -> None:
    """ Function to create the AppSre monitoring namespace
    """
    ns_path = APPSRE_OBSERVABILITY_NS_PATH.format(
        data_dir=data_dir,
        cluster=cluster
    )
    create_file_from_template(ns_path, APPSRE_OBSERVABILITY_NS_TEMPLATE,
                              cluster=cluster)


def configure_appsre_observability_ns(data_dir: str, cluster: str) -> None:
    """ Function to configure the AppSre monitoring namespace in the required
        roles and saas files
    """
    entry = {
        "namespace": {
            "$ref": (
                f"/openshift/{cluster}/namespaces/"
                "app-sre-observability-per-cluster.yml"
            )
        },
        "role": "view"
    }
    role_path = APPSRE_OBSERVABILITY_NS_ROLE.format(data_dir=data_dir)
    _add_entry_to_role_access(role_path, entry)
    _add_appsre_observability_ns_to_nginx_saas(data_dir, cluster)
    if not _cluster_is_private(data_dir, cluster):
        _add_appsre_observability_ns_to_acme_saas(data_dir, cluster)


def _add_appsre_observability_ns_to_nginx_saas(
        data_dir: str, cluster: str) -> None:
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
            "PROMETHEUS_SERVER_NAME": f"prometheus.{cluster}.devshift.net"
        }
    }

    saas_path = NGINX_SAAS_FILE.format(data_dir=data_dir)
    _add_target_to_resource_template(saas_path, "nginx-proxy", entry)


def _add_appsre_observability_ns_to_acme_saas(
        data_dir: str, cluster: str) -> None:
    entry = {
        "namespace": {
            "$ref": (
                f"/openshift/{cluster}/namespaces/"
                "app-sre-observability-per-cluster.yml"
            )
        },
        "ref": "master"
    }
    saas_path = ACME_SAAS_FILE.format(data_dir=data_dir)
    _add_target_to_resource_template(saas_path, "openshift-acme", entry)


def _get_grafana_json_datasources(file_path: str):
    # Remove base64 non_yaml compliant lines
    content = ""
    with open(file_path, mode="r", encoding="utf8") as file:
        for line in file.readlines():
            if "b64encode" not in line:
                content = content + line

    yaml_obj = get_base_yaml()
    yaml_obj.explicit_start = False
    yaml_obj.preserve_quotes = True
    yaml_obj.width = 65535

    # Load the data
    data = yaml_obj.load(content)
    datasources_yaml = data["data"]["datasources.yaml"]

    # Parse the data as JSON
    stream = StringIO()
    yaml_obj.dump(datasources_yaml, stream)
    json_data = json.loads(stream.getvalue())
    return json_data


def configure_grafana_datasources(data_dir: str, cluster: str) -> None:
    """ Configures grafana datasources"""
    _check_data_and_cluster_exists(data_dir, cluster)

    file_path = GRAFANA_DATASOURCES_PATH.format(data_dir=data_dir)

    # Get the json data
    json_data = _get_grafana_json_datasources(file_path)

    name1 = f"{cluster}-prometheus"
    name2 = f"{cluster}-cluster-prometheus"

    existent_datasources = [d["name"] for d in json_data["datasources"]]
    exists = False
    for name in [name1, name2]:
        if name in existent_datasources:
            exists = True
            log.error(
                "Datasource %s already exists in grafana-datasources-secret",
                name
            )
    if exists:
        return

    # Add data new datasources
    tls_skip_verify = "false"
    if _cluster_is_private(data_dir, cluster):
        tls_skip_verify = "true"

    console_url = _cluster_console_url(data_dir, cluster)
    if not console_url:
        raise Exception(
            "Can not find consoleUrl in cluster.yml. Is the cluster"
            "provisioned sucessfully ?"
        )

    data1 = {
        "cluster": cluster,
        "name": name1,
        "tlsSkipVerify": tls_skip_verify,
        "url": f"https://prometheus.{cluster}.devshift.net",
    }
    data2 = {
        "cluster": cluster,
        "name": name2,
        "tlsSkipVerify": tls_skip_verify,
        "url": f"https://prometheus-k8s-openshift-monitoring.{console_url}",
    }

    tpl1 = render_template_as_str("grafana-datasource.tpl", **data1)
    tpl2 = render_template_as_str("grafana-datasource.tpl", **data2)
    json1 = json.loads(tpl1)
    json2 = json.loads(tpl2)
    json_data["datasources"].extend([json1, json2])

    # Format the output
    txtdata = json.dumps(json_data, indent=4)

    # This is ugly and I feel bad for it, but I cannot find another way to
    # add spaces at the beggining of the json dumped objects
    output = ""
    for line in txtdata.splitlines():
        output = f"{output}    {line}\n"

    # Render a new template with the requried format
    tpl = render_template_as_str(
        "grafana-datasources-secret.tpl",
        datasources=output
    )

    with open(file_path, mode="w", encoding="utf-8") as file:
        file.write(tpl)

    log.info("Grafana datasources for %s cluster added succesfully", cluster)
    sys.exit(1)


def configure_customer_monitoring(data_dir: str,
                                  cluster: str,
                                  environment: str) -> None:
    """ Configure customer monitoring namespace
    """
    _check_data_and_cluster_exists(data_dir, cluster)

    if not os.path.exists(data_dir):
        raise FileNotFoundError(f"{data_dir} does not exist")

    if not cluster_config_exists(data_dir, cluster):
        raise FileNotFoundError(f"Cluster configuration doesn't exist for "
                                f"{cluster}, check if the cluster name was "
                                f"mistyped")

    create_customer_monitoring_ns(data_dir, cluster, environment)
    configure_customer_monitoring_ns(data_dir, cluster, environment)
    create_appsre_observability_ns(data_dir, cluster)
    configure_appsre_observability_ns(data_dir, cluster)
    add_cluster_to_observability_role(data_dir, cluster)
