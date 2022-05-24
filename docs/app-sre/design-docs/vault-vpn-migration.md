# Design doc: Vault migration inside Red HatVPN

- [Design doc: Vault migration inside Red HatVPN](#design-doc-vault-vpn-migration)
  - [Author/date](#authordate)
  - [Tracking JIRA](#tracking-jira)
  - [Problem Statement](#problem-statement)
  - [Goals](#goals)
  - [Non-objectives](#non-objectives)
  - [Proposal](#proposal)
  - [Alternatives considered](#alternatives-considered)
  - [Milestones](#milestones)
    - [Rollback](#rollback)
  - [Additional information](#additional-information)


## Author/date
`Andreu Gallofré` / `April 2022`


## Tracking JIRA
[APPSRE-4791](https://issues.redhat.com/browse/APPSRE-4791)


## Problem Statement

For security concerns, Vault instances must not be accessible from internet, and should be accessed only under Red Hat internal VPN

## Goals

The goal is to deploy vault in the internal clusters `appsrep05ue1` and `appsres03ue1` to move the services inside the VPN and secure the environment that now is exposed to internet.

Current integrations and CI accesses must keep working with the new internal vaults and all the data must remain.

## Non-objectives

N/A

## Proposal

The idea for this project is to deploy new Vault instances in the internal clusters following the instructions of the [Vault failover to other clusters](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/vault.md#vault-failover-to-another-cluster)

We need to ensure that peerings between relevant clusters are in place before the migration, tracking ticket for this is [APPSRE-4792](https://issues.redhat.com/browse/APPSRE-4792)

## Alternatives considered

N/A

## Milestones

Pre-requisite actions:

* Get access to `vault-locker` repository to access deploy files [APPSRE-4797](https://issues.redhat.com/browse/APPSRE-4797)
    * Check access to all relevant files

* Check if vault can be deployed in a master-master set-up with both instances working at the same time to test the new setup without affecting the current one.

* Setup peerings between affected clusters to ensure correct vault access [APPSRE-4792](https://issues.redhat.com/browse/APPSRE-4792)

* Get Digicert cerficate to use instead of Openshift-ACME that does not work inside the VPN - RITM1177754 & RITM1177748 

Migration steps:

* Deploy new vault instance in `appsres03ue1` cluster
* Change certificates to use the new digicert certificate
* Validate read/write operations from Vault stage instance
* Test stage integrations run with the new Vault instance

* Deploy new vault instance in `appsrep05ue1` cluster
* Change certificates to use the new digicert certificate
* Validate read/write operations from Vault prod instance
* Modify integrations to run with the new Vault instance

Post-migration cleanup:

* Remove current vault instances in `app-sre-prod-01` and `app-sre-stage-01`

### Rollback

Switch DNS back to external vault instances to recover the service. This is currently managed via devshift.net zone on app-interface.

## Additional information

TBD
