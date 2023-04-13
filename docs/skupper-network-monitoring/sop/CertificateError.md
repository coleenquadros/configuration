# SOP - CertificateError

## Severity: Critical

## Impact

This alert is triggered when the X509 Certificate Exporter cannot decode a certificate from Kubernetes TLS secrets. The certificate must be malformed or corrupted. The skupper-network/skupper-site using this certificate is impacted and not functioning.

## Summary

X509 Certificate Exporter is unable to decode a certificate.

## Access required

Access to clusters and namespaces where the x509 certificate exporter is deployed.

## Steps
- Log into the console and verify if x509-certificate-exporter pods are up/stuck.
- Review the logs of the pods to see if there are any errors.
- Review the certificate to see if it is malformed or corrupted
  ```
  $ oc get secret <secret-name> -n <namespace> -o jsonpath='{.data.tls\.crt}' | base64 --decode | openssl x509 -text -noout
  ```
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
