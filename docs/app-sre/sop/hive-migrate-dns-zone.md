# Migrate DNS zone for Hive

## Background

Following the p1.openshiftapps.com not resolvable incident (https://issues.redhat.com/browse/OHSS-7390), we are working on managing Hive DNS zones via app-interface in https://issues.redhat.com/browse/OSD-8770.

As part of this work, we need to update Hive to use a new DNS zone managed via app-interface, instead of the one that is currently being used.

## Purpose

Describe the process to switch Hive to use a new DNS zone.

## Process

1. Pre-create the destination DNS zone via app-interface: https://gitlab.cee.redhat.com/service/app-interface#manage-external-dns-zones-via-app-interface-openshiftnamespace-1yml. This will result in a Secret with credentials to manage the DNS zone.
1. Submit a MR to update the HiveConfig to use the newly created Secret.
    * Once this MR is merged, Hive controller pods will be recycled to pick up the new Secret and will start populating the destination DNS zone.
1. Update the DNS delegation to point at the newly created DNS zone.

## Impact

If a new cluster will be created after the Secret change in the HiveConfig, the DNS entry for the cluster will be created in the destination DNS zone, while DNS will still be pointing at the source DNS zone. This means that the cluster will not be reachable until DNS delegation is updated.

Assuming the update of the Secret has successfully caused the population of the destination DNS zone, this will mean that the only impact is:

"New clusters may not be reachable for an additional <time between Secret change and DNS delegation update and propogation>".

In reality, there will likely be no impact for customers.
