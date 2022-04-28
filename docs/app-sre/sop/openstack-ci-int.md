# OBSOLETE!!

This document is left for historical purposes only. It will be removed
soon.

# Provisioning VMs in OpenStack

The OpenStack dashboard is here:
https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project/

## Log in

To login, use: `domain: redhat.com` and your kerberos id and password.

Note: access is managed via this group:
https://rover.redhat.com/groups/group/app-sre

## Dashboard overview

In the top right you will see a `Project` dropdown. You should select the `ci-int-jenkins` project.

## Download and install `clouds.yaml`

The `clouds.yaml` file contains the tokens to access the project. It will be used by `ansible` and some CLI tools.

This file can be downloaded from the dashboard under the top left `Project -> API Access -> Download OpenStack clouds.yaml File`. It must be installed to `~/.config/openstack/clouds.yaml`.

## `openstack` CLI tool

The `openstack` CLI tool can be installed with `pip install python-openstackclient`.

Alternatively, you can install it in CentOS 7 like this:

```shell
$ yum install centos-release-openstack-rocky
$ yum install python2-openstackclient
```

Or, in recent Fedora with `dnf -y install python3-openstackclient`.

This tool requires that you `export OS_CLOUD=openstack` first. Then you can use like this:

```shell
$ openstack server list
Password:
+--------------------------------------+--------------------------+--------+------------------------------------------------------------------+----------------------------------------------+-----------+
| ID                                   | Name                     | Status | Networks                                                         | Image                                        | Flavor    |
+--------------------------------------+--------------------------+--------+------------------------------------------------------------------+----------------------------------------------+-----------+
| c57922b3-9a30-4a99-af85-9b92369407eb | jenkins-slave-02-uhc     | ACTIVE | provider_net_cci_1=10.0.132.76, 2620:52:0:84:f816:3eff:fe63:9a02 | CentOS-7-x86_64-GenericCloud-released-latest | m1.large  |
| 4f43ba0a-fba2-46c0-b150-2c9b57c07766 | jenkins-slave-01-app-sre | ACTIVE | provider_net_cci_1=10.0.132.92, 2620:52:0:84:f816:3eff:fe90:7075 | CentOS-7-x86_64-GenericCloud-released-latest | m1.medium |
+--------------------------------------+--------------------------+--------+------------------------------------------------------------------+----------------------------------------------+-----------+
```

Note: the command will prompt you for your Kerberos password. It also takes a long time (~2 mins).

You can add your kerberos password in clear text in the `clouds.yaml` file like this:

```
clouds:
  openstack:
    auth:
      auth_url: https://rhos-d.infra.prod.upshift.rdu2.redhat.com:13000/v3
      username: "<kerberos_id>"
      password: "<kerberos_password>"
      ...
```
Or alternatively you can download this file from the dashboard under the top left `Project -> API Access -> Download OpenStack RC File (Identity API v3)` to ~/~/ci-int-jenkins-openrc.sh
And source it like:

```shell
source ~/ci-int-jenkins-openrc.sh
```
This will alsk you for password and not store it in plaintext, also it allos you resize VMs without adding too many commandline parameters.

## Key Pairs

You need to create a Key Pair in order to use it when you provision VMs. Go to the [Compute -> Key Pairs](https://rhos-d.infra.prod.upshift.rdu2.redhat.com/dashboard/project/key_pairs) page, and select `Import Public Key`.

If you are going to use `ansible` to provision VMs, remember to use the name of the key pair you have created in the `key_name` parameter.

If you want others to be able to access the VM, run the `baseline` ansible role on the VM so it provisions all the ssh keys.

## Provisioning a VM with Ansible

You have an example on how to provision a VM with Ansible [here](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/openstack-jenkins-slaves.yml)

```shell
$ ansible-playbook playbooks/openstack-jenkins-slaves.yml
```

Note that this command runs ssh against your `localhost` so your own ssh to localhost must work.

It uses the [os_server](https://docs.ansible.com/ansible/latest/modules/os_server_module.html) module to create the hosts.

Once the playbook is executed, you can retrieve the IP via the web UI or via the CLI. You will be able to ssh to it next. If you are using a `CentOS-7-x86_64-GenericCloud` image, you will need to ssh to the `centos` account:

```shell
$ ansible-playbook playbooks/openstack-jenkins-slaves.yml -u centos
```

## Resize VM

For resizing VM you need source ~/ci-int-jenkins-openrc.sh because of using `nova` command.
Get list of available flavours:
```shell
openstack flavor list --sort-column Name
```
Get list of running VMs:
```shell
openstack server list
```
Give command to resize where ID is for new flavor:
```shell
nova resize skryzhni-test 77b8cf27-be16-40d9-95b1-81db4522be1e --poll
```
Then check if resize completed OK:
```shell
openstack server list
```
You should have something similar to:
```
| 713fd3d4-4529-4ea1-bc44-0933c9a60194 | skryzhni-test                      | VERIFY_RESIZE | provider_ne3a5 | | ci.m1.medium.ephemeral |
```
If resize is virified successfully then you need to confirm it:
```shell
openstack server resize --confirm 713fd3d4-4529-4ea1-bc44-0933c9a60194
```
Or cancel resize if it not successful you can revert resize:
```shell
openstack server resize --revert 67bc9a9a-5928-47c4-852c-3631fef2a7e8
```

It good to check again if server has `ACTIVE` state:
```shell
openstack server list
```

## Increase quota

Our OpenStack quotas are defined in:
* https://gitlab.cee.redhat.com/psi/psi-rhos/blob/master/overcloud-data/rhos-d/overcloud_projects.yaml#L620 (search for ci-int-jenkins)
* https://gitlab.cee.redhat.com/psi/psi-rhos/blob/master/overcloud-data/rhos-e/overcloud_projects.yaml#L386 (search for ci-int-jenkins)

Available tiers are defined in:
* https://docs.engineering.redhat.com/display/HSSP/PSI+Quota+Details

To increase quota, create a ticket such as [this one](https://redhat.service-now.com/surl.do?n=PNT0812455).
