# Design document - SaaS Promotions Manager Integration

## Author / Date

Karl Fischer
February 2023

## Tracking JIRA

[APPSRE-6941](https://issues.redhat.com/browse/APPSRE-6941)

## Problem statement

We often see merge conflicts in auto-promotion MRs created by our devtools bot.
Promotions are currently event based. Gitlab sends messages to an SQS queue if
an auto-promotion is desired as result of a merge.
The SQS queue is read by an integration, which then creates auto-promotion MRs.

An auto-promotion can take some time. If a change was done to a saas file in the
meantime, then we will see merge confilcts that currently need manual intervention.
Changes can happen by a human, but they can also happen through multiple in-flight
MRs from the auto-promoter process.

## Goals

* Solution to avoid merge conflicts in auto-promotions

## Proposal

## Alternatives

## Milestones

* TODO
