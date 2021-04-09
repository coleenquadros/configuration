# Quay.io SSL Certificates

The quay.io SSL certificates are used by the quay app directly which is where TLS is terminated through the Load Balancer service

## Process

The process to generate and request a TLS certificate from IT can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/digicert-tls-certificates.md)

## Update the Certificate in Vault

Quay SSL certificates are managed in Vault with other Quay configuration & secrets. Quay SSL certs are stored in `quay-config-secret` with keys `ssl.cert` and `ssl.key`. Secret in Vault can be found [here](quayio.md#updating-secret-in-vault)
