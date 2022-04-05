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

## Proposal

Add a `test_data` directory in app-interface which will be populated with test data.

This directory will not be bundled together with the production data and will never leave the local pr-check scope. During pr-check only, we will repeat the bundle + validation step just like we do for the `data` directory, but using `test_data` instead. We will follow up by running specific integrations (such that test the test data in some way) against that data.

This approach means that the only updates we will need to make will be in the app-interface pr-check, and we will be able to re-use qontract-validator AS IS.

## Alternatives considered

- Enhance qontract-validator to bundle test data into the production bundle (not with the actual data, but still within the bundle)
- Use existing production data as an expected result. This may lead to additional overhead in maintaining the expected test results.

## Milestones

1. Add test data
1. Update pr-check to run explicitly specified integrations against it.
