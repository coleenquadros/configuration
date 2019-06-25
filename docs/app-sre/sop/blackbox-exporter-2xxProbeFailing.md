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
    - https://blackbox-exporter-app-sre-exporters.1061.app-sre.openshiftapps.com/
    - http://10.0.132.216:9115/ (CentralCI)

## Escalations

- If app-sre runs this service, ping oncall if required and follow incident procedures
