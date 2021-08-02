App-cost-presto-insufficent-resources-In-hccm
=============================================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The HCCM presto worker requests have been failing due to insufficient resources the last 5 minutes. This could cause a lag in customer data processing if enough workers requests cannot complete.

Summary
-------

This alert fires when the HCCM presto worker requests fail due to insufficent resources in the past 5 minutes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to koku (https://github.com/project-koku/koku)

Steps
-----

-  Log into the console / namespace and verify if presto worker pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR
-  Check recent PR for changes made to the presto workers.
-  Increase the CPU or Memory Limit if its not a bug and redeploy.
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
