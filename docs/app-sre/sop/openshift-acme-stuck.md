## Overview 

Several openshift routes on app-sre clusters have their certificate managed by [openshift-acme](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/openshift-acme.md).

TLS Certificates in Routes are set in plain text in the TLS attribute spec. 

```yaml
apiVersion: v1
kind: Route
metadata:
  name: frontend
spec:
  host: www.example.com
  to:
    kind: Service
    name: frontend
  tls:
    termination: reencrypt
    key: |-
      -----BEGIN PRIVATE KEY-----
      [...]
      -----END PRIVATE KEY-----
    certificate: |-
      -----BEGIN CERTIFICATE-----
      [...]
      -----END CERTIFICATE-----
    caCertificate: |-
      -----BEGIN CERTIFICATE-----
      [...]
      -----END CERTIFICATE-----
    destinationCACertificate: |-
      -----BEGIN CERTIFICATE-----
      [...]
      -----END CERTIFICATE----- 
```

This certificate rotation process is known to occasionally get stuck. The openshift-acme operator fails to manage the ACME Order and the certificate in the Route is not updated. 

Currently we're not sure what exactly causes this "stuck" state to occur. It is unclear if this is a problem is caused by openshift-acme, openshift routes, or possibly something else. [This mostly-unresolved issue](https://github.com/tnozicka/openshift-acme/issues/134) exists for the openshift-acme project.

## How to Fix

Use app-interface to identify:
* the "route" resource that represents the hostname with the "stuck" certificate
* the cluster containing the namespace that this "route" belongs to.

Use the `oc` CLI to login to this cluster.

Run `oc -n <namespace> describe route <route>`

Verify the certificate in the TLS spec is not updated. If the certificate is updated, you are probably facing another problem related to openshift-ingress controller. 
`oc get route <route> -o json | jq .spec.tls.certificate | openssl x509 -noout -text -in -`
If you get an error with the command, maybe the certificate contains the whole certificate chain, you will need to remove the intermediate CA's to get the host one. 

Verify the value of the `openshift.io/status=provisioningStatus.orderStatus` annotation and the ACME order. If the value is `pending` or `ready`, then check the order link set in the annotation to see the real order state.
e.g:

```yaml 
    acme.openshift.io/status: |
      provisioningStatus:
        earliestAttemptAt: "2022-03-16T12:30:59.602678051Z"
        orderStatus: pending
        orderURI: https://acme-v02.api.letsencrypt.org/acme/order/96822116/71950839980 # <-- OPEN THIS LINK
        startedAt: "2022-03-16T12:30:59.602678051Z"
```

If you navigate to the URI referenced in the `orderURI` property from the previous step, you should see a JSON format "order" comparable to the following:

```yaml
{
  "status": "valid",   ## <-- THE STATUS
  "expires": "2022-03-23T12:30:59Z",
  "identifiers": [
    {
      "type": "dns",
      "value": "wllyvs40ee788l7.api.stage.openshift.com"
    }
  ],
  "authorizations": [
    "https://acme-v02.api.letsencrypt.org/acme/authz-v3/86564274200"
  ],
  "finalize": "https://acme-v02.api.letsencrypt.org/acme/finalize/96822116/71950839980",
  "certificate": "https://acme-v02.api.letsencrypt.org/acme/cert/04df292ddcc11855ff336148d21609d65610" # <-- THE CERTIFICATE
}
```


Set the `openshift.io/status=provisioningStatus.orderStatus` annoation value to `valid`. Do this by editing the `acme.openshift.io/status` annotation, but keep the value of everything except `orderStatus` the same.

**IMPORTANT:** If the Order state is errored or not valid for any reason, another path forward is to delete the whole `acme.openshift.io/status` annotation from the Route to request a brand new certificate with a new order. 

```
# example
oc -n <namespace> edit route <route> 
```

Within a few minutes, the certificate should be updated via openshift-acme. Proceed to validate.

## How to Validate

You can validate the current expiration date of a certificate managing an endpoint through a web browser, or with `curl`.

```
curl -vs $ENDPOINT 2>&1 | grep expire
```

```
# example

$ curl -vs https://api.openshift.com 2>&1 | grep expire

expire date: Jun 13 16:25:11 2022 GMT
```
