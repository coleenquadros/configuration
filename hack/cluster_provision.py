#!/usr/bin/env python3
"""Basic CLI for cluster privisioning utlity commands.
"""
import logging
import sys
import click

import cluster_provision.cso as cso
import cluster_provision.dvo as dvo
import cluster_provision.olm as olm
import cluster_provision.observability as observability


def init_logging() -> None:
    """Intializes the logging system"""

    formatter = logging.Formatter("%(levelname)s - %(message)s")
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger = logging.getLogger()
    logger.addHandler(console_handler)
    logger.setLevel(logging.INFO)


@click.group()
@click.option(
    "--datadir",
    default="data",
    show_default=True,
    help="Path of app-interface data directory",
)
@click.pass_context
def cli(ctx, datadir):
    """Base CLI with helper commands for OSD cluster onboarding"""
    ctx.ensure_object(dict)
    ctx.obj["datadir"] = datadir
    init_logging()


@cli.command()
@click.argument("cluster")
@click.pass_context
def create_olm_ns(ctx, cluster):
    """Generates Operator lifecycle manager manifest"""
    olm.create_namespace(ctx.obj["datadir"], cluster)


@cli.command()
@click.argument("cluster")
@click.pass_context
def create_dvo_cluster_config(ctx, cluster: str) -> None:
    """Generates Deployment Validation Operator (DVO) configs for a cluster"""
    dvo.main(ctx.obj["datadir"], cluster)


@cli.command()
@click.argument("cluster")
@click.pass_context
def create_cso_cluster_config(ctx, cluster: str) -> None:
    """Generates Container Security Operator (CSO) configs for a cluster"""
    cso.main(ctx.obj["datadir"], cluster)


@cli.command()
@click.argument("cluster")
@click.pass_context
def create_obs_dns_records(ctx, cluster: str) -> None:
    """Generates Observability DNS records"""
    observability.create_dns_records(ctx.obj["datadir"], cluster)


@cli.command()
@click.argument("cluster")
@click.argument("environment")
@click.pass_context
def create_obs_customer_monitoring(ctx, cluster: str, environment: str) -> None:
    """Generates APP-SRE observability config for a cluster"""
    observability.configure_customer_monitoring(
        ctx.obj["datadir"], cluster, environment
    )


@cli.command()
@click.argument("cluster")
@click.pass_context
def create_obs_grafana_datasources(ctx, cluster: str) -> None:
    """Generates APP-SRE observability config for a cluster"""
    observability.configure_grafana_datasources(ctx.obj["datadir"], cluster)


if __name__ == "__main__":
    # pylint: disable=no-value-for-parameter
    cli()
