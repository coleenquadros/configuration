# Create API token for Grafana

## Background

We are using Promlens which requires a Grafana API token: https://issues.redhat.com/browse/APPSRE-4396

## Purpose

This is an SOP that explains how to create/revoke such API tokens.

## Content

To create API tokens we need to use admin credentials for grafana. The credentials can be found here:
- stage: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-stage/grafana/grafana-admin-user
- production: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/grafana/grafana-admin-user

In order to be able to use these credentials, basic auth must be enabled: https://gitlab.cee.redhat.com/service/app-interface/-/blob/f95887abf8ae7f48d2c3a0b30f3f3af7c535771f/resources/observability/grafana/grafana-config.secret.yaml#L14

Note: this makes grafana inaccessible.

Once grafana has basic auth enabled, follow the [documentation](https://grafana.com/docs/grafana/latest/http_api/create-api-tokens-for-org) on how to interact with grafana API to create or revoke API tokens:

```sh
# using a service called grafana-direct
$ oc port-forward <grafana_pod_name> 3001
# list keys
$ export GF_ADMIN_USER=<from vault secret>
$ export GF_ADMIN_PASSWORD=<from vault secret>
$ curl -H "Content-Type: application/json" http://$GF_ADMIN_USER:$GF_ADMIN_PASSWORD@localhost:3001/api/auth/keys
# generate new key
$ curl -X POST -H "Content-Type: application/json" -d '{"name":"<token_name>", "role": "Admin"}' http://$GF_ADMIN_USER:$GF_ADMIN_PASSWORD@localhost:3001/api/auth/keys
```

The token for promlens can be found here:
- stage: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-stage/grafana/grafana-api-token
- production: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-observability-production/grafana/grafana-api-token
