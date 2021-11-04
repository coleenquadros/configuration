AutomationAnalyticsProcessorServiceAbsent
===================

Severity: High
------------------

Incident Response Plan
----------------------

`Incident Response Doc`_ for console.redhat.com

Impact
------

- Customer data sent from Ansible Towers through Ingress service (S3 bucket) won't be processed.
- Data are available for 2 days

Summary
-------

- This alert fires when the Automation Analytics Processor pod(s) are down (prometheus cannot scrape metrics).
- Usually caused by pods going offline or a prometheus problem.

Access required
---------------

- Console access to the cluster (crcp01ue1) + namespace (tower-analytics-prod) pods are running in

Steps
-----

- Log into the console / namespace (tower-analytics-prod) and verify if:
  - Pods are up
  - Readiness Probe is working (in Events)
  - Other errors/warning are present in the Events
- Check logs for pods in the tower-analytics-prod namespace and `Kibana Log`_
- Check if there were any recent changes to the CR's in the namespace
- ``oc rsh`` into one of the containers if available

Escalations
-----------

- Ping more team members if available
- Ping the engineering team that owns the APP (`CoreOS Slack Forum-consoledot`_
- - call `@aa-api-team`

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Kibana Log: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-24h,to:now))&_a=(columns:!(source_host,levelname,tenant,message,exception),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!t,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:'@log_stream',negate:!f,params:(query:tower-analytics-prod),type:phrase),query:(match_phrase:('@log_stream':tower-analytics-prod))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:levelname,negate:!t,params:(query:INFO),type:phrase),query:(match_phrase:(levelname:INFO))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:source_host,negate:!f,params:(query:automation-analytics-processor),type:phrase),query:(match_phrase:(source_host:automation-analytics-processor)))),index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',interval:auto,query:(language:kuery,query:'@log_stream:*analytics*'),sort:!())
.. _CoreOS Slack Forum-consoledot: https://app.slack.com/client/T027F3GAJ/C022YV4E0NA
