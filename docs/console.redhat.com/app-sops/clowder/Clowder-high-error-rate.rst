Clowder-high-error-rate
=======================

Impact
------

Potentially be blocking app teams from testing or deploying their app in their
target environment.

Summary
-------

More than 50% of reconciliations have resulted in failure for at least ten
minutes.

Access required
---------------

- Console access to the cluster+namespace pods are running in.
- OLM access, thus dedicated-admin

Steps
-----

- Log into the console / namespace and verify if pods are up / stuck / etc
- Check logs / events for pods in the `clowder-system` namespace
- Analyze errors in clowder-controller-manager pod logs.  Try to determine if
  root cause is user error or clowder bug.

Escalations
-----------

Ping the DevProd team
