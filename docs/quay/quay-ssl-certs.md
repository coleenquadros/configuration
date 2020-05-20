# Quay.io SSL Certificates

Quay SSL certificates are managed in Vault with other Quay configuration & secrets. Quay SSL certs are stored in `quay-config-secret` with keys `ssl.cert` and `ssl.key`.

Quay SSL certificates also need to be imported into Amazon ACM so that they can be used with CloudFront distribution.
