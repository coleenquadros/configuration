# Rotate Vault Secret ID

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

Update the secret ID in the following confis:

- [reconcile-config-toml](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/qontract-reconcile-toml)
- [ci-int-config-toml](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml)
  - don't forget to also update `data_base64`! 

4. Trigger a dummy-deployment

Let's roll out qontract-reconcile to see if everthing works as expected. Create and deploy a dummy release.

5. Delete old secret ID

```
vault write -f auth/approle/role/app-interface/secret-id/destroy secret_id=<OLD_SECRET_ID_FROM_STEP_2>
```

6. Ensure old secret ID is not usable anylonger

```
vault write auth/approle/login role_id=7a72019e-85e0-637a-7706-65c88a47fd94 secret_id=<OLD_SECRET_ID_FROM_STEP_2>
```

