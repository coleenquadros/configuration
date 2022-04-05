# Design doc: optimal location for app-interface schemas

## Author/date

Maor Friedman / 2022-04-05

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4750

## Problem Statement

As part of our newly gained abilities to [dynamically generate configuration based on app-interface data](https://github.com/app-sre/qontract-reconcile/pull/2272), we want to be able to test that templating works as we expect. This essentially means that we want to define a test for a templated resource, specifying what the expected result looks like.

Since templating happens based on data in app-interface, it is difficult to define a static file which represents the expected result.

For this purpose and others, we would like to be able to define test data in app-interface.

This test data can be used to test templating, and probably a million other things.

## Goals

Have the ability to define test data in app-interface, which is not acted on by integrations unless explicitly defined.

## Non-objectives

* Integrate test data with qontract-reconcile pr-check or E2E tests.

## Proposal

Add a `test_data` directory in app-interface which will be populated with test data.

This directory will not be bundled together with the production data and will never leave the local pr-check scope. During pr-check only, we will repeat the [bundle + validation](https://gitlab.cee.redhat.com/service/app-interface/-/blob/e3438fbf54c31acea66bd3a793deddff76c9ea0e/hack/pr_check.sh#L63-69) step just like we do for the `data` directory, but using `test_data` instead. This means that any data added to the `test_data` directory is validated against our schemas.

We will follow up by [running specific integrations](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/hack/select-integrations.py) (such that test the test data in some way) against that data.

This data will only be tested by particular integrations. The plan is to start with only validating integrations, specifically the (proposed) integration `templates-tester` (described in !36434). Each integration that we will want to run against this test data will need to be reviewed on a case by case basis. For example, we can't (at this time) test `openshift-resources` (for example) since it needs to interact with external resources, OpenShift clusters in this case.

Integrations that will need to run against test data will explicitly specify it in the integration file (`/data/integrations`) in the form of:
```yaml
pr_check:
  cmd: <integration>
  run_with_test_data: true
```

This is going to be transparant to the integrations. They will run against a qontract-server loaded with a bundle that includes `test_data` instead of `data`. We will still use the same `resources`, as these are referenced from data files, which will reside in the `test_data` directory. As the initial intention in this proposal is to test templating of resources, we will want to reference a resource file and not duplicate it. This is another reason to use the existing `resources` instead of creating `test_resources`.

This approach means that the only updates we will need to make will be in the app-interface pr-check, and we will be able to re-use qontract-validator AS IS.

## Alternatives considered

- Enhance qontract-validator to bundle test data into the production bundle (not with the actual data, but still within the bundle).
- Use existing production data as an expected result. This may lead to additional overhead in maintaining the expected test results.

## Milestones

1. Add test data
1. Update pr-check to run explicitly specified integrations against it.
