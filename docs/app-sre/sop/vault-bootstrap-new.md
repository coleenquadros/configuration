# Bootsraping new Vault instance
This SOP captures some non-obvious steps for bootstraping new [Hashicorp Vault](https://www.vaultproject.io/docs/install) instance.
Existing [Vault SOP](../vault.md) for reference

## Terraform resources needed for Vault

1. S3 [buckets](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/vault-production/vault-s3.tf) for holding content, audit logs, backups
1. [KMS](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/vault-production/vault-kms.tf) for auto-unsealing Vault
1. [RDS](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/vault-production/vault-locking.tf) for HA 
1. [IAM user](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/terraform/app-sre/vault-production/vault-s3.tf) and AWS secret key for using S3 buckets

## OpenShift Resources

1. [Template](https://gitlab.cee.redhat.com/service/vault-devshift-net)
1. Secrets
1.1. [Vault settings](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/namespaces/vault-prod.yml#L27)
1.1. [Vault TLS](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/namespaces/vault-prod.yml#L30)
1.1. [Route](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/namespaces/vault-prod.yml#L33)

## App Interface resources

1. [Namespace file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/namespaces/vault-prod.yml0) 
1. [SaaS-file](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/cicd/saas.yaml)

## Steps for deploying new vault instance

1. Create all terraform resources (just copy and adapt)
1. Create AWS secret key for IAM user, need to do it manually
1. Create TLS files
    1. Create self-signed CA
    1. Create Certifcate Signing Request with SANs: --ip 127.0.0.1 --domain vault,vault.vault-prod,vault.vault-prod.svc,vault.vault-prod.svc.cluster.local
    1. Sign CSR with CA
```
podman run --rm -it --name certstrap -v $(pwd):/workdir:Z -w /workdir squareup/certstrap init --common-name "FedRAMP Vault CA" --locality "AppSRE" --province "CA" --country "US" --key ca.key --expires '60 months'
podman run --rm -it --name certstrap -v $(pwd):/workdir:Z -w /workdir squareup/certstrap request-cert --common-name "FedRAMP Vault" --locality "AppSRE" --province "CA" --country "US" --ip 127.0.0.1 --domain vault,vault.vault-prod,vault.vault-prod.svc,vault.vault-prod.svc.cluster.local
podman run --rm -it --name certstrap -v $(pwd):/workdir:Z -w /workdir squareup/certstrap sign FedRAMP_Vault --CA FedRAMP_Vault_CA
```
4. Put CA, certificate and key into vault-tls secret
1. Put CA into route secret (need to trust service because we are using `reencrypt`)
1. If not using OpenShift-Acme put external certificate and key into route secret

Now you are are able to deploy vault, do it for checking obvious typos/missing secrets/settings, Vault won't be able to run yet

**Note!** If this Vault instance is being deployed to a public cluster, do not deploy a Route for accessing it yet. Instead, utilize [port forwarding](https://docs.openshift.com/container-platform/3.11/dev_guide/port_forwarding.html) to complete step 7. The Route can be provisioned once step 7 is completed.

**Note!** You need temporarily remove Readyness and Liveness probes from DeploymeConfig as them expect vault to be fully configured and then will crashloop PODs

7. Go to Vault web-UI, create 5/2 keys and root token, download it and save securily
1. Restore Readyness and Liveness probes
1. Login to vault and create approle auth method
1. Login to vault and create [vault-manager-policy](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/policies/vault-manager-policy.yml) policy
1. Login to vault and create [vault-manager](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/vault.devshift.net/config/policies/vault-manager-policy.yml) approle
1. Get vault-manager approle's id and secret ID, put them in app-interface for managing this new instance
1. END

