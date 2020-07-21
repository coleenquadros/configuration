# 2xx Probe Failing

## Severity: Critical (prod) , High (stage)

## Impact

- Atleast a subset of end users may be unable to access the endpoint/URL

## Summary

Prometheus blackbox exporter scrapes checking for a `2xx` response from a web URL are failing

## Access required

- Must be in Github app-sre team `app-sre-observability` to login to application prometheus instances.
- Vault secret: https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-sre-prometheus/prometheus/prometheus-app-sre-additional-scrapeconfig


## Steps

- Check the relevant prometheus instance for `probe_success`
- Get the labels from `probe_success` and list all other metrics
- Find the metric that's failing the probe
- For further troubleshooting, blackbox exporter logs the probes at its url, for example:
    - https://blackbox-exporter.devshift.net/
    - http://10.0.132.216:9115/ (CentralCI)

## Escalations

- If app-sre runs this service, ping oncall if required and follow incident procedures

## Instances

### https://github.com/

If GitHub is down this may affect several things, so the first step is to send comms to as documented in AAA.md to let other people know.

#### Access to Vault

Vault relies on GitHub for authentication. However, if it's down, access to Vault can be obtained via this SOP:
https://gitlab.cee.redhat.com/dtsd/housekeeping/blob/master/docs/vault.md#login-to-vault-when-github-is-down

#### Access to OpenShift clusters

If authentication is down, access to the OpenShift clusters can be obtained via the ServiceAccount here:
https://vault.devshift.net/ui/vault/secrets/app-sre/list/creds/kube-configs/

There's a `qontract-cli` subcommand for this:

```
$ qontract-cli get bot-login app-sre-prod-01
oc login --server https://api.app-sre-prod-01.i7w5.p1.openshiftapps.com:6443 --token REDACTED
```

#### Failed build master jobs

The CI jobs that build GitHub repos will not work, and there's no workaround for this.

#### Rollbacks of prod deployments if the saasrepo is in GitHub

Some saas-repos are in GitHub. If GitHub is down the rollback will not work as the CI job will immediately fail since it won't be able to git clone the repo.

A possible way of working around this is by restoring the saas repo and the upstream repo from the [git-keeper backups](https://gitlab.cee.redhat.com/service/app-interface/blob/master/docs/app-sre/sop/git-keeper-restore.md) and running the deployment manually (easier) or pushing the backed up repo to gitlab and create the corresponding CI/CD jobs in ci-int (the jobs that will usually fail are those that are run by ci-ext).

This will be eventually fixed entirely by https://issues.redhat.com/browse/APPSRE-1276.
