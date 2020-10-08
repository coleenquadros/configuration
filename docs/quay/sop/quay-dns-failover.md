- [Quay.io DNS Failover SOP](#quayio-dns-failover-sop)
  - [Find the current route receiving traffic](#find-the-current-route-receiving-traffic)
  - [Increase the weight for the new route](#increase-the-weight-for-the-new-route)
  - [Decreate the weight for the old route](#decreate-the-weight-for-the-old-route)
  - [Example](#example)

# Quay.io DNS Failover SOP

Quay's DNS is managed by AWS Route53. To change the which route receives the quay.io traffic, the weights of the specific routes need to be modified.

It is important for first increase the weight for the new route and then decrease the weight for the existing route to avoid any service disruption.

See [Weighted Routes](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/aws/aws-route53.md#selecting-a-weight-for-a-weighted-record) for details about weighted routes in Route53.

## Find the current route receiving traffic

In Route53, click on `Hosted Zones` on the left-hand side.  Filter the routes listed by `quay.io`.  The route that has a weight > 0 is the current active route.

## Increase the weight for the new route

Find the entry for the new route.  It should currently have a weight of 0.  Edit the route and increase the weight for the route to be > 0.  It is usually best to set this value to the same weight as the existing route.

## Decreate the weight for the old route

Edit the old (original) route and set the weight to 0.

## Example

To change from routeA to routeB, assuming routeA has a weight of 30:

1. Find the entry for routeA in AWS Route53 console
1. Edit routeB and set weight to 30
1. Edit routeA and set weight to 0
