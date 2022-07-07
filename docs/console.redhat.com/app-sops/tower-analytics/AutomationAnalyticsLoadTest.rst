Load testing tower analytics
============================

Summary
-------

-  The linked document expands on the test plan defined below.
-  The complexity of the test environment and validation is probably best escalated to engineering @aa-api-team
   https://docs.google.com/document/d/1--VRoFmstA7tEgAr5m9LHpk6RlXiyVEiYXBOy0HE0io/edit#heading=h.2atp35jzs18x

Access required
---------------

-  Console access to the cluster & namespace pods are running in. 

Steps
-----

- create baseline in stage aaa, to do that create 3 months fake historical events and upload - expected 300M events
- Update cluster credentials in some GDoc for lsmola and make sure inventories are up2date in towerperf repo
https://github.com/ansible/towerperf/blob/master/conf/inventory-2020-10-07.ini
- To access through UI (admin/password)
- Contact @aa-api-team from towerperf-stage-user2 credentails
- Check all the exporters are running on both clusters and we can see reasonably correct dashboards for all the hosts
- Check AA tarballs are being uploaded correctly every 15 minutes (?) and Kibana dashboard is OK for the cluster
- Check jobs are being run on cluster in expected rate
- Create a script to compare AA and Tower data
- Create a script to extract jobs, their duration, events processing duration and events lag so we can have a dashboard from that


Escalations
-----------

- Ping the engineering team that owns the APP (`CoreOS Slack Forum-consoledot`_)
- - call `@aa-api-team`

-  Escalate to console.redhat.com engineering team per `Incident Response Doc`_

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE

