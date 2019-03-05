## Versioning

For the contract components we will follow a two component versioning system:
`<MAJOR>.<MINOR>`.

`<MINOR>` version upgrades MUST be backwards compatible.

JSON schemas will:

- Include their major version in the filename: `access/user-1.yml`.
- Include a top-level `version` key with their `<MAJOR>.<MINOR>` version.

Example:

```
qontract-server/schemas/access/bot-1.yml
3:version: "1.0"

qontract-server/schemas/access/user-1.yml
3:version: "1.0"

qontract-server/schemas/access/role-1.yml
3:version: "1.0"

qontract-server/schemas/access/permission-1.yml
3:version: "1.0"

qontract-server/schemas/app-sre/app-1.yml
3:version: "1.0"
```

Note that the version **MUST** be a string (see
[here](<https://github.com/app-sre/qontract-server/blob/beb70a68334f49581c3656e2a223998965ee19c1/schemas/common-1.json#L16-L19>)).

Additionally **all** the resources created in the GraphQL schemas will have the
`_v<number>` suffix. Example:

```js
const typeDefs = `
  type Bot_v1 implements DataFile_v1 {
    schema: String!
    path: String!
    labels: JSON
    name: String!
    github_username: String
    owner: User_v1
  }
`
```

When new major versions are deployed, previous major versions **MUST NOT** be
removed. This will allow integrations to keep using old major versions, without
suffering from backwards compatibility changes.


## Open questions

- Should we protect against poorly performing upstream services with heuristics
  against the magnitude of the change and the service API responses?
- Is it actually possible to run a full rectification loop that is declarative
  and idempotent against all of our required services? Are we going to run into
  rate limits against the upstream services?
- Will we have the "list" permissions required for running a rectification loop
  against a running service for each required integration?
- Use a unique ID per schema?

## TODO

- ref resolver in PR check
- sleep 20 in pr_check.sh => better to implement a call that says that
  everything is loaded?
- heuristics to determine when not to execute the action - example,
  graphql-server returns nothing, everything gets deleted by reconcile github
- work on local datafile validator. currently it requires s3!
- graphql schema generator
- backrefs
- service currently handles only 1 replica (as the /reload will only received by one pod)
- inconsistency between relative and absolute paths
- oneOf in permissions to require mandatory attributes
