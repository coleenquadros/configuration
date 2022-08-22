# Design doc: Enhanced AMI (image) selection for AWS Auto Scaling Groups (ASG)

## Author/date

Christian Assing - August 2022

## Problem statement

An AppSRE tenant wants to build several AMIs for a specific GIT commit and is using these tags:

RHEL 8 x86_64
* `name = "RHEL 8 x86_64"`
* `os = "rhel"`
* `os_version = "8"`
* `arch = "x86_64"`
* `commit = "aabbccddeeff..."`

and RHEL8 aarch64

* `name = "RHEL 8 aarch64"`
* `os = "rhel"`
* `os_version = "8"`
* `arch = "aarch64"`
* `commit = "aabbccddeeff..."`


To create AWS Auto Scaling Groups (ASG) out of them, the tenant has to specify the AMIs via the `image` schema section, e.g.:

```yaml
$schema: /openshift/namespace-1.yml
...

externalResources:
- provider: aws
  provisioner:
    $ref: /aws/.../account.yml
  resources:
  - provider: asg
    identifier: rhel-x86-64
    ...
    image:
      tag_name: commit
      url: http://github.com/...
      ref: aabbccddeeff...
  - provider: asg
    identifier: rhel-aarch64
    ...
    image:
      tag_name: commit
      url: http://github.com/...
      ref: aabbccddeeff...

```

Currently, `tag_name` with `ref` (commit sha) is the only way to reference the AMI, no other tags or other filters can be used.
Given that, qontract-reconcile will fail, because the current implementation of getting the AMI ids will return two AMIs, and [it'll throw
an exception](https://github.com/app-sre/qontract-reconcile/blob/f992017060663c7a526f84e1b594d69675cd0268/reconcile/utils/aws_api.py#L1376).

## Goal

Let tenants to specify multiple tags in the `image` section to allow fine-grained AMI selection.

## Out of scope

Everything else :)

## Proposed solution

Enhance the `image` schema section to be a list of different tag types.

`type = git`

Current implementation of a `tag_name`, `url` and `ref`.

`type = simple`

Simple possibility to specify a user-defined key/value pair.

E.g.:

```yaml
$schema: /openshift/namespace-1.yml
...

externalResources:
- provider: aws
  provisioner:
    $ref: /aws/.../account.yml
  resources:
  - provider: asg
    identifier: rhel-x86-64
    ...
    image:
      - tag_name: commit
        url: http://github.com/...
        ref: aabbccddeeff...
        type: git
      - tag_name: arch
        value: x86_64
        type: simple
  - provider: asg
    identifier: rhel-aarch64
    ...
    image:
      - tag_name: commit
        url: http://github.com/...
        ref: aabbccddeeff...
        type: git
      - tag_name: arch
        value: aarch64
        type: simple
```

With that tenants have more flexibility in how to use AMI tags in app-interface.

## Alternatives considered

Tenants have to use different `tag_name`s for their AMI images, which may leads to a [more complicated setup](https://github.com/osbuild/osbuild-composer/pull/2718/files#diff-3242a92a6c9ef4106d1ef5de8428854390640de462247209c2a8fb3f8d3fbf91R75) on their site.

## References

* [APPSRE-6126](https://issues.redhat.com/browse/APPSRE-6126)
* [osbuilder-compose: support aarch64 machines](https://github.com/osbuild/osbuild-composer/pull/2718)
