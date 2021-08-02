App-cost-invalid-sources-In-hccm
=======================================

Severity: Warning
-----------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Sources are defined to allow Cost Management APP to obtain cost data from public cloud provider or expect data from customer OCP clusters.

Summary
-------

This alert fires when its found that a source is missing basic reference data like source ID, account, or cost management ID 

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to koku (https://github.com/project-koku/koku)

Steps
-----

-  Log into the console / namespace and verify if sources worker pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR
-  Check recent PR for changes made to the sources workers.
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
