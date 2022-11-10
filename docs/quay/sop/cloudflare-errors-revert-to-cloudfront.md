# Rolling back cloudflare to CloudFront

If you see errors from CloudFlare or if the CloudFlare pods (pods with `-cloudflare` in their name) are crashing. You need to stop traffic to CloudFlare and redirect that traffic back to CloudFront.

1. Update the ALB rules in [quayp05ue1]() and [quayp04ue2]() remove any rules which redirect traffic to CloudFlare. These rules will have `target: quayio-cf` under their `action` 

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