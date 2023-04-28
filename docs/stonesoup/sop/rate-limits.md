# Dealing with rate limits

## Pre-requisites

* [Gain view access to RHTAP clusters](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/logs.md)
* [Gain access to view RHTAP logs](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/logs.md)
* [Gain access to Argo CD](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/fleet-manager-argocd.md)

## Indicators of Github rate limits

### Rate limit metrics

Check these metrics. Ideally they should all be at "0" but here you can see an example of some rate limiting:
```
primary_rate_limit_total{controller="Application",operation="DeleteRepository",tokenName="GITHUB_AUTH_TOKEN"} 6
primary_rate_limit_total{controller="Application",operation="GenerateNewRepository",tokenName="GITHUB_AUTH_TOKEN"} 15149
primary_rate_limit_total{controller="Component",operation="GetLatestCommitSHAFromRepository",tokenName="GITHUB_AUTH_TOKEN"} 6
primary_rate_limit_total{controller="SnapshotEnvironmentBinding",operation="GetLatestCommitSHAFromRepository",tokenName="GITHUB_AUTH_TOKEN"} 879
```

### Check the rate limits directly

* First, find the Github tokens.  If you have direct access to the [Vault](https://vault.devshift.net/ui/vault/secrets/stonesoup/list), the tokens are in the following paths:
  * https://vault.devshift.net/ui/vault/secrets/stonesoup/show/staging/has/github-token
  * https://vault.devshift.net/ui/vault/secrets/stonesoup/show/production/has/github-token
When there is only one token in the rotation, it's in this Vault folder as `token`. When a token pool is in use, the first token is stored in `token` and additional tokens are stored as a comma-separated list in `tokens`, as in: `token2:<token2>,token3:<token3>`.

* If you have oc access to the application-service namespace, you can also query the value like this on each affected member cluster: `oc get secret has-github-token -n application-service -o json | jq '.data | map_values(@base64d)'`

* Run a Github rate limit check against each token. This API call doesn't count against the rate limiting:
```
curl -L \                               
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <token>"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/rate_limit
```

If the token is rate-limited, you will see a match between the "limit" and "used" values, and/or a "remaining" count of 0, as in the example below. The "reset" field is the number of seconds before the rate limit will be removed automatically:
```
  "rate": {
    "limit": 60,
    "used": 60,
    "remaining": 0,
    "reset": 1682600320
  }
```

A token that's not in use will have a "used" value of 0.  A token that's in use but not rate-limited will have "used" and "remaining" counts that are both above 0:
```
  "rate": {
    "limit": 5000,
    "used": 4,
    "remaining": 4996,
    "reset": 1682691356
  }
```

### Primary rate limits

* Refer to: [RHTAP-601](https://issues.redhat.com/browse/RHTAP-601)
* Error in the logs: `Problem Creating the Application: %vtimed out when waiting for devfile content creation for application xyz-tenant-app in xyz-tenant namespace: timed out waiting for the condition` 

```
$ oc -n xyz-tenant get Application
NAME                      AGE   STATUS   REASON
xyz-tenant-app   13m   False    Error 

$ oc -n xyz-tenant describe Application/xyz-tenant-app
Name:         xyz-tenant-app
Namespace:    xyz-tenant
Labels:       <none>
Annotations:  finalizeCount: 0
API Version:  appstudio.redhat.com/v1alpha1
Kind:         Application
Metadata:
  [...]
Spec:
  App Model Repository:
    URL:         
  Display Name:  xyz-tenant-app
  Git Ops Repository:
    URL:  
Status:
  Conditions:
    Last Transition Time:  2023-02-17T13:27:33Z
    Message:               Application create failed: POST https://api.github.com/orgs/app-studio-test/repos: 403 You have exceeded a secondary rate limit and have been temporarily blocked from content creation. Please retry your request again later. []
    Reason:                Error
    Status:                False
    Type:                  Created
Events:                    <none> 
```

### Secondary rate limits cause E2E test failures

* Refer to: [RHTAP-812](https://issues.redhat.com/browse/RHTAP-812)
* Under load, when the secondary rate limits start to appear, the time needed to finish the application creation goes way beyond the 10 minutes used as a time-out in E2E tests.

### Canary performance test fails

* Frequent build timeouts reported on the [performance testing dashboard](http://kibana.intlab.perf-infra.lab.eng.rdu2.redhat.com/app/dashboards#/view/01508c40-d5e0-11ed-a972-8971ce66b77d)
* Refer to: [RHTAP-784](https://issues.redhat.com/browse/RHTAP-784)

### Github has banned an account

* When an account hits its rate limit too many times, Github will ban the token. This is evidenced by very low rate limits, for example this limit of 60 instead of 5000 requests: 
```
  "rate": {
    "limit": 60,
    "used": 60,
    "remaining": 0,
    "reset": 1682600320
  }
```

### Steps

* If the Github tokens have been changed recently, it's possible that the token in Vault isn't in use in the HAS pods yet.  To rule out this case, you can go to Argo CD, find the applications that start with "has", drill down to the affected pod(s) and click on the "Delete" button.  The pods will be re-created automatically.
* Waiting a few minutes for API traffic to ramp down might resolve the error, especially if it's only the primary or secondary rate limit.  This will not fix a banned token.
* Check for evidence of new bots or new tests (performance, pen-test, parallel E2E tests, etc.) causing too many API requests in a short period of time.
* The HAS team can create additonal Github tokens and add them to the token pool.  This can help by reducing the number of requests made by each token per time window.  They can also replace banned tokens.  Report this problem in Slack to [#forum-has-dev](https://redhat-internal.slack.com/archives/C02HZRGKDEY).
* If this occurs repeatedly, which we don't expect at this time, we will need to implement some new features following the Github recommendations for ["Dealing with secondary rate limits"](https://docs.github.com/en/rest/guides/best-practices-for-integrators?apiVersion=2022-11-28#dealing-with-secondary-rate-limits).
