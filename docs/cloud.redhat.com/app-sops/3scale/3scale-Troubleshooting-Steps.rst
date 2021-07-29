3scale-troubleshooting-steps
========================================

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  The 3scale gateway is a major piece of the platform infrastructure and will cause outages if not available.

Summary
-------

We expect there to be very few 5xx returns and for most (99%+) requests to return in less than 2000ms.  If either of these criteria is not met, it is an indication that something is not operating correctly with the 3scale gateway.

Access required
---------------

-  Console access to the cluster and '3scale-prod|stage' namespace pods. 

Steps
-----

-  Log into the console & '3scale-prod|stage' namespace and verify if pods are up / stuck / etc
-  There are several 'apicast-*' pods in the 3scale namespace.  These are the pods that service 3scale requests.
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the continers if available

Escalations
-----------

-  Escalate to *@crc-rbac-escalations* on Slack.

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
