# Performance Testing

## SWATCH Deployment

1. Currently SWATCH service deployed to openshift perf cluster using clowder - https://issues.redhat.com/browse/SWATCH-557
2. The service has many components but the deployment of swatch service in the performance cluster was limited to swatch-tally and swatch-api components.
3. SWATCH service uses two postgres instances, rhsm-db, host-inventory-read-only-db and these are deployed using perf-aws-account in AWS.
4. All configuration changes are managed through app-interface

## SWATCH Performance Testing

1. Create a tenant account in the RBAC.
2. Populate HBI database by creating N hosts per account for all the accounts.
3. Populate RHSM database account_config table by creating sync_enabled and reporting_enabled to TRUE for all the accounts.
4. And once we have all the hosts table data in HBI and account config data in RBAC populated we would trigger tally compute operation.
5. Finally we capture "Time to produce first message to Kafka Topic", "Time to produce all messages to Kafka Topic", "Time to process first message from Kafka Topic", "Time to process last message from Kafka Topic", "Time to perform tally operation on all accounts" and "Average time required to perform tally operation" metrics to understand the swatch performance.
6. API endpoint used for testing `/api/rhsm-subscriptions/v1/hosts/products/RHEL?limit=100`

## How to rerun the SWATCH Performance Testing
1. Performance tooling was also limited to swatch-tally and swatch-api because these 2 are identified as core components which play an important role in service offering.
2. Use InsightsTally_builder jenkins job to deploy the desired image tag. If the deployment is successful then it will automatically trigger InsightsTally_runner, a Jenkins job which actually runs the performance test. 
   - https://master-jenkins-csb-perf.apps.ocp-c1.prod.psi.redhat.com/job/InsightsTally_builder/build
   - https://master-jenkins-csb-perf.apps.ocp-c1.prod.psi.redhat.com/job/InsightsTally_runner/build
   - https://issues.redhat.com/browse/ESSNTL-3614
3. As soon as the test completes results will be pushed to ElasticSearch. Use RHCloud CPT: Tally dashboard to see the results in Kibana
   - http://kibana.intlab.perf-infra.lab.eng.rdu2.redhat.com/goto/13f9cd9e34efe9178d2c9d377eb26ca7
4. If the current test result falls in the accepted range then we would say the test is passed otherwise the test is failed. If the current test is passed then the current test results will contribute to the decision making of PASS or FAIL for the upcoming test. 
5. Parameters that influence the performance testing ... 
   - accountscount            - No of accounts to consider for performance test
   - hostsperaccount         - No of hosts to add for each account during the performance test
   - locust.num_clients      - No of clients to create
   - locust.hatch_rate        - No of users to spawn per second
