- [Quay.io DNS Failover SOP](#quayio-dns-failover-sop)
  - [Find the current route receiving traffic](#find-the-current-route-receiving-traffic)
  - [Increase the weight for the new route](#increase-the-weight-for-the-new-route)
  - [Decreate the weight for the old route](#decreate-the-weight-for-the-old-route)
  - [Example](#example)

# Quay.io DNS Failover SOP

Quay's DNS is managed by AWS Route53. To change the which route receives the quay.io traffic, the weights of the specific routes need to be modified.

refer to the [failover doc](../quay-region-failover.md)
