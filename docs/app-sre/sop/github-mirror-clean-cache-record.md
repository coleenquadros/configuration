# Github Mirror - Clean Redis Cache Record

## Impact

- Any clients using the Github Mirror service as the Github API endpoint
  will be served corrupted data from the cache.

## Summary

In some rare occasions, GitHub gives a corrupted response to some requests. If
such response comes with HTTP code 200 and also with a valid ETag header, the
github-mirror will cache the response and, from there, serve clients with that
corrupted data.

## Access required

- Must be an App-SRE Team member for accessing the `app-sre-prod-01` Openshift
  cluster.

## Steps

- Gain terminal access to one of the github-mirror pods.
- Execute:

```bash
$ python
>>> import hashlib
>>> from ghmirror.data_structures.redis_data_structures import RedisCache
>>>
>>> url = 'https://api.github.com/teams/2926968/invitations'
>>> token = '*****'  # Redacted
>>>
>>> cache = RedisCache()
>>> auth_sha = hashlib.sha1(f'token {token}'.encode()).hexdigest()
>>> cache_key = (url, auth_sha)
>>> response = cache[cache_key]
```

Inspect the response object:

```bash
>>> response.headers
...
>>> response.json()
...
```

Delete the cache record:

```bash
>>> cache.wr_cache.delete(cache_key)
```

Next call from the client should then cache a fresh response from the GitHub
API.

## Escalations

- Ping the @app-sre-ic user on Slack.
