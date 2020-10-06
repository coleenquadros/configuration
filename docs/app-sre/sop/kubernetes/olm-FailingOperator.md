# FailingOperator

## Severity: High

## Impact

The operator in question is not in running condition, the dependant application may also be degraded as a result

## Summary

A CSV is the metadata that accompanies your Operator container image. It can be used to populate user interfaces with info like your logo/description/version and it is also a source of technical information needed to run the Operator, like the RBAC rules it requires and which Custom Resources it manages or depends on.

A full description of the Operator Framework architecture is available here: https://github.com/operator-framework/operator-lifecycle-manager/blob/master/doc/design/architecture.md#what-is-a-clusterserviceversion

An operator CSV is in `Failed` phase upon failed execution of the Install Strategy, or an installed component disappears

## Access required

Console / command line access to the cluster where the operator is running

## Steps

1. Check the events in `openshift-operator-lifecycle-manager` namespace
1. Check the pod logs for the `olm-operator` and `catalog-operator` pods to identify any issues with the catalog
1. Check the `csv` for the specific operator. The `status.reason` field should give you more information on why the operator is stuck in Pending state

### CoreOS slack

`#forum-operator-framework` for the operator framework development team
`#sre-operators` for reporting issues specific to OSD/SRE operators. These operators also have their own slack owner groups, and you can always involve @sre-primary and let them escalate issues
