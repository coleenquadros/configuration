WorkerBuildErrors
=================

Impact
------

Worker build errors indicate image builds are failing, and the core feature of this service is in
bad shape.


Summary
-------

This alert fires when worker jobs are failing at a high rate.

Access required
---------------

The aws accounts the workers are running on:
- [production](/data/aws/image-builder-prod/account.yml)
- [stage](/data/aws/image-builder-stage/account.yml)

The [image-buidler-worker](https://grafana.app-sre.devshift.net/d/image-builder-worker) grafana
dashboard.

Steps
-----

- In the worker aws accounts, go to cloudwatch.
- The following query can be used to filter out worker messages:
```
fields message
| filter(_SYSTEMD_UNIT like "osbuild-remote-worker")
| parse message "time=* level=* msg=*" as time, level, innermsg
| display innermsg, level
| sort @timestamp desc
```
- Filtering by (error) level and host can be useful.
- If the instance is failing to subscribe, check [Red Hat status](https://status.redhat.com/) for
  Subscription Management outages.
- If the host/instance itself is in bad shape (out of disk space), simply terminate it. The scaling
  group will replace it.
- Ping the @image-builder-team in #osbuild-image-builder-service.

Escalations
-----------

[Escalation policy](data/teams/image-builder/escalation-policies/image-builder.yml).
