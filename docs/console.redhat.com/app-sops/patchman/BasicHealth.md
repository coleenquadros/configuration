# Basic check whether application is running

## Browser

Go to [Patch page on consoledot](https://console.redhat.com/insights/patch/systems). If you're not logged in you will be prompted to log in.
Depending on the status of your account you will see different things on the page:
* Account has no connected systems - you'll see a message about learning how to connect your systems to Insights
* Account has connected systems - list of connected systems is present
* Account is not allowed to use Patch service - you'll see a "forbidden" message
All of these are valid scenarios when accessing systems page, it's recommended to visit other pages in Patch application (acccessible by a menu on the left) as well, in all cases pages should load without any errors which indicate basic health of the service

## Terminal
`curl -ski -X GET -u "${LOGIN}:${PWD}" https://console.redhat.com/api/patch/v1/status
Where `${LOGIN}` is your https://sso.redhat.com login/email and `${PWD}` is your password.  You need to figure out whether to use your login as `${LOGIN} (e.g. rhn-engineering-jdoe) or your email as `${LOGIN}` (e.g. jdoe@redhat.com), as it's been reported login works for majority of users but for some users it does not (usage of login results in authentication failire) and these users had to use their email. This inconsitency is caused by SSO and there's nothing Patch team can do about it.
200 and 204 are expected HTTP codes (the /status API should not return any 4xx or 5xx HTTP code).

Example of expected output:
```
curl -ski -X GET -u "${LOGIN}:${PWD}" https://console.redhat.com/api/patch/v1/status
HTTP/2 200
server: openresty
x-rh-insights-request-id: 6d61c2de6004447eb06ec5a1dd331370
x-content-type-options: nosniff
cache-control: private
date: Mon, 21 Mar 2022 08:20:51 GMT
content-length: 0
set-cookie: b3e2e456866f84f3604b36899c8be8b3=f48eaf8b95da84655097a72cbf4f0428; path=/; HttpOnly; Secure; SameSite=None
x-rh-edge-request-id: 297baf99
x-rh-edge-reference-id: 0.976ed417.1647850851.297baf99
x-rh-edge-cache-status: Miss from child, Miss from parent
x-frame-options: SAMEORIGIN
```

