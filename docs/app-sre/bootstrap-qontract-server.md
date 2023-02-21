# Bootstrap Qontract-Server

This assumes we have no qontract tooling running. Everything happens from local environment.

## Requirements

- an app-interface data repository
- AWS account + credentials
- openshift cluster + credentials
- AWS account and openshift cluster defined in app-interface

## Procedure

### Create a Namespace

1. Define a namespace in app-interface for qontract-server

2. Run `openshift-namespaces` integration to create it

### Setup Secrets

1. Place secrets referenced in [openshift templates](https://github.com/app-sre/qontract-server/blob/master/openshift/app-interface.yaml) in your local `config.toml`, e.g.,

**config.toml:**

```toml
# https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/dev-data/app-interface
[app-interface.app-sre.dev-data.app-interface]
"aws.access.key.id" = "TODO"
"aws.region" = "us-east-1"
"aws.s3.bucket" = "app-interface-development"
"aws.s3.key" = "data.json"
"aws.secret.access.key" = "TODO"
htpasswd = "TODO"
"slack.webhook_url" = "TODO"
```

2. Define the secret in the qontract-server namespace

3. Run `openshift-vault-secrets` integration locally to push secrets to the namespace in openshift

### Create Configuration

1. Create a configmap resource in app-interface and add it to the namespace

```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-interface
  annotations:
    qontract.recycle: "true"
type: Opaque
data:
  forward_host: app-interface.app-interface-production.svc
  load_method: s3
  GITHUB_API: https://github-mirror.devshift.net
  SENTRY_DSN: TODO
```

2. Run `openshift-resources` locally to create it

### Deploy Qontract-Server

1. Define a SaaS pipeline to deploy qontract-server master. You could name it `qontract-server-deploy`.

2. Run `openshift-saas-deploy` to deploy the template (this usually happens in tekton pipelines). `openshift-saas-deploy --saas-file-name qontract-server-deploy`.
