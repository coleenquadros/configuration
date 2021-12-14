# Fix 403 errors when Yum/DNF downloads RPMs in Jenkins

## Issue Description

Jenkins may fail to download any RPMs, failing build jobs. The
repositories will return 403 error codes.

## Identifying the issue

Typically users report 

```
Errors during downloading metadata for repository 'rhel-8-for-x86_64-baseos-rpms':
Status code: 403 for https://cdn.redhat.com/content/dist/rhel8/8/x86_64/baseos/os/repodata/repomd.xml
```

on one of their build jobs.

## Possible Cause for this issue

There is a daily job running subscription-manager on every Jenkins
node, but it sometimes gets stuck.

## Temporary resolution

Log into the affected node and run `sudo subscription-manager refresh`

## See also

https://issues.redhat.com/browse/APPSRE-4121

