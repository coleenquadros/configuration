<!-- TOC -->

- [Managing Quay Routes](#managing-quay-routes)
  - [Modifying a record's weight](#modifying-a-records-weight)
  - [Adding a record](#adding-a-record)

<!-- /TOC -->

# Managing Quay Routes

Quay's routes are managed in AWS Route53's `quay.io` [Hosted Zone](https://console.aws.amazon.com/route53/home?region=us-east-2#resource-record-sets:Z2FAYW1VCQM237) using weighted records.

## Modifying a record's weight

To change which record(s) receive traffic, find the record to be edited and change the `Weight` on that record.  If the record is not to be used, set the `Weight` to 0.  If a record is to receive traffic, set the `Weight` to a value value > 0 and <= 255.

To determine a weight for a record, look [here](docs/aws/aws-route53.md#selecting-a-weight-for-a-weighted-record).

## Adding a record

Follow the procedure for [Adding a record to a Hosted Zone](docs/aws/aws-route53#adding-a-record-to-a-hosted-zone).