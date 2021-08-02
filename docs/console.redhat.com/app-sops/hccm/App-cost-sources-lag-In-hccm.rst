App-cost-sources-lag-In-hccm
=============================

Severity: Warning
-----------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The HCCM Sources queue is growing, if events are not processed in a reasonable period of time source create, update, and deletes will not be handled, which could impact data processing for the source. 

Summary
-------

This alert fires when the sources event queue exceeds 800 for the last 10 minutes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to koku (https://github.com/project-koku/koku)

Steps
-----

-  Log into the console / namespace and verify if sources pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR
-  Check recent PR for changes made to the deployments
-  Check for blocking DB queries or slow queries that may need canceling
-  Scale up the deployment in order to handle the increase in events
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing

