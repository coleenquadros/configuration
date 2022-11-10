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
