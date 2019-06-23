# Onboard a new cluster to app-itnerface

To on-board a new cluster to app-interface, perform the following operations:

1. Create `app-sre-bot` ServiceAccount in the `app-sre` namespace and add permissions to the ServiceAccount:

```shell
oc new-project app-sre
oc -n app-sre create serviceaccount app-sre-bot
oc adm policy add-cluster-role-to-user dedicated-cluster-admin app-sre/app-sre-bot
oc adm policy add-cluster-role-to-user dedicated-cluster-reader app-sre/app-sre-bot
oc adm policy add-cluster-role-to-user view app-sre/app-sre-bot
```

2. Get the token of the `app-sre-bot` SeriveAccount:

```shell
oc -n app-sre sa get-token app-sre-bot
```

3. Create a secret in Vault under the following path: `app-sre/creds/<cluster-name>-automation-token`. The secret should have a single `token` key with the value being the token from step 2.
