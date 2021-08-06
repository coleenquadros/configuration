App-cost-upload-lag-In-hccm
=============================

Severity: Warning
-----------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The HCCM OpenShift cluster upload queue is growing, if data is not processed within 48 hours it could be lost. An increasing processing queue also cretes lag on when customers can see data.

Summary
-------

This alert fires when the upload queue exceeds 100 for the last 10 minutes.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.
-  Repo access to koku (https://github.com/project-koku/koku)

Steps
-----

-  Log into the console / namespace and verify if listener pods are up / stuck / etc
-  Check oc logs for error messages with severity of ERROR
-  Check recent PR for changes made to the deployments
-  Check for blocking DB queries or slow queries that may need canceling
-  Scale up the deployment in order to handle the increase in uploads
-  Notify service owners if changes have occurred in the above

Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP

.. _Incident Response Doc: https://docs.google.com/document/d/1ztiNN7PiAsbr0GUSKjiLiS1_TGVpw7nd_OFWMskWD8w/edit?usp=sharing
