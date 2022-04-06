# Basic Functionality Test

## Summary

Details basic functionality test instructions. This tests [image-builder-crc][image-builder-crc],
[image-builder-composer][image-builder-composer], and
[image-builder-workers][image-builder-workers].

A simple build will be queued, executed, and it's artifact upload to S3.

## Access required

- [console.redhat.com][consoledot] or [console.stage.redhat.com][stageconsoledot] account with
  access to insights.

## Steps

### UI
1. Go to [Image Builder][consoledotib] or [Stage Image Builder][stageconsoledotib]

2. Click `Create Image`. In the wizard choose a `Virtualization - Guest image`. Choose `Register
   later` on the Registration page.

3. Click through to the Review page and click `Create Image`.

An image build will be queued, which involves a request to [image-builder-crc][image-builder-crc],
[image-builder-composer][image-builder-composer], and the
[image-builder-workers][image-builder-workers] will complete the build.

4. On the overview page wait until the status is green and produces a valid download link.

### API

This produces the same results as the UI method.

1. Save the following json
```
{
  "distribution": "rhel-85",
  "image_requests": [
    {
      "architecture": "x86_64",
      "image_type": "guest-image",
      "upload_request": {
        "options": {
        },
        "type": "aws.s3"
      }
    }
  ]
}
```

2. Send the request

Production:
```
curl -d'@request.json' -H "Content-Type: application/json" \
-u '$USER:$PWD' https://console.redhat.com/api/image-builder/v1/compose
```

Stage:
```
curl -d'@request.json' -H "Content-Type: application/json" \
--proxy http://squid.corp.redhat.com:3128 -u '$USER:$PWD' \
https://console.stage.redhat.com/api/image-builder/v1/compose
```

3. Extract the compose ID from the request

Response from the above request should look like
```
{
    "id": <uuid>
}
```

4. Poll the status until it returns `success` and produces a valid download link

Production:
```
curl -u '$USER:$PWD' https://console.redhat.com/api/image-builder/v1/composes/$ID
```

Stage:
```
curl --proxy http://squid.corp.redhat.com:3128 -u '$USER:$PWD' \
https://console.stage.redhat.com/api/image-builder/v1/composes/$ID
```

[image-builder-crc]:      https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/insights/image-builder
[image-builder-composer]: https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/image-builder
[image-builder-workers]:  https://gitlab.cee.redhat.com/service/app-interface/tree/master/data/services/image-builder
[consoledot]:             https://console.redhat.com
[stageconsoledot]:        https://console.stage.redhat.com
[consoledotib]:           https://console.redhat.com/beta/insights/image-builder
[stageconsoledotib]:      https://console.stage.redhat.com/beta/insights/image-builder
