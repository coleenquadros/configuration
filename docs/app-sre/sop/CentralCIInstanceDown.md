# Central CI Instance(ci.ext and ci.int) Down alert runbook

## Severity: Critical

## Impact

- Depending on the failing instance, it may mean that we are unable to deliver the services we run.

## Summary

To monitor internal resources such as https://ci.int.devshift.net, we use a Prometheus instance appsrep05u1: https://prometheus.appsrep05ue1.devshift.net/

The [InstanceDown](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/host_vars/prometheus.centralci.devshift.net) monitores various [instances](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/6215bc233827e43bda7974cadfef0eeb6beba106/ansible/hosts/hosts.cfg#L11-66) 

## Access required

- [SSH access to instances](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/ansible#ssh-setup)
- AWS console access for app-sre account

## Steps 

1. Check AWS console instance monitoring for relevant metrics.
1. SSH to the instance.
    1. Check if node_exporter service is running or not `systemctl status node_exporter`.
    1. Do any additional digging as required.
## Escalations

- [PnT DevOps](/docs/app-sre/AAA.md#pnt-devops)
