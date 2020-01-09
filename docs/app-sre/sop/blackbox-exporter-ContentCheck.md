# ContentCheck

## Severity: Critical

## Impact

- End users might be seeing blank webpages

## Summary

This check ensures that a webpage is serving the expected content, beyond a regular 2xx

## Access required

- Must be in Github app-sre team `app-sre-observability` to login to application prometheus instances.

## Steps

- Check the relevant prometheus instance for `probe_success`
- Get the labels from `probe_success` and list all other metrics
- Find the metric that's failing the probe
- For further troubleshooting, blackbox exporter logs the probes at its url, for example:
    - https://blackbox-exporter.devshift.net/
    - http://10.0.132.216:9115/ (CentralCI)

## Escalations

- If app-sre runs this service, ping oncall if required and follow incident procedures
