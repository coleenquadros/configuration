# Red Hat status pages

https://status.redhat.com/
https://status.quay.io/

IT documentation: https://docs.engineering.redhat.com/display/Communities/Availability+Monitoring+Information+Page

## Login to statuspage

Updates to statuspage should be made with app-interface `dependencies/status-page-component-1.yml` (see below) wherever possible, but if you need to login directly see the link below:

https://manage.statuspage.io

Credentials: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/status.redhat.com

## Manage statuspage status with app-interface

Please refer to https://service.pages.redhat.com/dev-guidelines/docs/appsre/advanced/statuspage/#status-management

Please note, that the status page feature in app-interface does not support statuspage.io incident management right now.

## Automate status changes with monitoring probes

Work is in progress to automate the state on statuspage based on Catchpoint and blackbox-exporter monitoring probes.

https://issues.redhat.com/browse/APPSRE-3905
https://issues.redhat.com/browse/APPSRE-4161

Until then, instructions to set this up manually can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/catchpoint.md)
