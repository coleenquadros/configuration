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

- Verify that the alert is legitimate
    ```
    HOST=<your host>
    PORT=443  ## it will usually be this one
    openssl s_client -servername $HOST -showcerts -connect $HOST:$PORT 2>/dev/null </dev/null | openssl x509 -text
    ```
- Check the relevant prometheus instance for `probe_success`
- Get the labels from `probe_success` and list all other metrics
- Find the metric that's failing the probe
- For further troubleshooting, blackbox exporter logs the probes at its url. See this [SOP for accessing the blackbox-exporter](accessing-blackbox-exporter-and-domain-exporter.md#blackbox-exporter).
- If the failing cert is located in an OSD cluster there are two main scenarios based on the certificate issuer (you can see it in the above command to check if certificate is legit):
  1. The issuer is Let's Encrypt: Please take a look to the [cert manager runbook](/docs/app-sre/runbook/cert-manager.md) for further instructions.
  1. The issuer is not Let's Encrypt (usually Digicert). These certificates are usually issued by IT. Take a look into the [Digicert certificates SOP](/docs/app-sre/sop/digicert-tls-certificates.md).


## Escalations

- If its the OSD cluster console certs, contact SREP to confirm cert rotation schedule
- If app-sre runs this service and cert has expired, ping oncall if required and follow incident procedures
