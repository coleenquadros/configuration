# e2e tests Job debugging

## Background

The app-interface e2e tests is executing the following test [scripts](https://github.com/app-sre/qontract-reconcile/tree/master/e2e_tests) as CronJobs in  [appsrep05ue1](https://console-openshift-console.apps.appsrep05ue1.zqxk.p1.openshiftapps.com/k8s/ns/app-interface-production/batch~v1~CronJob?name=e2e).

## Purpose

Provide guidance when troubleshooting under failure situation of the app-interface e2e tests CronJob.

## Steps

1. Login the cluster through command line 
2. Find the pod that's behind the job failed and gather its logs. For example:
```
$ oc get pods -n app-interface-production | grep e2e
e2e-tests-create-namespace-28048800-wkxr7                         0/1     Completed          0               7h9m
e2e-tests-dedicated-admin-rolebindings-28048800-c55b5             0/1     Error              0               7h5m
$ oc logs e2e-tests-dedicated-admin-rolebindings-28048800-c55b5 -n app-interface-production
[2023-05-01 08:04:30] [INFO] [gql.py:init_from_config:293] - using gql endpoint https://app-interface.stage.devshift.net/graphqlsha/252e5ad44b68a387826f1da5e41d66acad333d505d05bda6726ea11c6dfe22c1
[2023-05-01 08:05:32] [INFO] [dedicated_admin_rolebindings.py:test_cluster:15] - [ocmquayrop01uw2] validating RoleBindings
[2023-05-01 08:05:33] [INFO] [dedicated_admin_rolebindings.py:test_cluster:15] - [clairp01ue1] validating RoleBindings
[2023-05-01 08:05:33] [ERROR] [run-integration.py:main:179] - Error running e2e-tests
Traceback (most recent call last):
  File "/run-integration.py", line 169, in main
    command.invoke(ctx)
  File "/usr/local/lib/python3.9/site-packages/click/core.py", line 1657, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/usr/local/lib/python3.9/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/usr/local/lib/python3.9/site-packages/click/core.py", line 760, in invoke
    return __callback(*args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/click/decorators.py", line 26, in new_func
    return f(get_current_context(), *args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/e2e_tests/cli.py", line 69, in dedicated_admin_rolebindings
    run_test(e2e_tests.dedicated_admin_rolebindings.run, thread_pool_size)
  File "/usr/local/lib/python3.9/site-packages/e2e_tests/cli.py", line 20, in run_test
    func(*args)
  File "/usr/local/lib/python3.9/site-packages/reconcile/utils/defer.py", line 13, in func_wrapper
    return func(*args, defer=stack.callback, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/e2e_tests/dedicated_admin_rolebindings.py", line 38, in run
    threaded.run(
  File "/usr/local/lib/python3.9/site-packages/sretoolbox/utils/threaded.py", line 72, in run
    return pmap(func,
  File "/usr/local/lib/python3.9/site-packages/sretoolbox/utils/concurrent.py", line 87, in pmap
    return list(pool.map(func_partial, iterable))
  File "/usr/lib64/python3.9/concurrent/futures/_base.py", line 609, in result_iterator
    yield fs.pop().result()
  File "/usr/lib64/python3.9/concurrent/futures/_base.py", line 446, in result
    return self.__get_result()
  File "/usr/lib64/python3.9/concurrent/futures/_base.py", line 391, in __get_result
    raise self._exception
  File "/usr/lib64/python3.9/concurrent/futures/thread.py", line 58, in run
    result = self.fn(*self.args, **self.kwargs)
  File "/usr/local/lib/python3.9/site-packages/sretoolbox/utils/concurrent.py", line 113, in _full_traceback
    return func(*args, **kwargs)
  File "/usr/local/lib/python3.9/site-packages/e2e_tests/dedicated_admin_rolebindings.py", line 17, in test_cluster
    projects = [
  File "/usr/local/lib/python3.9/site-packages/e2e_tests/dedicated_admin_rolebindings.py", line 20, in <listcomp>
    if p["status"]["phase"] != "Terminating"
KeyError: 'status'
```
3. Correlate the logs to scripts mentioned above and find out what happened.


When following CronJob fails:

- `create-namespace` - the test could either not create a new namespace or the namespace was created without the correct `RoleBinding`s.
- `dedicated-admin-rolebindings` - the test could not find the correct `RoleBinding`s in a certain namespace(s).

This would usually mean that we should open a SNOW ticket to OpenShift SRE:
https://url.corp.redhat.com/OpenShift-SRE-Service-Request-Form

* `Request Type` - Incident/Outage
* `Customer Type` - v3 Dedicated Clusters (Internal and Partner customers)
* `Incident severity 1-4` - 1 - Urgent (as this may influence other clusters as well)
