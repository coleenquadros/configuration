# SOP for reinstalling bastion instance (bastion.ci.ext.devshift.net)

Bastion instance provisioned by [terraform](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/ci.ext/ci.ext-bastion.tf) and [ansible](hhttps://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/node-ci-ext-bastion.yaml)

So need to replay ansible playbook like: `ansible-playbook playbooks/node-ci-ext-bastion.yaml -CD` and `ansible-playbook playbooks/ci-ext-bastion-accounts.yml -CD`

Or if replaying ansible playbooks hasn't fixed the problem:
1. Delete AWS EC2 instance
1. In clonned [repo](https://gitlab.cee.redhat.com/app-sre/infra/) go to terraform/app-sre/ci.ext
1. Run `terraform init`, `terraform plan`, `terraform apply`
