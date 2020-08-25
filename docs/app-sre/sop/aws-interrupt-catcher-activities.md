# AWS Interrupt Catcher activities

## Definitions

AWS `osio` account - The AWS account with ID [386414299200](https://386414299200.signin.aws.amazon.com/console). Used to contain production and development resources.

AWS `osio-dev` account - The AWS account with ID [619539278362](https://619539278362.signin.aws.amazon.com/console). A new account created to contain development resources.

## Background

We have been working on seperating development resources from production resources, in the attempt to remove all development resources in the `osio` account. The aim is to remove stale resources and to move others to the `osio-dev` account when requested.

## Purpose

This document aims to describe processes that has to be done manually from time to time in order to move resources from the `osio` account to the `osio-dev` account.

## Content

* DynamoDB cross account export
* Reset user AWS console password
* Reset user MFA device

### DynamoDB cross account export

See docs [here](../../aws/dynamodb-cross-account-export.md).

### Reset user AWS console password

See docs [here](../../aws/reset-user-password.md)

### Reset User MFA Device

See docs [here](../../aws/aws-mfa-entity-already-exists.md)
