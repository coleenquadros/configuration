# 1. Description

This SOP describes how to request a new (or the renewal of a) TLS certificate signed externally by DigiCert.

The IT Operations team is responsible for TLS certificates.

Their IRC channel at irc.devel.redhat.com is #iso (on-call can be pinged for urgent requests)

# 2. Process

1. Generate a CSR/KEY (if a new certificate is requested)

        ~ $ openssl req -new -newkey rsa:2048 -nodes -keyout FQDN.key -out FQDN.csr
        
        Country Name (2 letter code) [AU]: US
        State or Province Name (full name) [Some-State]: North Carolina
        Locality Name (eg, city) []: Raleigh
        Organization Name (eg, company) [Internet Widgits Pty Ltd]: Red Hat, Inc.
        Organizational Unit Name (eg, section) []: <NONE>
        Common Name (e.g. server FQDN or YOUR name) []: <FQDN>
        Email Address []: <NONE>
        
        Please enter the following 'extra' attributes
        to be sent with your certificate request
        A challenge password []: <NONE>
        An optional company name []: <NONE>
        

2. Open a ticket with IT Operations at https://redhat.service-now.com/help

        - New request
        - Information Technology
        - General Service Request
        - Subject: (New|Renew) DigiCert certificate for <FQDN> (*.<FQDN> if a wildcard is needed)
        - Attach CSR to the request if a new certificate is requested

3. The certificate will be attached to the ticket once it is created. Optionally you can request that you want the certificate to be sent via email.
4. (Optionally) If the certificate is to be used for an OpenShift route, it should be added to vault along with the corresponding key. See documentation here: https://gitlab.cee.redhat.com/service/app-interface/#manage-routes-via-app-interface-openshiftnamespace-1yml-using-vault
