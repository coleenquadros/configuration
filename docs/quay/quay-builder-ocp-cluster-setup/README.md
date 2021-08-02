# Quay Builder OpenShift Cluster

Instructions to setup a OpenShift Container Platform (OCP) cluster for Quay builders.

## Pre Requisites

### Red Hat Account

Request an account in APP SRE Red Hat organization if you don't have one. You will need it to get OpenShift installer and pull secrets.

### AWS Account

To get access to the AWS account dedicated for Quay builder cluster, you will need to be a member of the APP SRE team. Follow the steps documented [here](https://gitlab.cee.redhat.com/service/app-interface#add-or-modify-a-user-accessusers-1yml) to add a user to the team.

Once your request has been approved by APP SRE team, you will get an email with subject `Invitation to join the quay-builder AWS account`. Email will include AWS console url, your IAM username and password encrypted using your GPG key. You will be required to set a new password on first login.

### GitHub Team

Access to the OpenShift cluster is managed by GitHub [team](https://github.com/orgs/app-sre/teams/quay-app-sre). Make sure you are a member.

### Vault

Request and verify access to [quay secrets engine](https://vault.devshift.net/ui/vault/secrets/quay/list) in Vault. Access to Vault is managed by app-interface. See [docs](https://gitlab.cee.redhat.com/service/app-interface#manage-vault-configurations-via-app-interface) for access.

### DNS Zone Delegation & Base Domain

If you are starting from scratch, you will need to create a DNS zone delegation in the AWS account. Current AWS account has hosted zone setup for the domain `ocp4-builder.quay.io`. This will be the base domain for the OCP cluster.

Base domain must be managed in the same AWS account where OpenShift cluster will be deployed. See [docs](https://docs.openshift.com/container-platform/4.1/installing/installing_aws/installing-aws-account.html#installation-aws-route53_installing-aws-account) for more details.

### SSH Key

For production OpenShift Container Platform clusters on which you want to perform installation debugging or disaster recovery, you must provide an SSH key that your `ssh-agent` process uses to the installer. You can use this key to SSH into the master nodes as the user `core`. When you deploy the cluster, the key is added to the `core` user’s `~/.ssh/authorized_keys` list.

SSH key used for current cluster can be found in [Vault](https://vault.devshift.net/ui/vault/secrets/quay/show/quay-builder/ssh-key).

Follow steps documented [here](https://docs.openshift.com/container-platform/4.1/installing/installing_aws/installing-aws-customizations.html#ssh-agent-using_install-customizations-cloud) to add the SSH key to the `ssh-agent`.

## Install OCP Cluster on AWS

### AWS CLI Configuration

Install and configure AWS cli on the system where you will run the OpenShift installer. You may use the existing `terraform` user or [create an new one](https://docs.openshift.com/container-platform/4.1/installing/installing_aws/installing-aws-account.html#installation-aws-iam-user_installing-aws-account).

### AWS Account/Region Limits

If you are using `us-east-1`, the default account limits are not enough to deploy OpenShift cluster even in a singe az mode. Review the limits listed [here](https://docs.openshift.com/container-platform/4.1/installing/installing_aws/installing-aws-account.html#installation-aws-limits_installing-aws-account) and open support case with AWS to increase resource limits.

### Obtain Installer

Log into [OCM](https://console.redhat.com/) to download the OCP installer for AWS (with Installer-Provisioned Infrastructure) and pull secrets. You will also need the OpenShift command-line tools which can be downloaded from the same page.

### Installer Configuration File

Steps for creating the installer configuration file can be found [here](https://docs.openshift.com/container-platform/4.1/installing/installing_aws/installing-aws-customizations.html#installation-initializing_install-customizations-cloud). A copy of the `install-config.yaml` used to setup the builder cluster can be found [here](ocp-installer-config/install-config.yaml). The installer configuration file is consumed with each install run so make sure to backup the configuration file before running the installer. This will allow you to re-run installer with same configuration if needed.

#### Cluster Configuration

| | Master | Worker | Bare-metal Worker |
| --- | --- | --- | --- |
|**Count/Instance Type**|3 / m5.xlarge|3 / m5.xlarge | 1 / m5.metal|
|**EBS Volume Type**|gp2|gp2|gp2|
|**EBS Volume IOPS**|100|100|5000|
|**EBS Volume Size**|500|500|5000|
|**Region**|us-east-1|us-east-1|us-east-1|
|**Availability Zone**|us-east-1d|us-east-1d|us-east-1d|

When creating the cluster install config, you will configure it for `3` master nodes and `3` worker nodes of type m5.xlarge. `m5.metal` worker node will be added once the cluster setup is complete.

See [install-config.yaml](ocp-installer-config/install-config.yaml) for networking configuration details.

### Deploy the Cluster

Follow [instructions](https://docs.openshift.com/container-platform/4.1/installing/installing_aws/installing-aws-customizations.html#installation-launching-installer_install-customizations-cloud) to deploy the cluster.

Installer will take about 60 minutes to deploy the cluster if there are no issues.


## Configure OpenShift Cluster

To setup the cluster, you can use the temporary `kubeadmin` credentials.

Note: You must update files with actual values before running commands listed below.

### Create Security Context Constraints

```sh
oc apply -f cluster-setup/01-quay-builder-scc.yaml
```

### Configure GitHub Identity Provider

[Register](https://docs.openshift.com/container-platform/4.1/authentication/identity_providers/configuring-github-identity-provider.html#identity-provider-registering-github_configuring-github-identity-provider) a new GitHub application in the `app-sre` organization.

#### Create the Secret

```sh
oc create secret generic -n openshift-config github-secret --from-literal=clientSecret=<redacted>
```

#### Create OAuth CR

```sh
oc apply -f cluster-setup/02-github-idp-oauth.yaml
```

### Create APP SRE Group

```sh
oc apply -f cluster-setup/03-quay-app-sre-group.yaml
```

### Create Cluster Role Binding

This will bind `cluster-admin` role to all users in APP SRE group.

```sh
oc apply -f cluster-setup/04-quay-app-sre-cluster-role-binding.yaml
```

## Configure Builder Project

### Create Builder Project

```sh
oc new-project builder
```

### Create Service Account

```sh
oc apply -n builder -f project-setup/01-service-account.yaml
```

### Create Ingress Network Policy

```sh
oc apply -n builder -f project-setup/02-ingress-network-policy.yaml
```

### Create Egress Network Policy

Note: Before applying egress network policy, make sure there no other egress network policy applied for the project. If OpenShift detects multiple egress network policy for a project, it will degrade the networking on purpose. Only one egress network policy is allowed in a project.

```sh
oc apply -n builder -f project-setup/03-egress-network-policy.yaml
```

### Create Security Context Constraints Role & Role Binding


```sh
oc apply -n builder -f project-setup/04-quay-builder-scc-role.yaml && oc apply -n builder -f project-setup/05-quay-builder-scc-rolebinding.yaml
```

### Create Image Pull Secret

```sh
oc apply -n builder -f project-setup/06-image-pull-secret.yaml
```

## Cluster Setup (contd.)

### SSL Certificate

Cluster is deployed with self-signed certificate. You will need to request SSL certificate from Digicert for the default ingress and the API server.

#### Create Certificate Signing Request

```sh
openssl req -new -newkey rsa:2048 -nodes \
 -out star_apps_c1_ocp4-builder_quay_io.csr \
 -keyout star_apps_c1_ocp4-builder_quay_io.key \
 -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Service Delivery - APP SRE/CN=*.apps.c1.ocp4-builder.quay.io"
```

Request a wildcard certificate from [DigiCert](https://www.digicert.com/) with 2 year validity. In your request, you should include all the subject alt names for the certificate. A cluster with base domain `subdomain.example.com` must have following subject alt names in the certificate request:

- `*.cluster-name.subdomain.example.com`
- `*.apps.cluster-name.subdomain.example.com`

Once your certificate request has been approved, you will receive email with the actual SSL certificates. SSL Certificates are stored in [Vault](https://vault.devshift.net/ui/vault/secrets/quay/show/quay-builder/ssl).

The certificate zip file will contain multiple `.crt` files. You need to combine all certificate files to create a `fullchain.crt` file. Order of certificate in `fullchain.crt` should be following:

1. star_your_domain.crt
2. DigiCertCA.crt
3. TrustedRoot.crt

#### Replacing the Default Ingress Certificate

##### Delete Existing Secret

Note: This secret will not exist on a fresh cluster.

```sh
oc delete secret certificate -n openshift-ingress
```

##### Create New Secret

```sh
oc create secret tls certificate --cert=fullchain.crt --key=star_c1_ocp4-builder_quay_io.key -n openshift-ingress
```

##### Update the Ingress Controller Configuration

```sh
oc patch ingresscontroller.operator default --type=merge -p '{"spec":{"defaultCertificate": {"name": "certificate"}}}' -n openshift-ingress-operator
```

#### Add an API Server Named Certificate

##### Delete Existing Secret

Note: This secret will not exist on a fresh cluster.

```sh
oc delete secret certificate -n openshift-config
```

##### Create New Secret

```sh
oc create secret tls certificate --cert=fullchain.crt --key=star_c1_ocp4-builder_quay_io.key -n openshift-config
```

##### Update the API Server Configuration

Note: Replace the domain name for API server with the one for your cluster.

```sh
oc patch apiserver cluster --type=merge -p '{"spec":{"servingCerts": {"namedCertificates":  [{"names": ["api.c1.ocp4-builder.quay.io"], "servingCertificate": {"name": "certificate"}}]}}}'
```

### Create Machineset for Bare-Metal Worker Node

Note: Because `m5.metal` instances are expensive, add the node once you have completed rest of the setup steps.

To add `m5.metal` worker node, you will need to create a new [MachineSet](https://docs.openshift.com/container-platform/4.1/machine_management/creating-machineset.html). A copy of current MachineSet can be found [here](cluster-setup/05-bare-metal-machine-set.yaml).

```sh
oc apply -n openshift-machine-api -f cluster-setup/05-bare-metal-machine-set.yaml
```

#### Approve CSR for MachineSet

EC2 Instances of type metal.m5 are not automatically approved by the node auto-approver in OpenShift v4.1. We have filed a [bugzilla](https://bugzilla.redhat.com/show_bug.cgi?id=1723955) for engineering team. Current work around is to monitor pending CSR requests and approve them.

List all pending CSRs:

```sh
oc get csr
```

Approve all pending CSRs:

```sh
oc get csr | tail -n +2 | awk '{print $1}' | while read line; do oc adm certificate approve $line; done
```

## Setup Cluster Monitoring

## Setup Cluster Alerting

## Setup Dead Man's Snitch

## Setup PagerDuty









