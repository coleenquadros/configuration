# Skip Kube-Linter Checks

## Overview 
Currently, all of DVO's (Deployment Validation Operator) checks are handled by [kube-linter](https://github.com/stackrox/kube-linter). Kube-Linter supports methods of telling it to skip some or all checks on certain kubernetes objects. As such, these methods of skipping checks are compatible with DVO.

[It is planned](https://issues.redhat.com/projects/DVO/issues/DVO-3) for there to be a check built into DVO that will bring attention to kubernetes objects skipping kube-linter checks without App-SRE approval.

## Skip Specific Check

To ignore violations for specific objects, one can add an annotation with the key `ignore-check.kube-linter.io/<check-name>`. 

It is encouraged to add an explanation as the value for the annotation. For example, to ignore a check named "privileged" for a specific deployment, you can add an annotation like: `ignore-check.kube-linter.io/privileged: "This deployment needs to run as privileged because it needs kernel access"`.

## Skip All Checks

To ignore all checks for a specific object, use the special annotation key `kube-linter.io/ignore-all`.

It is encouraged to add an explanation as the value for the annotation. For example: `kube-linter.io/ignore-all: This is a temporary resource that is about to be deleted.`
