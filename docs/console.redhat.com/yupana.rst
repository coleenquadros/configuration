Yupana
======

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Summary
-------

Yupana is a kafka consumer that processes QPC archives.  This archive contains
a bundle of host information, generating updates for multiple (possibly
hundreds or thousands) of hosts.

Yupana will halt itself until it is manually restarted (via a pod deletion and
recreation) when it encounters a DB error or Kafka error.  These will be
detected via metrics and alerted upon.

Impact
------

It is a dependency of receptor gateway and thus the whole FiFi (find-it-fix-it)
feature.

Access required
---------------

Edit access to ``subscriptions-stage`` and/or ``subscriptions-prod``.

Steps
-----

- Review `Kafka troubleshooting doc`_ for steps to gather information from
  Kafka
- Delete the pod and let it respawn
