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

The state of a statuspage component can be updated from a catchpoint monitoring probe as described in the [catchpoint docs](docs/app-sre/catchpoint.md). The process is not automated, since the catchpoint API lacks functionality to setup alerting.

There is currently no support to set a status page component from blackbox-exporter metrics.
