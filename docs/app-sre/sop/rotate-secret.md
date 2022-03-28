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
