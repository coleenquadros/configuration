# GraphQL API server

The purpose of this service is to provide the app-interface data with a GraphQL API.

Every file defined under the `/data` directory is called a datafile, and can be queried either by label or by schema from the GraphQL API. Once this datafile has been obtained, regular GraphQL resolving can be performed for the elements inside that datafile.

## Design

This service has been written in [nodejs](http://nodejs.org), and it has been developed and tested using [rh-nodejs8 scl](https://www.softwarecollections.org/en/scls/rhscl/rh-nodejs8/).

The library used for the GraphQL server is [graph-yoga](https://github.com/prisma/graphql-yoga).

Every json schema should have a corresponding GraphQL schema file under the [schemas](schemas) directory. The `base.js` file contains the common methods required for all specific GraphQL schema files. There is a 1-to-1 correspondence between the JSON schema and the GraphQL schema. For example:

- `$schema: "users/access.yml"` => The GraphQL schema will define an `Access` type that implements the `DataFile` [interface](https://graphql.org/learn/schema/#interfaces).
- `roles` top-level key => The GraphQL schema will define an `AccessRole` type.
- `teams/members` is a cross-reference of `/users/user.yml` objects, so it will return an list of `User` types.

The service is deployed using an OpenShift compatible container. The datafiles are built statically into the container, so the service is as a result completely static. It will be hosted in a private repo: `quay.io/app-sre/app-interface`.

## Quickstart

In the root of the git repo:

```shell
make build-app-interface
make run-app-interface
```

That will start the server in `http://localhost:4000`.

## Features

### Existing Features

- Base query that filters by schema and/or by label.
- Cross reference support, to allow referencing fields/objects in same or other datafile.

### Planned Features

- Testing
- Authentication / Authorisation
- Schema querying
- Dynamic GraphQL schema generation
- Compile time cross-reference validation

## Usage

### Querying

The base query is:

```
datafile(
label: JSON
schemaIn: [String]
): [DataFile]
```

It will search for datafiles by label, by schema, or both:

- `label`: JSON object with k/v, where the keys are the label names.
- `schemaIn`: list of strings, where each string is a the path to the schema as it appears in `$schema`.

For example, in order to retrieve the `access.yml` of the `quay.io` service:

```
{
  datafile(label: {service: "quay.io"}, schemaIn: ["users/access.yml"]) {
    ...
  }
}
```

### Cross-references

Note that the GraphQL server can follow cross-references:

- `$ref`: [jsonpointer](https://tools.ietf.org/html/rfc6901). The uri can be relative to the datafile or absolute (where `/` is the data root directory).
- `$jsonpathref`: Similar to `$ref` but uses [JsonPath](https://goessner.net/articles/JsonPath/) to resolve the data.

Examples:

```yaml
## ref provides a simple an convenient method to access objects by key name

# an entire datafile
$ref: "/users/jmelisba.yml"

# the above is equivalent to
$ef: "/users/jmelisba.yml#"

# the object `team` from the current datafile
$ref: "#/team"

# the above is equivalent to
$ref: ".#/team"

# jsonpath provides a more flexible querying method

# from the current datafile get the role from the roles array
# that has an specific value in the `name` attribute
$jsonpathref: '$.roles[?(@.name == "quay-developer")]'

# the above is equivalent to
$jsonpathref: '.$.roles[?(@.name == "quay-developer")]'

# the same but in another datafile
$jsonpathref: '/users/roles.yml$.roles[?(@.name == "quay-developer")]'
```
