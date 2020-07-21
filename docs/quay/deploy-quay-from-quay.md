# Deploy Quay from Quay

We currently deploy Quay using images stored in AWS ECR.

In case ECR goes down and we want to pull images from Quay itself, add the following 2 lines to the `parameters` section of the target you want to deploy:
```
IMAGE: quay.io/app-sre/quay
SYSLOG_IMAGE: quay.io/app-sre/syslog-cloudwatch-bridge
```

The saas file is located [here](https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/quayio/saas/quayio.yaml)
