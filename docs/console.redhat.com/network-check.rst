HttpFailuresAlert/GetentFailuresAlert
=====================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- This alert fires when the `network-check script`_ fails to make a successful request for 5 minutes
- If these checks fail, it indicates that inter-namespace network communication may have gone down,
  or that connectivity from our cluster to RDS has gone down.

Summary
-------

The network-check script is a simple python app deployed into the console.redhat.com stage/production
clusters that runs the following every 5 seconds:

1. a test HTTP call to `HTTP_URL` using the requests library
2. a test `getent hosts` call for host `GETENT_HOST` using a shell subprocess

The values of `HTTP_URL` and `GETENT_HOST` are defined in the `network-check saas file`_. The
HTTP_URL is an internal `.namespace.svc` URL for the entitlements service running in the cluster and
the test host is an external RDS database hostname.


Access required
---------------

- Access to the production `Grafana`_ in order to view the Network Check dashboard
- Access to the `production Openshift cluster`_ to check pod connectivity.
- Access to the `Kibana instance`_ in order to review logs to see if there are
  any problems causing the failures

Steps
-----

- Ensure that the deployment/service related to `HTTP_URL` is up in the cluster and that the
  network policies set on the namespaces would allow network-check to reach the target HTTP_URL
- Ensure that the RDS database used for `GETENT_HOST` is up
- If the above are true, there is a connectivity issue between the `network-check` namespace and
  these resources that needs to be investigated. Most likely this will be an OSD issue.

Escalations
-----------

- Ping @sre-platform-primary or @sre-platform-secondary in #sd-sre-platform on CoreOS Slack


.. _network-check script: https://github.com/RedHatInsights/network-check/blob/master/app.py
.. _network-check saas file: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/network-check/deploy.yml#L36-48
.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
