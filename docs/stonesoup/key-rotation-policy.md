# Key Rotation Policy

Date: 2022-03-31

## Status

Accepted

Relates to [ADR 7. Change Management](https://github.com/redhat-appstudio/book/blob/main/ADR/0007-change-management.md)

## Context

As we move from developing a platform to operating one, we need clear policies for how to manage
keys and passwords involved in the production and stage instances.

## Decision

As a practice, rotate keys for deployments of RHTAP on a periodic basis: **once a year**.

If a key is passwordless, rotate it **every time a team member who had access to the key leaves the team**.

In the event of key exposure or possible key exposure, the credentials in question should be rotated
only after contacting Red Hat incident response to alert them to the exposure, in order to not
accidentally remove forensic evidence important to understanding the breadth of the breach.

## Consequences

* The regular key rotation practice will impose toil on teams, who need to remember to carry out the
  manual activity and carry it out.
* By documenting this as a common decision, we should have clarity about the frequency of rotation.

## SOPs

* [AppSRE - When an AWS Access Key is Exposed](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/sop/security/compromised-aws-access-key.md#when-an-aws-access-key-is-exposed).
* [Stonesoup - Managing Secrets](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/secrets.md)
