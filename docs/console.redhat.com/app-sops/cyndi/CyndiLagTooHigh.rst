CyndiLagTooHigh
===============

Severity: Info
--------------

Incident Response Plan
----------------------

`Incident Response Doc <https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE>`_ for console.redhat.com

Impact
------

Cyndi kafka consumer lag is above the given SLO threshold.
As a result, applications are working with stale host data and may present incorrect information to the customers.


Summary
-------

Cyndi kafka consumers are lagging behind the HBI event interface.

Access required
---------------

-  Console access to the cluster+namespace pods are running in.

Steps
-----

Using `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/cyndi?orgId=1&refresh=1m>`_ determine if this is caused by a sudden spike in traffic or whether lag keeps growing.
If the latter then:

- Log into the console / namespace
- Check the pipeline events for any indication of a problem :code:`oc describe cyndi <pipeline name>`

Tools
-----

- `Grafana dashboard <https://grafana.app-sre.devshift.net/d/fF9U-h7Mk/cyndi?orgId=1&refresh=1m>`_

Escalations
-----------

-  Ping `platform-pipeline-dev <https://app.slack.com/client/T026NJJ6Z/CA0SL3420/user_groups/S01AWRG3UH1>`_
