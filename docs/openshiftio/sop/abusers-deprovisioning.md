# OSIO abusers deprovisioning

## Purpose

This is an SOP for deprovisioning OSIO abusers' accounts.
Instead of direct DB manipulation we are calling OSO API.

## Content

Basically deprovisionig is done by issuing this command:
```
curl -X PUT -H 'Content-Type: application/json' -d '{"is_banned":"true"}' https://manage.openshift.com/api/accounts/${1}/ban?authorization_username=openshiftio-api-client -H 'Authorization: Bearer VERY_SECRET_DUMMY' >>ban.log
```

## Obtaining needed info

We need to use abuser's *username*. While in some cases it's same to *namespace* generally it might be different from *namespace* or user's *email*. Need to be very accurate, in case of errors we might deprovision wrong user.

To get *username* we need to directly query DB. As it's only reading it acceptable to use direct DB query but we want to switch to use spme other (REST) API call in the future.
DB host and credentials can be found in vault: `https://vault.devshift.net/ui/vault/secrets/app-interface/show/dsaas/dsaas-production/f8tenant`
```
"SELECT t.os_username FROM tenants t, namespaces n WHERE t.id = n.tenant_id AND n.name in (${query});"
```
there `${query}` is comma separated list of abusers' namespaces.

Because of VPC restrictions You need to run it from DSaaS-stg OS cluster, like from `diag-container` in `devtools-sre-tools` namespace.

Token for OSO management API can be found in vault: `https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/oso-management-api`

## Checking if namespaces are deleted

Sometime namespaces aren't deleted after API call. Generally we want to idlers do their job and stop workspaces. For special cases we want to scale down abusers' PODs immediately.

In any cases we need to check if abusers' namespeces deleted in 10 or 15 minutes after calling deprovisioning API. Check if pods still running for corresponding OSIO cluster, you need to have tiered access to that cluster:
```
oc get pod --all-namespaces -owide | grep -i ${namespace}
```

In case PODs still running check again after some time or scale them down (and recheck again after some time).
