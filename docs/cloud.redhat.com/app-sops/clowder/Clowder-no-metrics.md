Clowder-no-metrics
==================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

[Incident Response Doc for console.redhat.com](https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE)

Impact
------

Clowder is unlikely to be running.  Therefore apps managed by Clowder will not
be updated while Clowder is down.  This should not cause an imminent outage
with any particular app, but updates to the environment will not be processed
by Clowder, potentially creating an outage.

Summary
-------

This alert fires when the Clowder pod(s) drop and/or prometheus cannot scrape metrics.
Usually caused caused by pods going offline or a prometheus problem.

Access required
---------------

- Console access to the cluster+namespace pods are running in.
- OLM access, thus dedicated-admin

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the `clowder` namespace
-  Check if there were any recent changes to the CR's in the namespace, in
   particular the `ClusterServiceVersion` or `Subscription` with the name `clowder`.

Escalations
-----------

Ping the DevProd team

