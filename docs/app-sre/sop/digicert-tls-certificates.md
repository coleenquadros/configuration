# 1. Description

**Important:** In most cases, we want to use LetsEncrypt certificates to secure service endpoints. For that we use openshift-acme as documented [here](https://gitlab.cee.redhat.com/service/app-interface/#manage-openshift-acme-deployments-via-app-interface-openshiftacme-1yml)

This SOP describes how to request a new (or the renewal of a) TLS certificate signed externally by DigiCert.

The IT Operations team is responsible for TLS certificates.

Their IRC channel at irc.devel.redhat.com is #iso (on-call can be pinged for urgent requests)

Their Google Chat room is `IT Utility & Infra Services (UIS)`

# 2. Process

1. Generate a CSR/KEY (if a new certificate is requested)

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
1. Open a General IT SNOW [ticket](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=630e51c22bb23c004c71dc0e59da15bb&sc_catalog=1a98389b4fa25b40220104c85210c7d4&sysparm_category=null)
1. Open a ticket with IT Operations using the [certificate request
   form](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=e5fc3a19db0898149693cf5e13961975)

   *Note*: Use the [Application Intake
   Form](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=88c9c7bb137f1340196f7e276144b020)
   to request a new application to link the certificate to in the
   previous form
   * CA Provider: Digicert
   * Ticket Reference #: `<Ticket created in previous step>`
   * Make CA Selection Digicert
     - Press the `Add` button
     - Enter the DNS information (Canonical Name is required)
    *NOTE*: Make sure to attach the CSR for this request to the ticket before submitting.
1. The certificate will be attached as a zip file to the ticket once it is created. Optionally you can request that you want the certificate to be sent via email.
1. (Optionally) If the certificate is to be used for an OpenShift route, it should be added to vault along with the corresponding key. See documentation here: https://gitlab.cee.redhat.com/service/app-interface/#manage-routes-via-app-interface-openshiftnamespace-1yml-using-vault


1. The certificate will be attached to the ticket once it is created. Optionally you can request that you want the certificate to be sent via email.

