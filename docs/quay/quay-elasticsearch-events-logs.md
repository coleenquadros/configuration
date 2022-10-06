# AWS Opensearch for event logs

Quay.io sends its events logs to a [Kinesis stream](). A
[lambda](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/quay-prod-logentry-stream-lambda)
then picks the events from the stream and pushes it to
[Opensearch](https://us-east-1.console.aws.amazon.com/esv3/home?region=us-east-1#opensearch/domains/quayio-prod-elasticsearch)
(AWS's elasticsearch)

We cannot directly access the Opensearch dashboard as it doesn't expose a
public endpoint. So there is a
[proxy](https://console-openshift-console.apps.quayp05ue1.d9j8.p1.openshiftapps.com/k8s/ns/opensearch-dashboards/deployments/opensearch-dashboards-proxy)
on the primary cluster that tunnels into the Opensearch.


## Access

To access the openseach dashboard go to the [proxy
endpoint](https://opensearch-dashboards.apps.quayp05ue1.d9j8.p1.openshiftapps.com/)
and login with github. You will be prompted with another credentials to the
openseach dashbaords which are accessible [here](
https://vault.devshift.net/ui/vault/secrets/app-interface/show/quayio-stage/elastic-credentials)  

Note: you need your github token to login to app-sre Vault. 

The credentials are under the keys: `master_user_name` and `master_user_password` use that to login to the Opensearch dashboard
