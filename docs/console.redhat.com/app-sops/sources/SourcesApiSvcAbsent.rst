SourcesApiSvcAbsent
===================

Severity: Critical
------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- Sources API is an APP used to store and check information about customer sources/accounts. It's primary used by other c.rh.c. services

Summary
-------

This alert fires when the Sources API svc pod(s) are down (prometheus cannot scrape metrics).
Usually caused caused by pods going offline or a prometheus problem.

Access required
---------------

- Console access to the cluster+namespace pods are running in

Steps
-----

- Log into the console / namespace (sources-prod) and verify if pods are up / stuck / etc
- Check logs / events for pods in the sources-prod namespace
-  Check if there were any recent changes to the CR's in the namespace
-  ``oc rsh`` into one of the containers if available

Escalations
-----------

- Ping more team members if available (`Workstreams`_ - Sources Workstream)
- Ping the engineering team that owns the APP (`Ansible Slack`_)

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Workstreams: https://source.redhat.com/groups/public/cloud-services-platform-cloudredhatcom/cloudredhatcom_wiki/insights_platform_workstreams
.. _CoreOS Slack: https://app.slack.com/client/T027F3GAJ/C0246P60U8H
