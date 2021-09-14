# Certificates

Quay.io's stage and production certificates are managed by [DigiCert](https://www.digicert.com/).  Quay needs three certificates in order to function properly:

- Wildcard Certificate (usually prefixed with start_ in the cert files)
- Intermediate Certificate (in DigiCert parlance this is called the `DigiCert SHA2 High Assurance Server CA`)
- Root Certificate (in DigiCert parlance this is called the `DigiCert High Assurance EV Root CA`).

Most requests through IT will produce a zipfile with the Intermediate Certificate and the Wildcard Certificate.  When making a request to create or renew a certificate, make sure to request all three certificates in the SNOW ticket.

## Get a CSR

The current CSR used for the stage and prod SSL certs is located in [vault](https://vault.devshift.net/ui/vault/secrets/quay/list) in the ssl key for quayio-stage and quayio-prod.

If a new CSR is required, then follow the entire process described in the Digicert TLS Certificates [SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/digicert-tls-certificates.md).

  *NOTE*: The COMMON_NAME needs to match the common name for the DigiCert.  It should be `*.quay.io` or `*.stage.quay.io` depending on which one is being generated.

If a new CSR is not required, then skip the CSR generation and continue with the rest of the Digicert TLS Certificates [SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/digicert-tls-certificates.md).

## Update Vault

Once the SNOW ticket has been completed by IT, the ssl certificate information will need to be updated in vault.

For stage the secret that needs to be updated is located [here](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-stage/quayio-stage/quay-config-secret).

For production the secret that needs to be updated is located [here](https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-prod-us-east-1/quay/quay-config-secret).

If a new CSR was generated, than a new key file was also created and needs to be updated in vault.  That key file (usually ending with .key if the [SOP](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/digicert-tls-certificates.md) was followed) will need to be placed into the `ssl.key` field in the secret.

Next the data to place into the `ssl.cert` field in the secret will need to be generated.  This is a combination of the Wildcard Certificate, Intermediate Certificate, and the Root Certificate.  *THE ORDER IS IMPORTANT*.  The certificates need to be in this order:

1. Wildcard Certificate
1. Intermediate Certificate
1. Root Certificate

Generate the contents via:

```shell
cat <wildcard_cert_file> <intermediate_cert_file> <root_cert_file>
```

Copy the result of that command and place it into the `ssl.cert` field in the secret.

Make sure to update the version of the quay secret deployed in app-interface for the new certs to take affect.

