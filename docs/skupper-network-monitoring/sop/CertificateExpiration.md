# SOP - CertificateExpiration

## Severity: High

## Impact

This alert is triggered when a skupper certificate is about to expire in less than 14 days. The skupper-network is still functioning, but the certificate will expire soon.

## Summary

A certificate is about to expire, and Skupper doesn't automatically renew certificates. The affected Skupper-site must be redeployed to generate a new certificate.

## Access required

App-Interface access.

## Steps
- Identify the namespace of the affected Skupper-site.
- Redeploy the skupper-site by adding and removing `delete: true`) to generate a new certificate.
  ```yaml
  ---
  $schema: /openshift/namespace-1.yml

  ...

  skupperSite:
    network:
      $ref: /path/to/skupper-network.yaml
    delete: true
  ```

## Escalations
- Ping `@app-sre-ic` in `#sd-app-sre` on Slack
