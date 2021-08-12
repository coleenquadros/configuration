App-koku-5xx-In-hccm
=======================================

Severity: High
--------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The Cost Management APP provide cost data around OpenShift clustes and public cloud infrastructure.

Summary
-------

This alert fires when the Cost Management API has returned a quantity of API responses with statuses
in the 500-599 range at or in excess of 10% of the total number of API responses in the 30 minutes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to koku (https://github.com/project-koku/koku)

Steps
-----

-  Log into the console / namespace and verify if API pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR
-  Check recent PR for changes made to the API.
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
