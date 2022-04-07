- [Moving off of Docker Hub](#moving-off-of-docker-hub)
  - [Why?](#why)
  - [What is changing](#what-is-changing)
    - [Changes to AppSRE pipelines](#changes-to-appsre-pipelines)
    - [Changes to AppSRE service deployments](#changes-to-appsre-service-deployments)
  - [How do I move away from Docker Hub?](#how-do-i-move-away-from-docker-hub)
    - [Replace the FROM image in your dockerfiles](#replace-the-from-image-in-your-dockerfiles)
      - [Red Hat UBI images](#red-hat-ubi-images)
      - [AppSRE mirror of common Docker Hub images](#appsre-mirror-of-common-docker-hub-images)
    - [Ad-hoc uses of images from Docker Hub](#ad-hoc-uses-of-images-from-docker-hub)
  - [What if I cannot find a way to move away from Docker Hub?](#what-if-i-cannot-find-a-way-to-move-away-from-docker-hub)
- [Implementation](#implementation)

# Moving off of Docker Hub

TLDR: Docker Hub will start rate limiting pulls on November 1st, 2020 and AppSRE will implent changes to move away from Docker Hub on **October 5th, 2020**

## Why?

Due to the upcoming Docker Hub [policy change](https://www.docker.com/blog/scaling-docker-to-serve-millions-more-developers-network-egress/) imposing a rate limit on image pulls, the AppSRE team will be making a couple of changes to its pipelines. The Docker Hub policy change is scheduled to take effect on November 1st. AppSRE is aiming to implement the following changes on October 5th.

## What is changing

### Changes to AppSRE pipelines

AppSRE pipelines (jenkins) will prevent pulling images from Docker Hub. This means that any docker/podman build or script that is using an image from Docker Hub from AppSRE CI pipelines will fail. Teams have to ensure their Dockerfiles are pulling FROM images that are not hosted in docker hub. We of course recommend that users pull images from Quay.io.

### Changes to AppSRE service deployments

AppSRE will prevent deploying images directly from Docker Hub on AppSRE managed clusters. Teams have to ensure their deployment manifests do not reference images from Docker Hub.

## How do I move away from Docker Hub?

### Replace the FROM image in your dockerfiles

The FROM line in your dockerfiles indicates the images from which your image is built. From now on, AppSRE will not allow building images based of images in Docker Hub.

You should replace your base image with one that is supported by AppSRE

#### Red Hat UBI images

Red Hat provides [Universal Base Images (UBI)](https://developers.redhat.com/products/rhel/ubi) which are based on RHEL. They should be the default choice for every image we use.

Many UBI images can be found in the Red Hat catalog, including toolsets for Golang, NodeJS, Python and more. The images can be searched from the [Red Hat Container Catalog](https://catalog.redhat.com/software/containers/)

This registry can be used directly. AppSRE also [provides a mirror](https://quay.io/app-sre) of some of the UBI images as they are not officially available in Quay.io. 

Here is an example MR where we moved an image using the upstream "official" golang base image with the one provided by Red Hat UBI: https://github.com/app-sre/rds-enhanced-metrics-exporter/pull/4/files

```diff
-FROM golang:latest as builder
+FROM registry.access.redhat.com/ubi8/go-toolset:latest as builder
+ENV GOPATH=/go/
+USER root
+RUN mkdir -p /go/src/github.com/percona/rds_exporter
 WORKDIR /go/src/github.com/percona/rds_exporter
 RUN git clone --progress --verbose https://github.com/percona/rds_exporter.git .
 RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o rds_exporter .
 
-FROM alpine:latest
-RUN apk --no-cache add ca-certificates
+FROM registry.access.redhat.com/ubi8-minimal:8.2
+RUN microdnf update -y && rm -rf /var/cache/yum && microdnf install ca-certificates
 WORKDIR /
 COPY --from=builder /go/src/github.com/percona/rds_exporter/rds_exporter .
 ENTRYPOINT ["./rds_exporter", "--config.file=/rds-exporter-config/config.yml"]
```

#### AppSRE mirror of common Docker Hub images

AppSRE currently mirrors some common Docker Hub images which are not available in Quay.io

Note: Some of these images are NOT based on UBI, RHEL or CentOS. As such, we recommend the above mentionned UBI images first and only if those cannot be used then we propose using the mirror images.

Also note that at some point in the future, AppSRE may deprecate and stop the mirroring of images from Docker Hub.

The quay repos (and image mirrors) are [documented](https://gitlab.cee.redhat.com/service/app-interface/-/tree/master#mirroring-quay-repositories) and [configured](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/data/services/app-sre/app.yml#L45) in App-Interface and the images are published at Quay.io [here](https://quay.io/organization/app-sre)

### Ad-hoc uses of images from Docker Hub

Some build tools such as scripts and Makefiles uses `docker run` to run images from Docker Hub. These will cease to work. Tenants have to inspect such scripts and make sure they use images from Quay.io. App-SRE already has many of such images [mirrored to Quay.io](https://quay.io/app-sre).

## Suggested alternative images

Note: The default choice should always be to move to UBI. While the path may not be straightforward in all cases, this aligns more with the company compared to other choices.

| Purpose            | Docker Hub                                | Alternative                                                                                                                         | Mirror?                                                                                 |
| ------------------ | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Minimal base image | alpine<br />ubuntu<br />non-rhel          | [registry.access.redhat.com/ubi8/ubi-minimal](https://catalog.redhat.com/software/containers/search?q=ubi8/ubi-minimal)             | [quay.io/app-sre/ubi8-ubi-minimal](https://quay.io/repository/app-sre/ubi8-ubi-minimal) |
| Go                 | golang:<version><br />golang:latest       | [registry.access.redhat.com/ubi8/go-toolset](catalog.redhat.com/software/containers/search?q=ubi8%2Fgo-toolset)                     | [quay.io/app-sre/ubi8-go-toolset](https://quay.io/repository/app-sre/ubi8-go-toolset)   |
| NodeJS             | nodejs                                    | [registry.access.redhat.com/ubi8/nodejs-12](https://catalog.redhat.com/software/containers/search?q=ubi8%2Fnodejs&p=1)              | [quay.io/app-sre/ubi8-nodejs-12](https://quay.io/repository/app-sre/ubi8-nodejs-12)     |
| busybox            | busybox                                   | [quay.io/app-sre/ubi8-ubi-minimal](quay.io/app-sre/ubi8-ubi-minimal)                                                                | -                                                                                       |
| CentOS             | centos:7<br />centos:8<br />centos:latest | We recomment to move to UBI or to [quay.io/centos/centos](https://quay.io/repository/centos/centos)                                 | -                                                                                       |
| Python             | python                                    | [registry.access.redhat.com/ubi8/python-38](https://catalog.redhat.com/software/containers/ubi8/python-38/5dde9cacbed8bd164a0af24a) | -                                                                                       |

## What if I cannot find a way to move away from Docker Hub?

Please reach out to the AppSRE team via Slack #sd-app-sre or email sd-app-sre@redhat.com and we will work with you to find a solution.

# Implementation

The block is implemented by pointing the docker hub registry hostnames to an invalid IP address in `/etc/hosts`

The ansible task for this is defined here:
- https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/node-ci-ext-jenkins-worker.yml#L20
- https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/node-ci-int-aws-jenkins-worker.yml#L16
- https://gitlab.cee.redhat.com/app-sre/infra/-/blob/master/ansible/playbooks/roles/docker-block-registries/tasks/main.yml

It is possible to temporarily undo this by commenting out the lines in `/etc/hosts` on the jenkins nodes. The playbooks can also be changed to ensure the entry is `absent` from `/etc/hosts`
