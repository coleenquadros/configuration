# Rotate Vault Secret ID

If this is a high emergency situation, then we can start with step 5. and delete the secret ID instantly.
Note, that this will lead to all integrations failing, thus secrets will need to be adjusted manually.
If this is not super urgent, then follow this procedure:

1. Create new secret ID in vault - you can do this in the terminal of the [vault UI](https://vault.devshift.net)

Double check parameters with what is currently configured in the [approle](../../data/services/vault.devshift.net/config/prod/roles/approles/app-interface-approle.yml).

```
vault write -f auth/approle/role/app-interface/secret-id bind_secret_id=true local_secret_ids=false token_period=0 secret_id_num_uses=0 secret_id_ttl=0 token_explicit_max_ttl=0 token_max_ttl=1800 token_no_default_policy=false token_num_uses=0 token_ttl=1800 token_type="default" token_policies=[app-interface-approle-policy] policies=[app-interface-approle-policy]
```

Remember that secret ID -> you need to change it now in several places.

2. Remember old secret ID

Copy old secret ID from [any configuration](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/qontract-reconcile-toml).
You will need it in the last step of this SOP

3. Update secret ID in configs

Update the secret ID in the following configs:

- [reconcile-config-toml](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/qontract-reconcile-toml) -> create new secret version
- [reconcile-config-toml-stage](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre-stage/app-interface-stage/qontract-reconcile-toml) -> create new secret version
- [ci-int-config-toml](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml) -> edit secret (Jenkins does not support secret versions)
  - don't forget to also update `data_base64`! Decode via `base64 -d` and then encode with `base64` (as is, newlines are fine in there)

- [gitlab-fork-compliance](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/gitlab-fork-compliance-approle-creds)
  - don't forget to also update `data_base64`! Decode via `base64 -d` and then encode with `base64` (as is, newlines are fine in there)

4. Bump secret versions in app-interface

Create and merge an MR that bumps the newly created secret versions in app-interface
(Grep for the secrets' vault path in the following files and bump the versions)

- [app-interface-prod](../../data/services/app-interface/namespaces/app-interface-production.yml)
- [app-interface-prod-int](../../data/services/app-interface/namespaces/app-interface-production-int.yml)
- [app-interface-stage](../../data/services/app-interface/namespaces/app-interface-stage.yml)
- [app-interface-stage-int](../../data/services/app-interface/namespaces/app-interface-stage-int.yml)

5. Delete old secret ID

Make sure integrations are running properly. Once you delete the old secret ID, it cannot be recovered.

```
vault write -f auth/approle/role/app-interface/secret-id/destroy secret_id=<OLD_SECRET_ID_FROM_STEP_2>
```

6. Ensure old secret ID is not usable anylonger

This command must fail:

```
vault write auth/approle/login role_id=7a72019e-85e0-637a-7706-65c88a47fd94 secret_id=<OLD_SECRET_ID_FROM_STEP_2>
```

