# Finding the Active Quay cluster

Quay runs in an active/passive setup for high availability. The traffic redirection on the loadbalancers is determined by a DNS weight set on the quay.io DNS in Route53.

## Getting to the correct AWS account

See https://visual-app-interface.devshift.net/awsaccounts

- [Production Quay](https://visual-app-interface.devshift.net/awsaccounts#/aws/quayio-prod/account.yml)
- [Stage Quay](https://visual-app-interface.devshift.net/awsaccounts#/aws/quayio-stage/account.yml)

## Check Route53 configuration

- Once logged in to the correct account, head to the [Route53 console](https://console.aws.amazon.com/route53/v2/hostedzones#)
- Check the [quay.io hosted zone configuration](https://console.aws.amazon.com/route53/v2/hostedzones#ListRecordSets/Z2FAYW1VCQM237)
- Check the `Record ID` for the record with the highest `Weight`. An easy filter for finding this is:
  - Record name: "quay.io"
  - Type: A
  - Routing policy: Weighted
- The `Record ID` should have the currently active quay cluster's ID.
- You can now proceed to [Visual App-Interface](https://visual-app-interface.devshift.net/clusters) and search for this cluster

## Additional References

- [AWS Cloudwatch Weighted Routing](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/routing-policy.html#routing-policy-weighted)
- [Quay.io General Documentation](https://gitlab.cee.redhat.com/service/app-interface/blob/e525a77f7c208cd498ee33d4bad63ae2c179a76d/docs%2Fquay%2Fquayio.md)
