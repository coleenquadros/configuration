# Disable Jenkins job in app-interface

## Background

There are cases when a job in Jenkins should be disabled.

## Purpose

This is an SOP describing how to disable a Jenkins job in app-interface.

## Content

Find the desired job in app-interface. For example:

```yaml
- project:
    name: job-name
    ...
    jobs:
    - 'gh-build-master':
        display_name: build master
```

To disable the job, add `disable: true` under the job:

```yaml
- project:
    name: job-name
    ...
    jobs:
    - 'gh-build-master':
        display_name: build master
        disable: true
```
