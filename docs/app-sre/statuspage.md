# Red Hat status page

https://status.redhat.com/

IT documentation: https://docs.engineering.redhat.com/display/Communities/Availability+Monitoring+Information+Page

## Login to statuspage

https://statuspage.io

Credentials: https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/status.redhat.com

# New Relic tests

NR tests allow us to automatically display incidents in the status page by configuring periodic checks on the services we run.

## Login to New Relic

Direct login page:
https://synthetics.newrelic.com/accounts/2409290/monitors

Ensure your account is part of the `RH Cloud Platform Prod` account.

JF and Jaime currently have admin on the project so access can be requested through them.

## Adding a Monitor

### Types

- Ping (free)
- Simple Browser
- Scripter Browser
- API Test

### Locations

- Select only 3 locations, all in NA (close to the origin)
- schedule is 5 mins or larger

### Alert configuration

Make sure alerts are only triggered if more than one geographical region fails. In order to do so:
Synthethics -> multiple location -> threshold: 2

### Budget concerns

After setting up each alert, make sure the amount of monthly checks it will take up is reasonable. If we ever exhaust these checks we should start a conversation with Vikas Kumar in IT ISO to contribute funds to the New Relic account.

## PagerDuty Integration

In PD:

- Need a new PD "service" per service
- +New Integration -> New Relic -> Name (prepend with AppSRE) + PD key

In NR:

- Alerts -> Notification channels
- New notification channel -> Name + PD key
- Alert Policy -> Add notification channel

## API

As admin you can create a new key:

- push scripts?
- consume /violations -> prom exporter?

# StatusPage <-> New Relic controller

This component connects a New Relic synthetic test with a statuspage component. No accounts are required, the connection is made using a naming convention between the statuspage and New Relic.

https://github.com/redhataccess/statuspage-controller

You need to request an account from Jared Sprague <jsprague@redhat.com> to access it.
