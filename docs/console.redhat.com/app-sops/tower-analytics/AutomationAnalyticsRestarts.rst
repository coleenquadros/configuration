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

- Log into the console / namespace (tower-analytics-prod).  You can see events for all running pods at `Prod Events Console`_
  
- Determine all the below are true: 
  - Pods are up
    - You can observe the status of the pods at the `Prod Deployments Console`_
    - In the Status column, you should see 20 of 20, 8 of 8, etc. for each service
  - Readiness Probe is working (in Events)
    - If this is not working, it usually means that pod wasn't able to complete some initialization phase.  Check logs and events to investigate. Also check external dependencies are available, like kafka/database
  - Liveness Probe is working (in Events), if available
    - If you see a "Liveness probe failed" event, you can verify that the probe has been resolved by clicking the "Log" tab for the pod that was failing and see if the logs indicate the pod is behaving normally.
  - Check all pods were deployed when expected
    - You should see a "CA" event with the message "Clowdapp reconciled" when Clowder succesfully deploys the pods, if you don't, ask the `@aa-api-team` (see below) if there isn't something planned

- If everything looks good at the above, you can check the following:
  - Check logs for pods in the tower-analytics-prod/stage namespace for an indication something is behaving strangely at `Prod Deployments Console`_
  - Check `Kibana API Log`_ and `Kibana Non-API Log`_
  - TODO: explain what "Check if there were any recent changes to the CR's in the namespace" means
  - ``oc rsh`` into one of the containers to determine it can be reached, if available

Escalations
-----------

- Ping more team members if available
- Ping the engineering team that owns the APP (`CoreOS Slack Forum-consoledot`_
- - call `@aa-api-team`

.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Kibana API Log: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-24h,to:now))&_a=(columns:!(source_host,levelname,funcName,message,'@message'),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:levelname,negate:!t,params:(query:INFO),type:phrase),query:(match_phrase:(levelname:INFO)))),index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,interval:auto,query:(language:kuery,query:'@log_stream:*uvicorn.error*%20AND%20source_host:*fastapi*'),sort:!())
.. _Kibana Non-API Log: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-24h,to:now))&_a=(columns:!(source_host,levelname,tenant,message,exception),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!t,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:'@log_stream',negate:!f,params:(query:tower-analytics-prod),type:phrase),query:(match_phrase:('@log_stream':tower-analytics-prod))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:levelname,negate:!t,params:(query:INFO),type:phrase),query:(match_phrase:(levelname:INFO)))),index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,interval:auto,query:(language:kuery,query:'@log_stream:*analytics*'),sort:!())
.. _CoreOS Slack Forum-consoledot: https://app.slack.com/client/T027F3GAJ/C022YV4E0NA
.. _Prod Deployments Console: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/tower-analytics-prod/deployments
.. _Prod Events Console: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/tower-analytics-prod/events
