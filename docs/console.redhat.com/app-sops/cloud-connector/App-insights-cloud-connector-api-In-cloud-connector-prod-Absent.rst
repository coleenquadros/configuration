App-insights-cloud-connector-In-cloud-connector-prod-Absent
================================================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

-  Cloud-Connector is an application used to pass messages to on-premise Satellite instance to console.redhat.com.

Summary
-------

This alert fires when the Cloud-Connector pod(s) drop and/or prometheus cannot scrape metrics.
Usually caused caused by pods going offline or a prometheus problem.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

-  Log into the console / namespace and verify if pods are up / stuck / etc
-  Check logs / events for pods in the cloud-connector namespace
    - Check the logs for a "Failed to connect to MQTT broker" error message or an "Unable to connect to MQTT broker" error message
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the continers if available


Escalations
-----------

-  Ping more team members if available
-  Ping the engineering team that owns the APP
-  If cloud-connector is unable to connect to the MQTT broker,
   contact Akamai support as described here:  https://it-akamai.pages.corp.redhat.com/docs/support/

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
