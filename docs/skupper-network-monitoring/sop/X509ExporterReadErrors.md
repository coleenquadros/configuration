# SOP - X509ExporterReadErrors

## Severity: High

## Impact

This alert is triggered when the X509 Certificate Exporter cannot read Kubernetes TLS secrets. The certificate monitoring is impacted but not the skupper networks.

## Summary

X509 Certificate Exporter is unable to read the certificate secrets.

## Access required

Access to clusters and namespaces where the x509 certificate exporter is deployed.

## Steps
- Log into the console and verify if x509-certificate-exporter pods are up/stuck.
- Review the logs of the pods to see if there are any errors.
- Optionally, try to restart the pods or manually trigger the deployment pipeline.

## Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
