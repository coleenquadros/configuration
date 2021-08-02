Kafka Free Storage Cricially Low
================================

Severity: Pagerduty
-------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

Kafka pods could start crashlooping, causing broker clients (i.e. topic
producers and consumers) to stop working, which means all ingress pipelines
halt.  This could result in data loss if the ingress webservice can not produce
messages for an extended period of time (it has a local cache of ingress
requests if Kafka goes down).

Summary
-------

The persistent volumes that back Kafka are almost out of space.  When this
alert is fired, Kafka is likely not in an outage *yet*, but an outage is likely
imminent.  At this point the only appropriate remedy is to increase the size of
the volumes by modifying the ``Kafka`` resource spec.  Reducing the storage
requirements can be considered in post-mortem discussions, but it is generally
not safe to modify topic settings without consulting dev teams and validating
them in stage.

Updating the volume size is a non-destructive operation and should cause no
disruption to Kafka service.

Access required
---------------

- View access to the ``platform-mq-prod`` namespace on crcp01ue1 cluster.
- Ability to approve/merge saas-deploy MRs for the strimzi app.
- View access to ``ClusterQuota`` resource type

Steps
-----

- Ensure there is enough storage quota on the cluster: ``oc describe clusterquota persistent-volume-quota``
- If there is not enough quota, escalate to App SRE to provision more storage quota.
- Open an MR to update the `strimzi saas-deploy file`_ increase volume size for
  Kafka.  Update the ``KAFKA_VOL_SIZE`` template parameter against the
  ``platform-mq-prod`` namespace.  `Permalink`_ to this specific line.
- If Kafka has already started crashlooping, updating the storage size should
  allow the pods to recover once they try to start again.  It's likely that the
  brokers that had crashed will take several minutes to reload all their data
  from disk before clients can reconnect.
- Check for other app-specific alerts to see if other apps need to be bounced
  to help them reconnect to Kafka.

.. _strimzi saas-deploy file: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/strimzi/saas.yml
.. _Permalink: https://gitlab.cee.redhat.com/service/app-interface/-/blob/0c5cd81aaf4d47ddc0e5332d025078928b39a524/data/services/insights/strimzi/saas.yml#L81

Escalations
-----------

-  Ping the App SRE on-call if storage qutoa is needed
-  Escalate the PagerDuty incident if Kafka has started crashlooping and you
   are having trouble getting the deployment to recover.
-  Further escalation is described in https://source.redhat.com/groups/public/sre-services/sre_services_wiki/escalating_kafka_strimzi_amq.

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
