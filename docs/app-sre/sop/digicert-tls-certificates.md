# 1. Description

**Important:** In most cases, we want to use LetsEncrypt certificates to secure service endpoints. For that we use openshift-acme as documented [here](https://gitlab.cee.redhat.com/service/app-interface/#manage-openshift-acme-deployments-via-app-interface-openshiftacme-1yml)

This SOP describes how to request a new (or the renewal of a) TLS certificate signed externally by DigiCert.

The IT IAM team is responsible for TLS certificates.

The prefered communication channel for general assistance is #team-iam on RedHat Internal Slack (previously their Google Chat room was `IT-IAM`)

# 2. Process

1. Generate a CSR/KEY (if a new certificate is requested) and store the key in vault.

    ```sh
    # Wildcard certs are banned!
    # Single domain 
    COMMON_NAME=mydomain.com
    # ESSv9 requires secp384r1 curve for TLSv1.2
    openssl req -new -newkey ec:<(openssl ecparam -name secp384r1) -nodes \
     -out cert_req_name.csr \
     -keyout cert_req_name.key \
     -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Service Delivery/CN=$COMMON_NAME"
    ```
1. Open a ticket with IT IAM using the [certificate request form](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=e5fc3a19db0898149693cf5e13961975)
    * **Note:** As of the time of writing this, the form is broken. Upon ticking the required "I acknowledge..." box, a new mandatory section will appear called "Make CA Selection RHCS" which is not the CA we use. If this issue is still present, reach out to the IT IAM team in #team-iam on RedHat Internal Slack
    
    [This](https://redhat.service-now.com/help?id=rh_ticket&table=sc_req_item&sys_id=fb1650231bd20114839e32a3cc4bcb50) is an example of the outcome of that form.
1. The certificate will be attached as a zip file to the ticket once it is created. Optionally you can request that you want the certificate to be sent via email.
1. (Optionally) If the certificate is to be used for an OpenShift route, it should be added to vault along with the corresponding key. See documentation here: https://gitlab.cee.redhat.com/service/app-interface/#manage-routes-via-app-interface-openshiftnamespace-1yml-using-vault

# 3. Consuming the certificate

The zip file in the ticket will contain instructions on how to use the certificate. **Disregard them**. They are for older versions of Apache.

You will receive both the certificate for your application and the digicert CA certificate. Your service must consume both of them, **concatenated in a single file**. You may store them in separate keys in vault or concatenate them and then uploading the bundle to a single location in vault, like [we do here](https://vault.devshift.net/ui/vault/secrets/app-interface/show//app-sre/uhc-production/routes/api.openshift.com). 

In any case, when the concatenation happens, it **must** have the service's certificate file first and afterwards the CA certificate, like [in this example](https://gitlab.cee.redhat.com/app-sre/infra/-/blob/0e924c191e1ce09f2dced71a404cefa30230a7ac/ansible/playbooks/roles/nginx-reverse-proxy/tasks/main.yml#L27-32). Or, if you store the bundle in a single field in Vault:

``` sh
cat $application_name.crt DigiCertCA.crt > application_name_bundle.crt
vault kv patch $path ssl_bundle=@application_name_bundle.crt
```

