<!-- TOC -->

- [Managing Route53](#managing-route53)
  - [Adding a Hosted Zone](#adding-a-hosted-zone)
  - [Adding a Record to a Hosted Zone](#adding-a-record-to-a-hosted-zone)
  - [Finding the Alias Target](#finding-the-alias-target)
  - [Selecting a Weight for a Weighted Record](#selecting-a-weight-for-a-weighted-record)

<!-- /TOC -->

# Managing Route53

Route53 is AWS' implementation of DNS.  It consists of `Hosted zones` that contain DNS records for that zone.  A `Hosted zone` is a domain name.

This document is only meant to be a highlight of common functionality.  For indepth documentation on Route53 see AWS' [documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values.html).

## Adding a Hosted Zone

In the `AWS Console` go to `Route53` and click on the `Hosted zones` link on the left.  This will bring up a list of defined zones.  Click on the `Create Hosted Zone` button on the top.  This will open a panel to the right.  Provide a `Domain Name` for the zone (ie example.com), a descriptive `Comment` and select the `Type`.

Press the `Create` button to complete the process.

Once the hosted zone is created, AWS will create nameservers for that hosted zone.  The registration for the domain will need to be updated to use the DNS servers AWS created.  See AWS' documentation for [active](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/migrate-dns-domain-in-use.html) and [inactive](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/migrate-dns-domain-inactive.html) domains for how to do this.

## Adding a Record to a Hosted Zone

In the `AWS Console` go to `Route53` and click on the `Hosted zones` link on the left.  This will bring up a list of defined zones.  Click on the one to edit and a list of existing records will be displayed.

Click on the `Create Record Set` at the top of the screen to create a new record for the zone.  This will bring up a panel on the right hand side of the screen with details for the record.  The `Name` field is the dns name for the record.  The field can be empty if the record is to apply to the domain as a whole.  If a subdomain is desired then add a value to the `Name` field.

Select the `Type` from the dropdown list that matches the desired record type.  Most entries relating to OSD routing will be either `A - IPv4 address` or `CNAME - canonical name`

If this is an alias record, select `Yes` for the `Alias` field.  Most records for OSD clusters will be alias records.  Follow the procedure for [Finding an alias target](#finding-the-alias-target).

If there is only only 1 entry for a record or all records are to receive traffic via a round-robin approach (and therefore equal traffic amongst all records) then select a `Routing Policy` of `Simple`.  If there is more than 1 entry for a record and it is desired to control how much traffic goes to each record then select `Weight` and follow the steps for selecting a [weight](#selecting-a-weight-for-a-weighted-record).

Select `No` for `Associate with Health Check`.

Press the `Create` button to finish creating the record.

## Finding the Alias Target

An Alias record needs a target.  For OSD clusters the target can be found by logging into the OSD cluster console and clicking on the `Networking` section on the left to expand it.  Click on the `Services` option and look for the `<service>-load-balancer-proxy-protocol-service` entry.  Click on that and on the right side there is a section named `Service Routing`, and inside that section is a field named `External Load Balancer`.  The value for this field will be the `Alias Target` for Alias records in Route53 for this cluster.

AWS will prepend `dualstack.` to the entry provided.

## Selecting a Weight for a Weighted Record

A weighted record will divde traffic between all records with a common name.  It does this based upon the `Weight` field for each record.  If all records have a `Weight` of 0 then traffic is recordd to all resources with equal probability.  If any other record is non-zero then a `Weight` of 0 will send no traffic to that record.  A `Weight` > 0 will send a portion of the traffic to that record that is proportional to the value of that record compared to the weight of outer records of the same name.

For exmaple, if there are 2 records with the folliwing weights:

- recordA: 30
- recordB: 60
  
Then recordB will get 2x the traffic of recordA, or roughly 66.6% of the total traffic to the record name.

The weight values are completely independent but must be between 0 and 255, inclusive (0 <= x <= 255).  The higher the value the more traffic a record will get.

The `Set ID` is a free form field and can be anything, but it must be unique.  Use it to provide a value that will distinguish between the records with the same name.  This will be the fastest means to know what each record is pointing to without having to track down what the alias is pointint to.  In most cases this value should be set to the name of the OSD cluster.

