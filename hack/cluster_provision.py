#!/usr/bin/env python3
"""Basic CLI for cluster privisioning utlity commands.
"""
import logging
import sys
import click

import cluster_provision.olm as olm


def init_logging() -> None:
    """ Intializes the logging system"""

    formatter = logging.Formatter('%(levelname)s - %(message)s')
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    logger = logging.getLogger()
    logger.addHandler(console_handler)
    logger.setLevel(logging.INFO)


@click.group()
@click.option('--datadir',
              default="../data",
              show_default=True,
              help='Path of app-interface data directory')
@click.pass_context
def cli(ctx, datadir):
    """ Base CLI with helper commands for OSD cluster onboarding """
    ctx.ensure_object(dict)
    ctx.obj["datadir"] = datadir
    init_logging()


@cli.command()
@click.argument("cluster")
@click.pass_context
def create_olm_ns(ctx, cluster):
    """ Generates Operator lifecycle manager manifest"""
    olm.create_namespace(ctx.obj["datadir"], cluster)


if __name__ == "__main__":
    # pylint: disable=no-value-for-parameter
    cli()
