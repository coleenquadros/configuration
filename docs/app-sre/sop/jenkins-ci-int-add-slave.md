- [Add a slave node to ci.int jenkins](#add-a-slave-node-to-ciint-jenkins)
	- [Prepare the environment](#prepare-the-environment)
		- [Configure OpenStack communication](#configure-openstack-communication)
		- [Configurating ansible](#configurating-ansible)
	- [Provision a new node in OpenStack](#provision-a-new-node-in-openstack)
	- [Create/Update jenkins playbooks](#createupdate-jenkins-playbooks)
		- [Adding a new host_vars file](#adding-a-new-host_vars-file)
		- [Updating the hosts.cfg](#updating-the-hostscfg)
		- [Updating the openstack-jenkins-slaves.yml playbook](#updating-the-openstack-jenkins-slavespy-playbook)
	- [Run the baseline playbook](#run-the-baseline-playbook)
	- [Remove temporary changes](#remove-temporary-changes)
	- [Run the jenkins slave playbook](#run-the-jenkins-slave-playbook)
	- [Add the slave to the jenkins master](#add-the-slave-to-the-jenkins-master)
	- [Commit changes](#commit-changes)

# Add a slave node to ci.int jenkins

Adding a new slave node to ci.int involves:

1. Prepare the environment
1. Creating a new VM in Openstack
1. Adding the created VM to jenkins playbooks
1. Adding users via the `baseline` playbook
1. Removing the temporary changes needed to run the `baseline` playbook
1. Running the playbook to configure the new VM
1. Adding the new slave node to the jenkins master

## Prepare the environment

In order for the tooling to work, the user running the commands needs their environment to be setup to talk to OpenStack, vault, and to be able to run ansible.  The ansible playbooks have been run with ansible version 2.9.x and 2.10.x.  It's possible the playbooks will run on other ansible versions though.

### Configure OpenStack communication

To configure the system to talk to OpenStack, follow the guidelines [here](./openstack-ci-int.md#download-and-install-cloudsyaml) to setup to talk to openstack, and make sure to add your auth information to the clouds.yaml and mentioned [here](./openstack-ci-int.md#openstack-cli-tool).

### Configurating ansible

In order for the ansible playbooks to run successfully a number of environment variables will need to be set:

- To talk to OpenStack, `export OS_CLOUD=openstack`
- To talk to vault, set `VAULT_ROLE_ID`, `VAULT_SECRET_ID`, and `VAULT_ADDR`

The values for the vault environment variables can be found in [vault](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/ansible-reader-role-creds).  The `env` key contains all three values as you would need to export them for the environment.

*NOTE*: The environment variables may also be able to be set via a [script](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/vars.sh) in the infra repo.  That script requires a vault github token set via an environment variable in order to run.

Additionally, the environment will need to have the python `hvac` module installed for the playbooks to talk to vault.  This can be achieved by executing `pip install hvac`.

## Provision a new node in OpenStack

Provisioning a new node in OpenStack can be done with ansible and the process to do it is outlined [here](./openstack-ci-int.md).

Don't worry about running the `baseline` playbook yet.  There is no need to do anymore more from that SOP once a VM has successfully been provisioned via the `Provisioning a VM with Ansible` step.

## Create/Update jenkins playbooks

Now that an OpenStack VM has been provisioned, the jenkins playbooks will need to be updated so it can be configured.  This consists of:

- Adding a new host_vars file
- Updating the hosts.cfg
- Updating the `openstack-jenkins-slaves.yml` playbook

### Adding a new host_vars file

A host_vars file defines variables for the new slave.  Each slave has its own file located in the infra repo [here](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/ansible/hosts/host_vars).  At a minimum this file needs to contain:

```shell
ansible_host: centos@<IP address of VM>
```

Since the `baseline` playbook hasn't been run yet the centos user is the only one that can ssh into the VM, that that is why `centos@` is prepended to the IP.  Once the `baseline` playbook has been run and all the users added, the `centos@` should be removed from this file.

### Updating the hosts.cfg

The [hosts.cfg](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/hosts.cfg) contains a list of all the jenkins slaves and what profiles should be applied to them.  Find the `[ci-int-jenkins-slave]` section and add the hostname for the new slave here.  It should be in the format `ci-int-jenkins-slave-*`, where `*` is replaced with the usual convention of a number and intended workload (ie `ci-int-jenkins-slave-01-app-sre`).

If this slave will have additional needs beyond the base template then look for an additional section header.  For example, any slaves listed under the `[ci-int-jenkins-slave-rhel8]` section will be given added configuration as a rhel8 machine.  If this slave needs a new set of configuration, then create a new section header and add the slave node under it.  This will require adding all the ansible tooling to implement the new template.

### Updating the openstack-jenkins-slaves.yml playbook

The [openstack-jenkins-slaves.yml](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/openstack-jenkins-slaves.yml) contains a list of all the jenkins slaves that ansible should configure.  Copy a stanza from an existing node and modify it to meet the needs of the new slave node.  A stanza looks like:

```shell
  - name: launch jenkins-slave-17-app-interface
    os_server:
      cloud: openstack
      state: present
      name: jenkins-slave-17-app-interface
      image: CentOS-7-x86_64-GenericCloud-released-latest
      key_name: sd-app-sre
      flavor: m1.xlarge
      security_groups: default
      network: provider_net_cci_1
```

## Run the baseline playbook

Once the setup is done and all the ansible modifications are complete it is time to run the `baseline` playbook to add all the users to the new slave node.  From the [ansible](https://gitlab.cee.redhat.com/app-sre/infra/-/tree/master/ansible) directory in the infra repo, run:

```shell
ansible-playbook playbooks/node-all-baseline.yml -D -l <node_name>
```

*NOTE*: The `-l` limits the run to just the new node.  This will make it run much faster and avoid changing anything on the other slaves.

Once this completes successfully, all app-sre users will be able to ssh into the new slave.

## Remove temporary changes

Since the `baseline` playbook has been run there is no need to use the `centos` user to access the new slave anymore.  Edit the file created in this [step](#adding-a-new-host_vars-file) and remove the `centos@` from the `ansible_host` entry.

## Run the jenkins slave playbook

The last playbook to run will configure the node will all modifications needed to fit the roles defined in ansible.  The run jenkins slave playbook with:

```shell
ansible-playbook playbooks/node-ci-int-jenkins-slave.yml -D -l <node_name>
```

*NOTE*: The `-l` limits the run to just the new node.  This will make it run much faster and avoid changing anything on the other slaves.

Once this completes successfully all that is left is to manually add the node to jenkins....

## Add the slave to the jenkins master

Adding the new slave to the master is a manually process.  Log into the ci.int [master](https://ci.int.devshift.net/) node and in the upper left corner click on the little down arrow next to `Dashboard`.  Go to `Manage Jenkins->Manage Nodes and Clouds`.  On the left will be a `New Node` item with a plus (+) sign next to it.  Click on that to add a new node to the slave.

It will ask for a name, so provide one using the existing naming convention.

If this is going to be another node to run existing workloads then select `Copy Existing Node` and enter the name of the node from which to copy configuration.

If this is going to run different workoads or an existing slave can't be used to copy, then select `Permanent Agent`.  On the slave configuration screen, set the following values:

- Number of executors: 3
- Remote root directory: /var/lib/jenkins
- Labels: `<labels>`
- Usage: Only build jobs with label expressions matching this node
- Launch Method: Launch agents via SSH
  - Host: `<IP of node>`
  - Credentials: jenkins
  - Host Key Verification Strategy: Manually trusted key Verification Strategy
- Availability: Keep this agent online as much as possible

## Commit changes

Once everything done, remember to commit all the changes to the [infra](https://gitlab.cee.redhat.com/app-sre/infra) repo.
