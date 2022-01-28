# Enabling Temporary Roles in App-Interface

Tenants can include an `expirationDate` field within their role yaml file whenever they need access for debugging.
<br><br>

## How it Works

The [openshift rolebindings](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/openshift_rolebindings.py) and [openshift groups](https://github.com/app-sre/qontract-reconcile/blob/master/reconcile/openshift_groups.py) section of our [qontract-reconcile](https://github.com/app-sre/qontract-reconcile) integration will pick up on the change through [app-interface](https://gitlab.cee.redhat.com/service/app-interface) and a check will run to see if the date is valid. The date specified in the `expirationDate` field must be in `YYYY-MM-DD` format and it must not be older than today's date. If the value for the field is not correct, the integration will fail alerting you about the date format and if the `expirationDate` value has past today's date then the access will be removed.
<br><br>

## Example on how it will look in a role file.

Schema can be found [here](https://github.com/app-sre/qontract-schemas/blob/main/schemas/access/permission-1.yml).

```
---
$schema: /access/role-1.yml

labels: {}
name: prod-debugger

expirationDate: '2023-02-01'

permissions: []

access:
- cluster:
    $ref: /openshift/telemeter-prod-01/cluster.yml
  group: observatorium-dev
```
