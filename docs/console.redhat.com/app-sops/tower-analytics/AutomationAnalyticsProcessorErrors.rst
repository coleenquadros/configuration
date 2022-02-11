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

- This alert fires when the Automation Analytics Processor pod(s) are unable to process payloads (Tower data)

Access required
---------------

- Prod: Console access to the `Prod cluster`_ (crcp01ue1) + namespace (tower-analytics-prod) pods are running in
- Stage: Console access to the `Stage cluster`_ (crcs02ue1) + namespace (tower-analytics-stage) pods are running in

Steps
-----

- Log into the console / namespace (`OpenShift/tower-analytics-prod`_) and verify if:
  - Pods are up
  - Readiness Probe is working (in Events)
  - Other errors/warning are present in the Events
- Check logs for pods in the tower-analytics-prod namespace and `Kibana Log`_
- Check if there were any recent changes to the CR's in the namespace
- ``oc rsh`` into one of the containers if available

Additional steps (developers)
-----------------------------
- Check logs in `Kibana Error Dashboard`_
- There are several kind of issues:
- - Bad tarballs - archive is corrupted - can be ignored (shoudn't invoke this alert)
- - There is a problem with connection to S3 (Ingress bucket)
- - Collected data are not compatible with processor.
- - - In that case, check the version of Tower(Collector), it's either bug or new version
- Look to the Prometheus (Button 'Query')
- Check `Grafana`_ (Button 'Dashboard') - mainly Status, Processor* and RDS Database panels
- Compare
- - deployed commit SHA (Button 'Link' - detail of deployment/pod)
- - expected commit SHA (`app-interface`_)
- - if there is fix in GitLab, but can't be auto-promoted (`AA Backend's Gitlab`_)
- In case there has to be implementation change (or any other non-immediate change), create a ticket (Bug/Task) in `Jira`_

Getting Payloads from S3 (Developers)
#####################################
If there is an error with parsing/saving in `Kibana Error Dashboard`_, payloads can be accessed from Ingress S3
They are available for 24 or 48 hours only.

- From the dashboard, get "Time", "source_host" and "tenant" values
- In the `Kibana log`_ find logs around the "Time" for the "tenant" and "source_host"
- Find an INFO message with message "[Processor] Processing starts" before error message
- Copy the "request_id" value

Now we have the Request ID, now we need the URL from it:

- Create a SQL query file based on `Messages SQL`_ (you can ask in `CoreOS Slack sd-app-sre`_ for review/approval)
- Replace the tenant_id in your query with "tenant" value from log
- After merge, look at `Prod Jobs`_'s UI, wait for Job named like your SQL query file
- Save it's log as a CSV file
- Open the CSV file and find "request_id".
- The same row contains URL to the S3

TODO: There should be the same Request ID in AA S3 Recovery bucket, but the URL is not saved in db,
but the data are there present for 90 days.

Escalations
-----------

- Ping more team members if available
- In case of S3 problems, ping `@app-sre-ic` team in `CoreOS Slack sd-app-sre`_
- Ping the engineering team that owns the APP (`CoreOS Slack Forum-consoledot`_)
- - call `@aa-api-team`

.. _AA Backend's Gitlab: https://gitlab.cee.redhat.com/automation-analytics/automation-analytics-backend/-/commits/main.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _app-interface: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/insights/tower-analytics/deploy-clowder.yml
.. _CoreOS Slack Forum-consoledot: https://app.slack.com/client/T027F3GAJ/C022YV4E0NA
.. _CoreOS Slack sd-app-sre: https://app.slack.com/client/T027F3GAJ/CCRND57FW
.. _Grafana: https://grafana.app-sre.devshift.net/d/81Du_aIHdf/automation-analytics?orgId=1&refresh=15m&var-Datasource=crcp01ue1-prometheus&var-DatasourceRDS=app-sre-prod-01-prometheus&var-namespace=tower-analytics-prod&var-granularity=daily&var-granularity=monthly&var-granularity=yearly&var-realtime_rollup_series=ta_rollup_processor_rollup_event_explorer_rollup_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_host_event_explorer_rollup_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_host_explorer_rollup_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_job_explorer_rollup_failed_steps_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_job_explorer_rollup_jobs_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_job_explorer_rollup_workflow_hierarchy_time_bucket&var-realtime_rollup_series=ta_rollup_processor_rollup_job_explorer_rollup_workflows_time_bucket&var-granularity_rollups=job_explorer&var-granularity_rollups=event_explorer&var-granularity_rollups=host_explorer&var-processor_tables=analytics_bundle&var-processor_tables=events_table&var-processor_tables=unified_jobs
.. _Incident Response Doc: https://docs.google.com/document/d/1AyEQnL4B11w7zXwum8Boty2IipMIxoFw1ri1UZB6xJE
.. _Jira: https://issues.redhat.com/browse/AA
.. _Kibana Log: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-24h,to:now))&_a=(columns:!(source_host,levelname,funcName,message,'@message'),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'43c5fed0-d5ce-11ea-b58c-a7c95afd7a5d',key:levelname,negate:!t,params:(query:INFO),type:phrase),query:(match_phrase:(levelname:INFO)))),index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,interval:auto,query:(language:kuery,query:'@log_stream:*uvicorn.error*%20AND%20source_host:*fastapi*'),sort:!())
.. _Kibana Error Dashboard: https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/dashboard/c378da30-5c92-11eb-bad1-cf638f17b353?_a=(description:'',filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:levelname,negate:!f,params:(query:ERROR),type:phrase),query:(match_phrase:(levelname:ERROR))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:levelname,negate:!t,params:!(INFO,DEBUG),type:phrases,value:'INFO,%20DEBUG'),query:(bool:(minimum_should_match:1,should:!((match_phrase:(levelname:INFO)),(match_phrase:(levelname:DEBUG)))))),('$state':(store:appState),meta:(alias:'Message%20Recovery',disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:source_host,negate:!t,params:!('*automation-analytics-message-recover*','*automation-analytics-bundle-recovery*'),type:phrases,value:'*automation-analytics-message-recover*,%20*automation-analytics-bundle-recovery*'),query:(bool:(minimum_should_match:1,should:!((match_phrase:(source_host:'*automation-analytics-message-recover*')),(match_phrase:(source_host:'*automation-analytics-bundle-recovery*')))))),('$state':(store:appState),meta:(alias:FastAPI,disabled:!t,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:source_host,negate:!t,params:(query:'*automation-analytics-api-fastapi*'),type:phrase),query:(match_phrase:(source_host:'*automation-analytics-api-fastapi*'))),('$state':(store:appState),meta:(alias:Processor,disabled:!t,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:source_host,negate:!f,params:(query:'automation-analytics-processor*'),type:phrase),query:(match_phrase:(source_host:'automation-analytics-processor*'))),('$state':(store:appState),meta:(alias:Rollups,disabled:!t,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:source_host,negate:!t,params:(query:'automation-analytics-rollups*'),type:phrase),query:(match_phrase:(source_host:'automation-analytics-rollups*'))),('$state':(store:appState),meta:(alias:!n,disabled:!t,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:levelname,negate:!f,params:(query:WARNING),type:phrase),query:(match_phrase:(levelname:WARNING))),('$state':(store:appState),meta:(alias:'Red%20Hat%20accounts',disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:tenant,negate:!t,params:!('5318290','11009103','6340056','11789772','1979710','12817815','11971228','12369592'),type:phrases,value:'5,318,290,%2011,009,103,%206,340,056,%2011,789,772,%201,979,710,%2012,817,815,%2011,971,228,%2012,369,592'),query:(bool:(minimum_should_match:1,should:!((match_phrase:(tenant:'5318290')),(match_phrase:(tenant:'11009103')),(match_phrase:(tenant:'6340056')),(match_phrase:(tenant:'11789772')),(match_phrase:(tenant:'1979710')),(match_phrase:(tenant:'12817815')),(match_phrase:(tenant:'11971228')),(match_phrase:(tenant:'12369592')))))),('$state':(store:appState),meta:(alias:!n,disabled:!t,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:elapsed,negate:!f,params:(gte:30,lt:100),type:range),range:(elapsed:(gte:30,lt:100))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:exception,negate:!t,params:(query:'*sqlalchemy.exc.OperationalError:%20(psycopg2.errors.QueryCanceled)%20canceling%20statement%20due%20to%20statement%20timeout*'),type:phrase),query:(match_phrase:(exception:'*sqlalchemy.exc.OperationalError:%20(psycopg2.errors.QueryCanceled)%20canceling%20statement%20due%20to%20statement%20timeout*'))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:'@message',negate:!t,params:(query:'%5BProcessor%5D%20Processing%20error:%20%5BErrno%202%5D%20No%20such%20file*'),type:phrase),query:(match_phrase:('@message':'%5BProcessor%5D%20Processing%20error:%20%5BErrno%202%5D%20No%20such%20file*'))),('$state':(store:appState),meta:(alias:!n,disabled:!t,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:message,negate:!f,params:(query:'%5BRBAC%5D%20RBAC%20Service%20call%20failure*'),type:phrase),query:(match_phrase:(message:'%5BRBAC%5D%20RBAC%20Service%20call%20failure*'))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:'@message',negate:!t,params:(query:'Processing%20error:%20Error%20-3*'),type:phrase),query:(match_phrase:('@message':'Processing%20error:%20Error%20-3*'))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:'@message',negate:!t,params:(query:'%5BProcessor%5D%20Processing%20error:%20Compressed%20file%20ended%20before%20the%20end-of-stream%20marker%20was%20reached'),type:phrase),query:(match_phrase:('@message':'%5BProcessor%5D%20Processing%20error:%20Compressed%20file%20ended%20before%20the%20end-of-stream%20marker%20was%20reached'))),('$state':(store:appState),meta:(alias:!n,disabled:!f,index:ffb9f2a0-5408-11eb-bad1-cf638f17b353,key:message.keyword,negate:!t,params:(query:'%5BProcessor%5D%20Processing%20error:%20file%20could%20not%20be%20opened%20successfully'),type:phrase),query:(match_phrase:(message.keyword:'%5BProcessor%5D%20Processing%20error:%20file%20could%20not%20be%20opened%20successfully')))),fullScreenMode:!f,options:(hidePanelTitles:!f,useMargins:!t),panels:!((embeddableConfig:(),gridData:(h:7,i:'41a415bd-3fbf-4af9-9e26-169807ceb4c0',w:48,x:0,y:0),id:a9478380-5c99-11eb-bad1-cf638f17b353,panelIndex:'41a415bd-3fbf-4af9-9e26-169807ceb4c0',type:visualization,version:'7.7.1'),(embeddableConfig:(),gridData:(h:15,i:ab8fcc36-f628-495f-9fee-2756275b03b9,w:11,x:0,y:7),id:'9d443b00-540b-11eb-bad1-cf638f17b353',panelIndex:ab8fcc36-f628-495f-9fee-2756275b03b9,type:visualization,version:'7.7.1'),(embeddableConfig:(),gridData:(h:15,i:'8fec71f1-a79f-49f3-be7f-ef82b1b9848e',w:10,x:11,y:7),id:'78898710-5c9a-11eb-bad1-cf638f17b353',panelIndex:'8fec71f1-a79f-49f3-be7f-ef82b1b9848e',type:visualization,version:'7.7.1'),(embeddableConfig:(table:!n,vis:(params:(sort:(columnIndex:1,direction:desc)))),gridData:(h:15,i:a278e299-a2f3-423e-b844-2f8ef0e0e68c,w:7,x:21,y:7),id:b3df3cd0-540a-11eb-bad1-cf638f17b353,panelIndex:a278e299-a2f3-423e-b844-2f8ef0e0e68c,type:visualization,version:'7.7.1'),(embeddableConfig:(),gridData:(h:15,i:'1fd74f16-1253-4f31-a636-d2c7bbc643fc',w:10,x:28,y:7),id:bc3eb200-5c95-11eb-bad1-cf638f17b353,panelIndex:'1fd74f16-1253-4f31-a636-d2c7bbc643fc',type:visualization,version:'7.7.1'),(embeddableConfig:(),gridData:(h:15,i:'984fc0df-c412-4385-a206-faa458427654',w:10,x:38,y:7),id:'4e919390-c43b-11eb-8c9c-c3e62251cf3b',panelIndex:'984fc0df-c412-4385-a206-faa458427654',type:visualization,version:'7.7.1'),(embeddableConfig:(columns:!(source_host,levelname,tenant,message,exception,tower_version,tower_license_type)),gridData:(h:39,i:'5ccbc380-0874-49c0-9894-4b098d97cfac',w:48,x:0,y:22),id:'3071ea30-5c90-11eb-bad1-cf638f17b353',panelIndex:'5ccbc380-0874-49c0-9894-4b098d97cfac',type:search,version:'7.7.1')),query:(language:kuery,query:''),timeRestore:!t,title:'Tower%20Analytics%20error%20dashboard',viewMode:view)&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:now-5d,to:now))
.. _OpenShift/tower-analytics-prod: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/tower-analytics-prod/deployments/automation-analytics-api-fastapi-v2
.. _Prod Cluster: https://visual-app-interface.devshift.net/clusters#/openshift/crcp01ue1/cluster.yml
.. _Prod Jobs: https://console-openshift-console.apps.crcp01ue1.o9m8.p1.openshiftapps.com/k8s/ns/tower-analytics-prod/jobs
.. _Stage Cluster: https://visual-app-interface.devshift.net/clusters#/openshift/crcs02ue1/cluster.yml
.. _Messages SQL: https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/app-interface/sql-queries/insights/tower-analytics/2022-02-10-tenants-messages-prod.yml
