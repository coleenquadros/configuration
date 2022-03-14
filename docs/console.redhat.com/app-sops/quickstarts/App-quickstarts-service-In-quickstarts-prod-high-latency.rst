App-quickstarts-service-In-quickstarts-prod-high-latency
=========================================================

Severity: Pagerduty
-------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- Quickstarts service provides persistent storage for guided user tours in console.redha.com.
- If the latency is high, there might be an impact on the latency SLO, and user experience might be degraded.

Summary
-------

Note: This service is deployed via `Clowder`_

This alert fires when more than 10% of the API responses have latency greater than 2000ms

Access required
---------------

- Console access to the cluster and namespace in which pods are running

Steps
-----
- Log in to the console, open "quickstarts-prod" namespace and verify if all pods are running and receiving requests.
- Check logs/events for Quickstarts pods.
- Check if any deployments or changes in the application happened closer to the time the requests started to return errors.
- Check infrastructure metrics on the OpenShift console for quickstarts service (Deployments -> quickstarts-service -> Metrics) and take notes.
- Escalate the alert with all the information available to the engineering team responsible for the app.

Escalations
-----------

-  Ping development team using @crc-experience-team group in CoreOS Slack

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE

.. _Clowder: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst



