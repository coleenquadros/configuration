# Service level healthcheck

If `/status` returns a non-200, check which service is `false`.

## Redis

Redis is down or inaccessible. Redis is currently managed via an ElastiCache in the Quay AWS account, so if this happens, restart the ElastiCache.

## Storage

If `storage` is reported as false, check [AWS Status Page](https://status.aws.amazon.com) for an S3 outage in US-East-1. If S3 is down, updated our status page to indicate as such. If S3 is not marked as down, check the registry logs to see if it is down. If so, updated our status page to indicate as such.

## :fire: Database :fire:

If `database` is reported as false, immediately check the status of RDS in the RDS control panel and see if it is currently failing over. If not, contact everyone possible and get them online, as this is a **major outage**.

## Other services

Probably a bad machine. It'll be taken out of service shortly automatically by OpenShift. Monitor to see if it fixes itself.
