SourcesApi5xxErrors
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

This alert may fire when there is an uncaught bug in the Sources API codebase, there is an issue with api's dependency services - e.g. RBAC/Kafka

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----
- Make sure that RBAC and Kafka are operating as expected.
    - If not, then fixing the issue in those service will most likely resolve this alert.
- Make sure that Sources RDS Database is working as expected.
    - If not, then fixing the issue in AWS will most likely resolve this alert.
- Check logs / events for pods in the sources-prod namespace (``cwl-sources-*`` index pattern in the Kibana)
    - If you see quota events, try scaling down the number of pods temporarily.
    -  If this is not possible or not working, reach out to AppSRE to make an immediate increase to the quota in the namespace. For a long-term quota change that takes longer to make, make an MR that modifies the host-inventory-quota.yml file.
-  Check to see if there were any recent deployments.
    -  If there was a deploy recently, a deployment rollback should be safe and get things running again until the team can be pinged. To do this, create an MR in app-interface that reverts the change to sources' deploy.yml/deploy-clowder.yml file.
    -  If you see any AWS-related connectivity issues, see if any password was changed in the configuration recently. If it was caused by config, revert that change; otherwise, reach out to AppSRE to see why the values aren't being set correctly.
-  In the event that a pod is not operating correctly, you can safely delete it, and the replica controller will create a new one.

Escalations
-----------

- Ping more team members if available (`Workstreams`_ - Sources Workstream)
- Ping the engineering team that owns the APP (`Ansible Slack`_)

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Workstreams: https://source.redhat.com/groups/public/cloud-services-platform-cloudredhatcom/cloudredhatcom_wiki/insights_platform_workstreams
.. _CoreOS Slack: https://app.slack.com/client/T027F3GAJ/C0246P60U8H
