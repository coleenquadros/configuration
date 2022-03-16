App-quickstarts-In-quickstarts-prod-Absent.rst
===============================================

Severity: Pagerduty
-------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- The quickstarts API is used to store console.redhat.com user tutorial progress.
- The API is unreachable. User tutorial progress will not be stored. User experience may be degraded.

Summary
-------

Note: This service is deployed via `Clowder`_

This alert fires when the API pod(s) drop and/or Prometheus is unable to collect metrics.
This is usually caused by pods going offline or a Prometheus problem.

Access required
---------------

- Console access to the cluster and namespace in which pods are running

Steps
-----
- Log in to the console, open "quickstarts-prod" namespace and verify if all pods are running and receiving requests.
- Check logs/events for Quickstarts pods.
- Check if any deployments or changes in the application happened closer to the time the requests started to return errors.
- Check infrastructure metrics on the OpenShift console for quickstarts service (Deployments -> quickstarts-service -> Metrics) and take notes.
- Escalate the alert with all the information available to the engineering team that is responsible for the app.


Escalations
-----------

-  Ping development team using @crc-experience-team group in CoreOS Slack

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE

.. _Clowder: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst



