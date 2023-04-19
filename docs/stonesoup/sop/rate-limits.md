# Dealing with rate limits

## Pre-requisites

* [Gain view access to RHTAP clusters](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/logs.md)
* [Gain access to view RHTAP logs](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/logs.md)

## Indicators of Github rate limits

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

### Steps

* Waiting a few minutes for API traffic to ramp down might resolve the error.
* Check for evidence of new bots causing too many API requests.
* The HAS team can create additonal Github tokens and add them to the rotation.
* If this occurs repeatedly, which we don't expect at this time, we will need to implement some new features following the Github recommendations for ["Dealing with secondary rate limits"](https://docs.github.com/en/rest/guides/best-practices-for-integrators?apiVersion=2022-11-28#dealing-with-secondary-rate-limits).
