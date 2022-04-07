# Rotate a secret in vault and app-interface

When a user has a secret they need rotated but they can't access
vault, they usually transmit it to the IC and it's the IC's
responsibility to perform the update.

To safely transmit the secret, you should run
qontract-cli's `gpg-encrypt` command.
The command requires the `org_username` for which
to encrypt the secret.
The command then generates a GPG message which can be
safely transmitted via slack or email.

The `-o` switch allows to specify an output file
instead of printing to stdout.

## Customer Side

Use this `config.customer.toml`:

```
# You need VPN enabled to use this backend!
[graphql]
server = "https://app-interface.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/graphql"
```

### Run via docker

Note: this option might pose trouble with SELinux, especially on Fedora/RHEL.

```
docker run -v $(pwd)/config.customer.toml:/config.customer.toml -v $(pwd)/file-to-share:/file-to-share quay.io/app-sre/qontract-reconcile qontract-cli --config /config.customer.toml gpg-encrypt --file-path /file-to-share --for-user kfischer
```

### Install natively via pip

```
pip install --upgrade qontract-reconcile
qontract-cli --config /config.customer.toml gpg-encrypt --file-path /file-to-share --for-user kfischer
```

## AppSRE

## Encrypt Secret from Local File

```bash
qontract-cli gpg-encrypt --for-user kfischer --file-path some/local/file
```

## Encrypt Secret from OpenShift

```bash
qontract-cli gpg-encrypt --for-user kfischer --openshift-path <cluster>/<namespace>/<secret>
```

## Encrypt Secret from Vault

```bash
qontract-cli gpg-encrypt --for-user kfischer --vault-path /app-sre/some/secret
```

Or get a specific version of a secret:

```bash
qontract-cli gpg-encrypt --for-user kfischer --vault-path /app-sre/some/secret --vault-secret-version 5
```
