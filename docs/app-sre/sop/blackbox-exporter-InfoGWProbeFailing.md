# InfoGW Probe Failing

## Severity: Critical (prod) , High (stage)

## Impact

Atleast a subset of end users may be unable to access either of the Info Gateway endpoints/URLs.

## Summary

Prometheus blackbox exporter probes the target (also providing a bearer token to be able to authorize itself) and subsequently checking for string `Prometheus` in the response.

## Access required

- Must be in Github app-sre team `app-sre-observability` to login to application prometheus instances.
- Config: `resources/observability/blackbox-exporter/blackbox-exporter-config.secret.yaml`
- Bearer token secret in Vault:
  - For staging: `app-sre/integrations-output/openshift-serviceaccount-tokens/app-sre-stage-01/telemeter-stage/app-sre-stage-01-telemeter-stage-telemeter-prometheus-access`
  - For production: `app-sre/integrations-output/openshift-serviceaccount-tokens/telemeter-prod-01/telemeter-production/telemeter-prod-01-telemeter-production-telemeter-prometheus-access`


## Steps

- Check the relevant prometheus instance for `probe_success`
- Get the labels from `probe_success` and list all other metrics
- Find the metric that's failing the probe
- For further troubleshooting, blackbox exporter logs the probes at its url, for example:
    - https://blackbox-exporter.devshift.net/
    - http://10.0.132.216:9115/ (CentralCI)

## Escalations

- If app-sre runs this service, ping oncall if required and follow incident procedures
