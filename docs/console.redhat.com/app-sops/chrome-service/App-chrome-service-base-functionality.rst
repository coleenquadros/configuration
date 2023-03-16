App-chrome-service-base-functionality.rts
======================================

Summary
-------

Basic check that verifies if a service is operational

Access required
---------------

Access to console.redhat.com an account with any permissions. Valid JWT token is required to access console.redhat.com API gateway.

Steps
-----

- Login into console.redhat.com with any account.
- Paste https://console.redhat.com/api/chrome-service/v1/user into the same browser tab and ensure you get a valid 200 JSON response.

Escalations
-----------

- Ping development team using @crc-experience-team group in CoreOS Slack
- Send an email to platform-experience@redhat.com
- Escalation Policy: /data/teams/insights/escalation-policies/crc-experience-escalations.yml
