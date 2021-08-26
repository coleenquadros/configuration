# Certificates

Quay.io's stage and production certificates are managed by [DigiCert](https://www.digicert.com/).

## Generate a Certificate Signing Request (CSR)

A CSR is required to issue or update a certificate with DigiCert.

To generate a CSR, run this command:

```shell
openssl req -new -newkey rsa:2048 -nodes \
 -out star_quay_io.csr \
 -keyout star_quay_io.key \
 -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Service Delivery/CN=*.quay.io"
```

*NOTE*: The CN needs to match the common name for the DigiCert.  It should be `*.quay.io` or `*.stage.quay.io` depending on which one is being generated.

The current CSR used for the stage and prod SSL certs is located in [vault](https://vault.devshift.net/ui/vault/secrets/quay/list) in the ssl key for quayio-stage and quayio-prod.

