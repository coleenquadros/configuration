# Sentry SOP

Check [production pods](https://console-openshift-console.apps.app-sre-prod-01.i7w5.p1.openshiftapps.com/k8s/ns/sentry-production/pods)

## Connection error to redis pod

you see sth like:

```
raised unexpected: ConnectionError
```

--> Restart worker pods

## Worker OOM

Hard to spot because the pod doesnt crash, but internal threads are killed over and over again.

-> Increase memory
