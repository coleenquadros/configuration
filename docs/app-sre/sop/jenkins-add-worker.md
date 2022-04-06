[TOC]

# Prework
  - Fork the infra repo from [here](https://gitlab.cee.redhat.com/app-sre/infra)
  - If we need a RHEL worker node, perform the following to make rhel gold images available in the AWS account.
    - Add the aws account against the employee subscription to make sure we get the rhel gold images. \
      This can be done at https://access.redhat.com/management/cloud#cloud_accounts_AWS.

# In the Infra repo make add/update configuration files 

### Update and add the configuration needed for aws ec2 resources using terraform

  - Add the required aws ec2 resources in the terraform file for
    [ci-ext](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/ci.ext/ci.ext-nodes.tf)
    or [ci-int](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/terraform/app-sre/app-sre-ci/ci-int-nodes.tf)

### Create the configuration needed for setting up jenkins and additional tasks via ansible playbooks

  - Create a host vars file like [this](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/host_vars/ci-ext-jenkins-worker-08-codeready-analytics)
  - Add the new host and group into the host in appropriate places in the [hosts.cfg](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/hosts.cfg)
  - Add the new task to the main playbook for jenkins worker for 
    [ci-ext
    node-ci-ext-jenkins-worker.yml](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/node-ci-ext-jenkins-worker.yml)
    or [ci-int node-ci-int](https://gitlab.cee.redhat.com/app-sre/infra/blob/master/ansible/playbooks/node-ci-int-aws-jenkins-worker.yml).

# Submit an MR with the above changes to the Infra repository.

# Execute terraform for creating AWS EC2 resources from your local machine after the MR is merged.
  - Setup and Run terraform resources to build the ec2 resources from the directory infra/terraform/app-sre/ci.ext/. \
      Refer to following doc on setting up and [running terraform resources](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/terraform-quickstart.md)

### If the node being built is RHEL then perform the following additional tasks.
  - Login to the host as ec2-user and subscribe RHSM as root. \
      subscription-manager register \
      The above will prompt for RHSM username/password where we have been using our personal subscription info which uses employee subscription for RHEL. \
      This possibly needs to be changed to use some generic account.
  - Enable optional repos if needed. This was needed for python36-devel. \
      yum-config-manager --enable rhel-7-server-optional-rpms

# Execute ansible playbooks for configuring the jenkins worker node
  - In the Local host_vars file for the newly built host [example](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/hosts/host_vars/ci-ext-jenkins-worker-08-codeready-analytics), change app-sre-bot to your own login. This is resolve possibly a circular dependancy. (Need to revert back to orignal after the playbook is run)
  - Run ansible playbook in debug mode to configure the new host for jenkins. \
    example: \
    ```
    ansible-playbook playbooks/node-ci-ext-jenkins-worker.yml --limit ci-ext-jenkins-worker-08-codeready-analytics -u ec2-user -CD
    ```
  - Run ansible playbook after confirming the changes in debug mode \
    example: \
    ```
    ansible-playbook playbooks/node-ci-ext-jenkins-worker.yml --limit ci-ext-jenkins-worker-08-codeready-analytics -u ec2-user
    ```

# Add the new node in the controller ci.ext.devshift.net
  - login to the controller (ci.int or ci.ext)
  - Click on 'Manage Jenkins' on the left nav
  - In System Configuration section click on 'Manage Nodes and Clouds'
  - In the Left Nav, click on 'New Node'
  - Select Add the Node name same as what we used in our ansible hosts and select 'Copy Existing Node' and choose any of the existing node to copy from.  
  - Finally in the node config window replace the IP of the Host to the newly build host and click save.

# Verify the node is added successfully in the Nodes section.

#### Reference MR for adding ci-ext-jenkins-worker-08-codeready-analytics [here](https://gitlab.cee.redhat.com/app-sre/infra/-/merge_requests/161)


