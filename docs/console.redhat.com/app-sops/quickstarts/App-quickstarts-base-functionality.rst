App-quickstarts-base-functionality.rts
======================================

Summary
-------

Basic check that verifies if a service is operational

Access required
---------------

Access to console.redhat.com an account with any permissions. Valid JWT token is required to access console.redhat.com API gateway.

Steps
-----

- Obtain valid JWT for an console.redhat.com account. Can be achieved via login into the console.redhat.com trough browser.
- In the browser terminal create a new fetch call to "https://console.redhat.com/api/quickstarts/v1/helptopics". OS terminal can be used as well with tools like curl. The request must contain cookie with valid cs_jwt value. 
- Mmake sure the API responded with 200 response code and a valid JSON payload

Escalations
-----------

- Ping development team using @crc-experience-team group in CoreOS Slack
- Send an email to platform-experience@redhat.com
