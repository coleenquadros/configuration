# SOP for reinstalling bastion instance (bastion.ci.int.devshift.net)

Bastion instance provisioned by [terraform](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/app-sre-ci/ci-int-bastion.tf) and [ansible](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/node-bastion.yaml)

So need to replay ansible playbook like: `ansible-playbook playbooks/node-bastion.yaml -CD` and `ansible-playbook playbooks/node-user-housekeeping.yml --tags bastion-accounts -CD`

Or if replaying ansible playbooks hasn't fixed the problem:
1. Delete AWS EC2 instance
1. In clonned [repo](https://gitlab.cee.redhat.com/app-sre/infra/) go to terraform/app-sre/app-sre-ci
1. Run `terraform init`, `terraform plan`, `terraform apply`
