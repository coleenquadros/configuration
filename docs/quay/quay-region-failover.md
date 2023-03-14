# Switch Quay from us-east-1 to us-east-2

Quay runs in two regions

* `us-east-1` as the primary 
* `us-east-2` as the read-only hot standby

the domain `quay.io` points to the `us-east-1` during normal operations where the registry is in read-write mode (image push and pulls work). The DNS config can be found in the file `data/aws/quayio-prod/dns/quay.io.yaml`. This is a weighted DNS with 100% of the traffic going to the `us-east-1` endpoint `quayio-production-alb01`.

We have two entries to route IPv4 and IPv6 addresses.

* `type: A` indicates DNS record for IPv4 addresses.
* `type: AAAA` indicates DNS record for IPv6 addresses.

To failover to `us-east-2` simply increase the weight on the `us-east-2` endpoint to 100 and decrease the weight on the `us-east-1` endpoint to 0 for the following:

* For IPv4: `osd-us-east-2-proxy-protocol`
* For IPv6: `quayio-production-alb02`

**NOTE** Increase the weight on `us-east-2` endpoint before decreasing the weight on `us-east-1` endpoint.

Once failed over, quay will run in RO mode. Any write operation like pushes, creating users, orgs will fail. Builders and clair will also be disabled.

To fail back to `us-east-1` change the weights in the DNS to give 100% of the weights to the `us-east-1` endpoint.

