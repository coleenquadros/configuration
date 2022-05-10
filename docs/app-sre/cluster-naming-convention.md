# AppSRE Cluster Naming Standard

## Purpose
This document defines a naming scheme for all AppSRE clusters.

## Background
Although a cluster name can be up to 64 characters, only the first 15 are displayed in the URL (a consequence of this [issue](https://issues.redhat.com/browse/SDA-2288) ), which can cause confusion when accessing multiple clusters at one time. The idea is to create a name that is unique and human readable but only 15 chars.

## Conclusions
app-sre clusters:
`app-sre-(prod|stage)-0N`
tenant clusters:
`<service>(p|s)NN<region abbreviation>`

Note: To keep the name to 15 chars, limit the service name to 9 chars or fewer. In other words, 9c1c2c3c. For example, “`crcp01ue1`”.

## Region Abbreviations

Taken from [here](https://docs.aws.amazon.com/general/latest/gr/rande.html).

| Region Name | Code | Abbreviation |
|:-----------|:-------|:----------|
| US East (Ohio) | us-east-2 | ue2 |
| US East (N. Virginia) | us-east-1 | ue1 |
| US West (N. California) | us-west-1 | uw1 |
| US West (Oregon) | us-west-2 | uw2 |
| Africa (Cape Town) | af-south-1 | fs1 |
| Asia Pacific (Hong Kong) | ap-east-1 | ae1 |
| Asia Pacific (Mumbai) | ap-south-1 | as1 |
| Asia Pacific (Osaka-Local) | ap-northeast-3 | an3 |
| Asia Pacific (Seoul) | ap-northeast-2 | an2 |
| Asia Pacific (Singapore) | ap-southeast-1 | as1 |
| Asia Pacific (Sydney) | ap-southeast-2 | as2 |
| Asia Pacific (Tokyo) | ap-northeast-1 | an1 |
| Canada (Central) | ca-central-1 | cc1 |
| China (Beijing) | cn-north-1 | cn1 |
| China (Ningxia) | cn-northwest-1 | cw1 |
| Europe (Frankfurt) | eu-central-1 | ec1 |
| Europe (Ireland) | eu-west-1 | ew1 |
| Europe (London) | eu-west-2 | ew2 |
| Europe (Milan) | eu-south-1 | es1 |
| Europe (Paris) | eu-west-3 | ew3 |
| Europe (Stockholm) | eu-north-1 | en1 |
| Middle East (Bahrain) | me-south-1 | ms1 |
| South America (São Paulo) | sa-east-1 | se1 |



## Historical Information

The following is a list of ideas for ensuring that the first 15 characters are meaningful:
* Eliminate hyphens?
* Abbreviate “Prod” to “prd”?
* Abbreviate “stage” to “stg”?
* Abbreviate the env nomenclature to -p, -s, -i, -d  (prod, stage, integration, dev)
* Abbreviate “appsre” to “as” or “app” or “sdas”

Would be helpful when multiple clusters up in the webconsole.

Please add your ideas here and we can discuss them at the next coordination meeting.

From Aditya: IETF guidance [here](https://tools.ietf.org/html/rfc1178).

### Upstream tickets:
https://issues.redhat.com/browse/SDA-2288
https://issues.redhat.com/browse/CONSOLE-2217

### Proposal:
Do not reinstall any new clusters.
For clusters created in the future,
Abbreviate the env nomenclature to -p, -s, -i, -d  (prod, stage, integration, dev)
