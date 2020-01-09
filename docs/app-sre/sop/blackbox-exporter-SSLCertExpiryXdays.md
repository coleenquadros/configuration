# ContentCheck

## Severity: Variable

## Impact

- Depending on the number of days, we risk getting an expired SSL cert that can cause cascading failures

## Summary

Blackbox exporter is set up to monitor the SSL chain on specific URL's

We will start seeing alerts when the SSL cert is close to expiry, or when its already expired

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

- If its the OSD cluster console certs, contact SREP to confirm cert rotation schedule
- If app-sre runs this service and cert has expired, ping oncall if required and follow incident procedures
