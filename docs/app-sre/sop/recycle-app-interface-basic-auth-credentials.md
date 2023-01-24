# Recycle app-interface basic auth credentials

1. Create and remember a new (24 char) password, e.g., via:

```
pwgen 24 1
```

2. Create htpasswd entry for new user/password:

```
htpasswd -n -b <NEW-USER> <PASSWORD_FROM_STEP_1>
```

New user is important, so we do not have to change any existing user/password combination.
Changing an existing combination breaks access.

3. Get base64 encoded version

Beware of newlines! Use `echo -n`

```
echo -n "<NEW_USER_FROM_STEP_2>:<PASSWORD_FROM_STEP_1>" | base64
```

4. Add htpasswd entry (step 2) to file [htpasswd](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/app-interface)

5. Add base64 encoded token (step 3) in the following qontract-tomls:
  - [app-interface-production](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/qontract-reconcile-toml)
  - [ci-int](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-int/qontract-reconcile-toml)
  - [ci-ext](https://vault.devshift.net/ui/vault/secrets/app-sre/show/ci-ext/qontract-reconcile-toml)

6. Add base64 encoded token (step 3) to [visual-qontract](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/visual-qontract-prod/visual-qontract)

7. Add user (from step 2) and password (from step 1) to [basic-auth](https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface/production/basic-auth)

8. In addition, submit a MR to app-interface to update the following secret versions:
- https://gitlab.cee.redhat.com/service/app-interface/-/blob/30260ea6fae449ae8da8fab66c4707733e5f9f6b/data/services/app-interface/namespaces/app-interface-production.yml#L31-33
- https://gitlab.cee.redhat.com/service/app-interface/-/blob/30260ea6fae449ae8da8fab66c4707733e5f9f6b/data/services/app-interface/namespaces/app-interface-production.yml#L43-45

You may need to restart all the pods in the app-interface-production namespace.

9. When everything still works, remove the old user/password entry from the [htpasswd](https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/app-interface) -> also bump secret version in app-interface

10. Verify that old credentials are not working anymore

This should fail:

```
curl -v https://app-interface.devshift.net/graphql -H 'Authorization: Basic <OLD-BASE64-ENCODED-CREDS>'
```

# Recycle app-interface basic auth developer access

In case we need to recycle the basic auth credentials for app-interface production, these are the secrets to update:
- https://vault.devshift.net/ui/vault/secrets/app-interface/show/app-sre/app-interface-production/app-interface
    * update the 2nd line of the `htpasswd` key
- https://vault.devshift.net/ui/vault/secrets/app-sre/show/creds/app-interface/production/basic-auth
    * update the `dev-access` key

In addition, submit a MR to app-interface to update the following secret versions:
- https://gitlab.cee.redhat.com/service/app-interface/blob/master/data/services/app-interface/namespaces/app-interface-production.yml#L43-45

You may need to restart all the pods in the app-interface-production namespace.
