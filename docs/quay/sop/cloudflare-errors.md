# Alerts

## Quayio CloudFlare worker script is reporting errors

The worker script that runs on CloudFlare is responsible for validating the
request and sending the response. If the script gives errors, please revert the
CDN back to CloudFront (see: [Rolling back cloudflare to CloudFront](#rolling-back-cloudflare-to-cloudfront) 


## Quay CloudFlare worker taking too long to respond

The worker script that runs on CloudFlare is responsible for validating the
request and sending the response. If the script takes too long to respond, please revert the
CDN back to CloudFront (see: [Rolling back cloudflare to CloudFront](#rolling-back-cloudflare-to-cloudfront) 


# Checking if response is from CloudFlare. 

1. Find out the URL rules that route traffic to the CloudFlare vs CloudFront
   deployment. They can be found in the [namespaces
   file](/data/services/quayio/namespaces/quayp05ue1.yml) under the ALB
   provider rules

2. check the `path` which routes to CloudFlare. Example:
    ```
     path: /v2/quayio-cloudflare-test/busybox/*
     ```
3. here `quayio-cloudflare-test/busybox` is the org/repo. Run the 
   following script replacing the org/repo with what you see in the rules

   ```
   #!/bin/bash
    
   # Replace this
   REPO=quayio-cloudflare-test/busybox
   
   BLOBS=$(curl -s https://quay.io/v2/$REPO/manifests/latest | jq -r '.fsLayers[].blobSum')
   
   echo $BLOBS
   
   while true
   do
       for blobsha in $BLOBS
       do
           echo $blobsha;
           CF_STATUS=$(curl -vL -o /dev/null https://quay.io/v2/$REPO/blobs/$blobsha 2>&1 | grep -i -e Server:)
           echo -e $CF_STATUS
       done
   done
   ```

   The output should have `Server: cloudflare1` if the response is from CloudFlare


# Rolling back cloudflare to CloudFront

If you see errors from CloudFlare or if the CloudFlare pods (pods with `-cloudflare` in their name) are crashing. You need to stop traffic to CloudFlare and redirect that traffic back to CloudFront.

1. Update the ALB rules in [quayp05ue1](/data/services/quayio/namespaces/quayp05ue1.yml) and [quayp04ue2](/data/services/quayio/namespaces/quayp04ue2.yml) remove any rules which redirect traffic to CloudFlare. These rules will have `target: quayio-cf` under their `action` 

Example rule:

```
    rules:
    - condition:
        path: /v2/quayio-cloudflare-test/busybox/*
      action:
        - target: quayio-cf
          weight: 100
        - target: quayio-production-py3
          weight: 0
```

Here you will remove this rule so the updated file looks like

```
rules: []
```

If there are other rules besides CloudFlare, keep them as-is

2. Check CloudFlare [status page](https://www.cloudflarestatus.com/) to see if there is any active outage. If so, keep CloudFlare failed over until the outage is resovled from CloudFlare

3. If there is no outage, it might be an issue with the worker script. Please open an issue with PROJQUAY with the information about the alert. Keep CloudFlare failed over till Quay team fixes the issue
