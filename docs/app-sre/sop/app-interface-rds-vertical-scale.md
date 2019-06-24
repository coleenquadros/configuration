# Vertical scaling of RDS instances via app-interface

## Background

From time to time we will need to vertically scale an RDS instance.

A vertical scale is the approach to increase the capacity of a single instance, for example by adding more processing power or storage.

## Purpose

This document explains how to vertically scale an RDS instance managed through app-interface.

## Process

1. Find the RDS instance you want to scale in the appropriate namespace file.
    * Example - RDS instance defition: [uhc-production/cluster-service](/data/services/uhc/namespaces/uhc-production.yml#L56)
2. Add an `overrides` section if one does not exist. Each attribute in this section will override the defaults in the file specified in the `defaults` section.
    * Example - defaults file: [app-sre/production/rds defaults](/resources/terraform/resources/app-sre/production/rds-1.yml)
3. To vertically scale, you can change one of the following attributes under `overrides`:
    * `instance_class` - select a supported instance class.
    > Note: instance class selection is limited in [app-interface schema](/schemas/openshift/namespace-1.yml#L193).
    * `allocated_storage` - increase allocated storage for the instance.
4. Create a Merge Request to app-interface with these changes.
5. Verify in the `terraform-resources` integration output that the change that is about to happen is of type `update` and not `replace`.

## References

* [AWS Database blog - Scaling Your Amazon RDS Instance Vertically and Horizontally](https://aws.amazon.com/blogs/database/scaling-your-amazon-rds-instance-vertically-and-horizontally/)
* [AWS Documentation - Choosing the DB Instance Class - Supported DB Engines for All Available DB Instance Classes](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.Support)
