# 1. Description

**Important:** In most cases, we want to use LetsEncrypt certificates to secure service endpoints. For that we use openshift-acme as documented [here](https://gitlab.cee.redhat.com/service/app-interface/#manage-openshift-acme-deployments-via-app-interface-openshiftacme-1yml)

This SOP describes how to request a new (or the renewal of a) TLS certificate signed externally by DigiCert.

The IT Operations team is responsible for TLS certificates.

Their IRC channel at irc.devel.redhat.com is #iso (on-call can be pinged for urgent requests)

Their Google Chat room is `IT Utility & Infra Services (UIS)`

# 2. Process

Before starting, if the application wasn't registered in CMDB, use the
[Application Intake
Form](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=88c9c7bb137f1340196f7e276144b020)
and wait until the registration completes.

1. Generate a CSR/KEY (if a new certificate is requested).  Please note, the process is different if the server/route supports TLS 1.3.
   * For TLS v1.2, as we currently have in ci.int and ci.ext:
    ```shell
    COMMON_NAME=mydomain.com
    # ESSv9 requires secp384r1 curve for TLSv1.2
    openssl req -new -newkey ec:<(openssl ecparam -name secp384r1) -nodes \
     -out cert_req_name.csr \
     -keyout cert_req_name.key \
     -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Service Delivery/CN=$COMMON_NAME"
    ```
   * For TLS v1.3 (as in Openshift routes), we [must use ED25519](https://source.redhat.com/departments/it/it-information-security/wiki/data_encryption__secure_key_management_guidelines) and the CSR generation takes two steps:
    ```shell
    COMMON_NAME=mydomain.com
    openssl genpkey -algorithm ed25519 -out cert_req_name.key
    openssl -new -nodes -out cert_req_name.csr -key cert_req_name.key |
     -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat, Inc./OU=Service Delivery/CN=$COMMON_NAME"
    ```
2. Open a General IT SNOW [ticket](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=630e51c22bb23c004c71dc0e59da15bb&sc_catalog=1a98389b4fa25b40220104c85210c7d4&sysparm_category=null)
2. Open a ticket with IT Operations using the [certificate request form](https://redhat.service-now.com/help?id=sc_cat_item&sys_id=e5fc3a19db0898149693cf5e13961975)
   Provide the following details:
   * CA Provider: Digicert
   * Ticket Reference #: `<Ticket created in previous step>`
   * Make CA Selection Digicert
     * Press the `Add` button
     * Enter the DNS information (Canonical Name is required)
  *NOTE*: Make sure to attach the CSR for this request to the ticket before submitting.
2. There will be one or two exchanges to the ticket, requesting you to
   create TXT records with challenge values in the appropriate
   zones. As always, app-interface  is [the way](/docs/aws/aws-route53.md).
2. The certificate will be attached to the ticket once it is created. Optionally you can request that you want the certificate to be sent via email.
2. (Optionally) If the certificate is to be used for an OpenShift route, it should be added to vault along with the corresponding key. See documentation here: https://gitlab.cee.redhat.com/service/app-interface/#manage-routes-via-app-interface-openshiftnamespace-1yml-using-vault
