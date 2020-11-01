# Quay.io SSL Certificates

## Generate SSL Certificates

```sh
openssl req -new -newkey rsa:2048 -nodes \
 -out star_quay_io.csr \
 -keyout star_quay_io.key \
 -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Service Delivery/CN=*.quay.io"
```

## Request Certificate from Digicert

Reach out to Red Hat IT to get certificate issued by Digicert. Include  `star_quay_io.csr` with your request.

## Update the Certificate in Vault

Quay SSL certificates are managed in Vault with other Quay configuration & secrets. Quay SSL certs are stored in `quay-config-secret` with keys `ssl.cert` and `ssl.key`. Secret in Vault can be found [here](quayio.md#updating-secret-in-vault)

## Digicert Docs

- [Order a wildcard SSL certificate](https://docs.digicert.com/manage-certificates/order-your-ssl-certificates/order-wildcard-ssl-certificate/)

