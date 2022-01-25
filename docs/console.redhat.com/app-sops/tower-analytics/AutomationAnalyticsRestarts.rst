AutomationAnalyticsRestarts
===================

Severity: Info
------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- Ansible Automation Analytics ensures backend processing of Ansible Tower data
for UI in c.rh.c. in Ansible Automation Platform,
i.e. Job Explorer or Savings Planner

Summary
-------

- This alert fires when one of the Automation Analytics pod(s) are restarted
 more than 5 times in 30 minutes for the last 1 hour"
- Usually caused by pods crash, liveness probes problem or a prometheus problem.

Access required
---------------

- Prod: Console access to the `Prod cluster`_ (crcp01ue1) + namespace (tower-analytics-prod) pods are running in
- Stage: Console access to the `Stage cluster`_ (crcs02ue1) + namespace (tower-analytics-stage) pods are running in

Steps
-----

- Log into the console / namespace (tower-analytics-prod) and verify if:
  - Pods are up
  - Readiness Probe is working (in Events)
  - Liveness Probe is working (in Events), if available
  - Other errors/warning are present in the Events
- Check if all pods weren't deployed recently
  - If so, ask the `@aa-api-team` (see below) if there isn't something planned
- Check logs for pods in the tower-analytics-prod/stage namespace and `Kibana API Log`_ and `Kibana Non-API Log`_
- Check if there were any recent changes to the CR's in the namespace
- ``oc rsh`` into one of the containers if available

Escalations
-----------

- Ping more team members if available
- Ping the engineering team that owns the APP (`CoreOS Slack Forum-consoledot`_
- - call `@aa-api-team`

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Kibana API Log: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-24h,to:now))&_a=(columns:!(source_host,levelname,funcName,message,'@message'),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:levelname,negate:!t,params:(query:INFO),type:phrase),query:(match_phrase:(levelname:INFO)))),index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,interval:auto,query:(language:kuery,query:'@log_stream:*uvicorn.error*%20AND%20source_host:*fastapi*'),sort:!())
.. _Kibana Non-API Log: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-24h,to:now))&_a=(columns:!(source_host,levelname,tenant,message,exception),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!t,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:'@log_stream',negate:!f,params:(query:tower-analytics-prod),type:phrase),query:(match_phrase:('@log_stream':tower-analytics-prod))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:levelname,negate:!t,params:(query:INFO),type:phrase),query:(match_phrase:(levelname:INFO)))),index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,interval:auto,query:(language:kuery,query:'@log_stream:*analytics*'),sort:!())
.. _CoreOS Slack Forum-consoledot: https://app.slack.com/client/T027F3GAJ/C022YV4E0NA
