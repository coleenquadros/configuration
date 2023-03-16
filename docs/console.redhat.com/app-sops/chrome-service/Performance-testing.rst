Performance-testing.rst
=======================

Severity: Minimal
-----------------

Impact
------

- The chrome-service provides several backend utilities for dependant services in console.redhat.com. 
- During performance tests increased latency and error rate is an expected outcome. User experience might be degraded.

Summary
-------

Performance testing is executed in the following steps:

- Before starting performance testing, inform AppSRE in #sd-app-sre
- Send traffic to stage environment
- Monitor stage environment for results
- Inform AppSRE when performance testing is complete

Escalation
----------

- During performance tests, there is no need for escalation. The responsible team will be monitoring the service.
- Escalation Policy: /data/teams/insights/escalation-policies/crc-experience-escalations.yml
