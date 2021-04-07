# 1. Description

**Important:** In most cases, we want to use LetsEncrypt certificates to secure service endpoints. For that we use openshift-acme as documented [here](https://gitlab.cee.redhat.com/service/app-interface/#manage-openshift-acme-deployments-via-app-interface-openshiftacme-1yml)

This SOP describes how to request a new (or the renewal of a) TLS certificate signed externally by DigiCert.

The IT Operations team is responsible for TLS certificates.

Their IRC channel at irc.devel.redhat.com is #iso (on-call can be pinged for urgent requests)

# 2. Process

1. Generate a CSR/KEY (if a new certificate is requested)

```sh
# Wildcard cert
# COMMON_NAME=*.mydomain.com

# Single domain 
COMMON_NAME=mydomain.com

openssl req -new -newkey rsa:2048 -nodes \
 -out star_quay_io.csr \
 -keyout star_quay_io.key \
 -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Service Delivery/CN=$COMMON_NAME"
```

2. Open a ticket with IT Operations using the [certificate request form](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=e5fc3a19db0898149693cf5e13961975)
   - Note: Use the [Application Intake Form](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=88c9c7bb137f1340196f7e276144b020) to request a new application to link the certificate to in the previous form

3. The certificate will be attached to the ticket once it is created. Optionally you can request that you want the certificate to be sent via email.

4. (Optionally) If the certificate is to be used for an OpenShift route, it should be added to vault along with the corresponding key. See documentation here: https://gitlab.cee.redhat.com/service/app-interface/#manage-routes-via-app-interface-openshiftnamespace-1yml-using-vault
