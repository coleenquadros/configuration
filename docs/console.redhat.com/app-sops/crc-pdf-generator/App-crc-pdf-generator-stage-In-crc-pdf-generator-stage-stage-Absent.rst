App-crc-pdf-generator-stage-In-crc-pdf-generator-stage-stage-Absent.rst
===============================================

Severity: Pagerduty
-------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- The crc PDF generator is used to generate PDF reports for console.redhat.com services.
- The service is unreachable. A user won't be able to generate and download PDF reports.

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
- Log in to the console, open "crc-pdf-generator-stage" namespace and verify if all pods are running and receiving requests.
- Check logs/events for the generator pods.
- Check if any deployments or changes in the application happened closer to the time the requests started to return errors.
- Check infrastructure metrics on the OpenShift console for the generator service (Deployments -> crc-pdf-generator-api -> Metrics) and take notes.
- Escalate the alert with all the information available to the engineering team that is responsible for the app.


Escalations
-----------

-  Ping development team using @crc-experience-team group in CoreOS Slack

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE

.. _Clowder: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/console.redhat.com/app-sops/clowder/clowder.rst



