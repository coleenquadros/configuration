# Base Functionality SOP

Use these credentials to issue GET queries to the API https://vault.devshift.net/ui/vault/secrets/app-sre/show/dashdot/auth-proxy-production

The following URLs should return prometheus metrics:

https://dashdotdb.devshift.net/api/v1/imagemanifestvuln/metrics
https://dashdotdb.devshift.net/api/v1/deploymentvalidation/metrics
https://dashdotdb.devshift.net/api/v1/serviceslometrics/metrics

Further, we should be able to narrow down queries, like:

https://dashdotdb.devshift.net/api/v1/imagemanifestvuln?cluster=app-sre-prod-01&namespace=sentry-production
