# GitHub Mirror

Github Mirror is a service built and run by the AppSRE team: https://github.com/app-sre/github-mirror

This service acts as a GitHub API mirror that caches the responses and implements conditional requests: https://docs.github.com/en/rest/overview/resources-in-the-rest-api#conditional-requests

## Overview

With conditional requests, all the calls are forwarded to the Github API, but when the GitHub API replies with a 304 HTTP code, meaning that the resource has not changed, we serve the client with the previously cached response.

That reduces the number of API calls that consume quota, helping you not to hit the GitHub API rate limit.

The mirror acts only on GET requests, by-passing other HTTP methods.

## How to use GitHub Mirror

1. Create a ticket on the APPSRE board requesting to use GitHub Mirror and add a description on the planned usage.
2. Submit a MR to add a GitHub user (bot) which you are going to use: https://gitlab.cee.redhat.com/service/app-interface/-/blob/92052baa487e3faead1dfe9e22e0536e5a3259c2/data/services/github-mirror/cicd/deploy.yaml#L30
3. Switch from using https://api.github.com to https://github-mirror.devshift.net

Example ticket: https://issues.redhat.com/browse/APPSRE-3506

Example MR: https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/22562
