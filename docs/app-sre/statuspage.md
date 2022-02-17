# Red Hat status pages

https://status.redhat.com/
https://status.quay.io/

IT documentation: https://docs.engineering.redhat.com/display/Communities/Availability+Monitoring+Information+Page

## Login to statuspage

Updates to statuspage should be made with qontract-cli (see below) wherever possible, but if you need to login directly see the link below:

https://manage.statuspage.io

Credentials: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/status.redhat.com

## Manage statuspage status with qontract-cli

First list all statuspage components managed with app-interface.

```
qontract-cli get statuspage-components

COMPONENT_NAME             COMPONENT_DISPLAY_NAME                      PAGE
-------------------------  ------------------------------------------  -----------------
cincinnati                 OpenShift Update Service                    status-redhat-com
clair                      Security Scanning                           status-quay-io
insights-advisor           Insights - Advisor                          status-redhat-com
insights-compliance        Insights - Compliance                       status-redhat-com
insights-drift             Insights - Drift                            status-redhat-com
insights-patch             Insights - Patch                            status-redhat-com
...
```

Pick the name of the component you want to change the status of and run

```
qontract-cli set statuspage-component-status $COMPONENT_NAME $STATUS
```

Supported values for `$STATUS` are `operational`, `under_maintenance`, `degraded_performance`, `partial_outage`, `major_outage`

Please note, that qontract-cli does not support statuspage.io incident features right now.

## Automate status changes with monitoring probes

Work is in progress to automate the state on statuspage based on Catchpoint and blackbox-exporter monitoring probes.

https://issues.redhat.com/browse/APPSRE-3905
https://issues.redhat.com/browse/APPSRE-4161

Until then, instructions to set this up manually can be found [here](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/catchpoint.md)
