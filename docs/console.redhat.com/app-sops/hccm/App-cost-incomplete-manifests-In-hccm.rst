App-cost-incomplete-manifests-In-hccm
=======================================

Severity: Warning
-----------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The Cost Management APP process cost reports from public cloud providers. These reports can be large and made of numerous files. Completeing the processing of these files is what drives cost data into the application and makes it visible to customers.

Summary
-------

This alert fires when it is taking longer than 10 minutes to process a single file for a current cost report. Slow processing or a bug in processing could lead to an overall lag for all customer data processing.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to koku (https://github.com/project-koku/koku)

Steps
-----

-  Log into the console / namespace and verify if worker pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR
-  Check recent PR for changes made to the celery workers.
-  Scaling the workers should improve report processing throughput if its not a bug.
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
