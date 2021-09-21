App-job-failures-In-hccm
=============================

Severity: Warning
-----------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The HCCM jobs are failing which could impact data compaction, demo data generation, application usage metrics, or internal email reporting depending on the job failing.

Summary
-------

This alert fires when jobs failures occur in the last hour.

Access required
---------------

-  Console access to the cluster+namespace jobs are running in.
-  Repo access to koku (https://github.com/project-koku/koku)

Steps
-----

-  Log into the console / namespace and verify if jobs are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR
-  Check recent PR for changes made to the jobs
-  Check events for resource limits being hit and if so redeploy with increased limits
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
