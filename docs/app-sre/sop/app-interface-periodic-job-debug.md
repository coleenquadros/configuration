# Periodic Job debugging

## Background

The app-interface periodic job is executing the following integrations:

* `slack-usergroups`
* `ldap-users`

## Purpose

This is an SOP for failure of the app-interface periodic job.

## Content

If this job fails, it means that one of the integrations is failing. To debug this, try to run the integraions locally using this SOP:

[running-integrations-manually](/docs/app-sre/sop/running-integrations-manually.md)
