# Temporary pod exec access
To temporarily grant exec access to pods in a namespace for a user, you'll need to create a role if it doesn't exist and then add a user to that role.

## role yaml
```
apiVersion: v1
kind: Role
metadata:
  name: exec-role
rules:
- apiGroups:
  - ""
  attributeRestrictions: null
  resources:
  - pods/exec
  verbs:
  - create
```

## create role
> oc -n foons create -f foorolename.yaml

## apply role to user
> oc adm policy add-role-to-user foorolename foouser --role-namespace=foons -n foons


## example
```
# on app-sre-stage-01 cluster
oc -n uhc-integration create -f exec-role.yaml
oc adm policy add-role-to-user exec-role jhernand --role-namespace=uhc-integration -n uhc-integration
```

