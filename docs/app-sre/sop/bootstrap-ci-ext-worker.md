# Bootstrap a new ci.ext jenkins worker

## Process

1. Create a merge request to housekeeping adding terraform configs and ansible configs for the new slave. Example: https://gitlab.cee.redhat.com/dtsd/housekeeping/merge_requests/522.
2. Apply terraform configs - a new EC2 instance will be created:

```shell
terraform init
terraform plan
terraform apply
```

3. Get the private key of the ec2 instance base user and ssh-add it. the key can be found here: https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-ext/ec2-user-ssh

4. Apply ansible playbooks:

```shell
# apply the baseline role using the centos user - dry run
ansible-playbook playbooks/node-ci-ext-jenkins-worker.yml --limit <worker_name> -u centos -t baseline -CD
# apply the baseline role using the centos user
ansible-playbook playbooks/node-ci-ext-jenkins-worker.yml --limit <worker_name> -u centos -t baseline
# apply the playbook using your own user - dry run
ansible-playbook playbooks/node-ci-ext-jenkins-worker.yml --limit <worker_name> -u <your_kerberos_username> -CD
# apply the playbook using your own user - dry run
ansible-playbook playbooks/node-ci-ext-jenkins-worker.yml --limit <worker_name> -u <your_kerberos_username>
```

5. Create the new node in jenkins by copying an existing node and changing the IP: https://ci.ext.devshift.net/computer/new
