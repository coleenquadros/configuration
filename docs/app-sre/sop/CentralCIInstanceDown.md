# Central CI Instance Down alert runbook

## Severity: Critical

## Impact

- Depending on the failing instance, it may mean that we are unable to deliver the services we run.

## Summary

To monitor internal resources such as https://ci.int.devshift.net, we use a Prometheus instance installed on OpenStack: http://prometheus.centralci.devshift.net:9090/

The [InstanceDown](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/host_vars/prometheus.centralci.devshift.net) monitores various [instances](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/6215bc233827e43bda7974cadfef0eeb6beba106/ansible/hosts/hosts.cfg#L11-66) 

## Access required

- [OpenStack Console](/docs/app-sre/sop/openstack-ci-int.md)
- [SSH access to instances](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/ansible#ssh-setup)

## Steps

1. Check outage-list for any outages related to PSI Openstack Cloud D
  * If the time fits an outage (planned or not), the alert can be silenced (we should create silences in advance for planned outages)
1. Check the OpenStack console to see if the instance happens to be down
1. SSH to the instance and dig in

## Escalations

- [PnT DevOps](/docs/app-sre/AAA.md#pnt-devops)
