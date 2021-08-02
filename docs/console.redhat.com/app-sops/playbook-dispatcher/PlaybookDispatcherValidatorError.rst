PlaybookDispatcherValidatorError
==================================

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Customer playbook artifact uploads are not processed.


Summary
-------

Incoming playbook artifact uploads fail validation.
This may indicate a bug in insights-client/RHC code which produces invalid data.

Access required
---------------

- Grafana dashboard
- Kibana

Steps
-----

#. Examine the validator logs to identify the root cause of error (the correct URL is part of the alert)
#. Examine the dashboard to identify the trend of errors(s) (the correct URL is part of the alert)

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
