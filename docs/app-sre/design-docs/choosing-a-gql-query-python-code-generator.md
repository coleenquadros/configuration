# Design doc: Deciding on a Python code generator for GQL Queries

## Author/date

Karl Fischer / 2022-04-28

## Tracking JIRA

[APPSRE-5537](https://issues.redhat.com/browse/APPSRE-5537)

## Problem Statement

Qontract-reconcile (QR) Python integrations consume the GraphQL (GQL) schema as a collection of un-typed nested dictionaries.
While this approach offers large flexibility and initial development speed, it comes at an increased code maintenance cost as the code base matures and grows.
[Similar work](gql-client-for-go-integrations.md) has been conducted for our GQL golang integrations.

## Goals

- Choose a tool to generate classes for GQL queries
- Tool must support static type checks, e.g., via `mypy`

## Non-Goals

- Migration strategy. This will be discussed in a follow-up design doc about implementation details
- Deciding on implementation details. Implementation details in this document are solely for highlighting problems that needs solving. Decision on implementation details will be done in a follow-up design doc.

## Proposal

We generate classes dedicated to queries, i.e., every query gets its own classes.
By doing so, we can ensure that fields only get `Optional` if allowed by the schema.
If we generated a single class for every object in the schema, then we would need to make every field `Optional` to accomodate for custom GQL queries.
By making every field `Optional` we lose some stability offered through static type checking.

We have investigated 3 options:

- [sgqlc](https://github.com/profusion/sgqlc)
- [strawberry](https://github.com/strawberry-graphql/strawberry)
- [custom generator](https://github.com/app-sre/qontract-reconcile/pull/2389)

In the end, we decided to go with a custom code generator.

### Custom Generator

Code generation for our current use-cases is a solvable problem. We could maintain our own code generator.

Similar to `sgqcl` or `strawberry`, the generator takes a `my_query.gql` file and converts it to `my_query.py`.
The generator only requires an introspection query to a GQL backend to properly interpret the types of a query.
The GQL core library does the heavy lifting of creating a typed abstract syntax tree (AST) for a GQL query.
The `my_query.py` contains very simple pydantic classes. Pydantic handles the mapping of dict to classes.
To highlight that those classes are basically typed containers for query data, the generated classes might be suffixed with `QueryData`.

A PoC for a simple code generator with a usage example can be found [here](https://github.com/app-sre/qontract-reconcile/pull/2389).

**Pros:**

- offers very simple Pydantic dataclasses
- works with static type checks
- we fully control our base types. E.g., we might decide to use a different kind of dataclass later on.

**Cons:**

- we need to maintain an additional code component
- might be difficult to change something later on if we decide our implementation lacks a feature

#### Details on Custom Implementation

A query is defined in a `.gql` file. The content of a `.gql` file is a valid query that could be used with curl against a GQL backend.
All `.gql` files are placed under the `gql_queries` directory.

Running `make generate-queries` will:

1. Run an introspection query against a GQL backend, i.e., fetch the schema
1. Read all `.gql` files under `gql_queries`
1. For each `.gql` file, generate the AST and match it with the types from the schema, i.e., generate a typed AST
1. Generate a corresponding `.py` file for each `.gql` file and place it in the same (sub)directory

In the end the `gql_queries` directory could look like this:

```
gql_queries/
├── __init__.py
└── saas_files
    ├── __init__.py
    ├── saas_files_full.gql
    ├── saas_files_full.py
    ├── saas_files_small_with_provider.gql
    └── saas_files_small_with_provider.py
```

The generated `.py` files can be consumed like:

```python
from gql_queries.saas_files import saas_files_full


with open("gql_queries/saas_files/saas_files_full.gql", "r") as f:
    query = f.read()

data: dict[Any, Any] = gqlapi.query(query)
apps: list[saas_files_full.AppV1QueryData] = saas_files_full.SaasFilesFullQueryData(**data).apps_v1 or []
```

More specifics and details can be found in the [PoC](https://github.com/app-sre/qontract-reconcile/pull/2389).

Some problems a code generator must consider:

- how do we offer a mechanism for backwards compatibility? --> e.g., we could implement a plugin mechanism like strawberry does
- how do we handle class name collision? --> e.g., we could prefix classes with parent names
- how do we deal with class mapping ambiguity? --> e.g., we could decide to not rely on `instanceof`

The final implementation decisions covering those questions will be discussed in a follow-up design doc.

## Alternatives Considered

### SGQLC

[sgqlc](https://github.com/profusion/sgqlc) is a GQL client with code generator functionality.
On top of using the GQL client you can generate classes for your queries.
A query file is written `my_query.gql` from which Python code `my_query.py` is generated.
That code can be used with the GQL client to obtain data in classes.

That being said, the classes are very generic and do not work with static type checks. This is a very hard limitation.
Further, the classes are quite complex with a lot of magic.

A PoC can be seen [here](https://github.com/app-sre/qontract-reconcile/pull/2367).

**Pros:**

- officially mentioned on [GQL website](https://graphql.org/code/#python)
- we do not need to maintain an extra code component

**Cons:**

- needs upstream contributions to allow static type checks. See [comment](https://github.com/profusion/sgqlc/issues/129#issuecomment-885820088).
- rather complex classes -> lots of magic happening, which we likely do not want in our base types

In the end we decided against sgqlc, mainly because it does not support static type checks in its current state.

We also [reached out](https://github.com/profusion/sgqlc/issues/129#issuecomment-1136022615) to the community, but did not come to a mutual understanding
on whether we can collaborate to change the tool to our needs.

### Strawberry

[strawberry](https://github.com/strawberry-graphql/strawberry) is a python library to define schemas as python classes and convert them to GQL.
Further, it offers a query code generator which converts a given `my_query.gql` into `my_query.py` file with corresponding dataclasses.

As of now strawberry requires the schema to be written into a python module using its library. Based on that module, the code generator can
generate query data classes.

A PoC is not feasible at this point, because it requires `qontract-schema` and `qontract-server` to be rewritten with strawberry.

**Pros:**

- we do not need to maintain an extra code component

**Cons:**

- code generation is experimental -> [subject to changes](https://strawberry.rocks/docs/codegen/query-codegen)
- `qontract-server` and `qontract-schema` need to be re-written with strawberry

In the end we decided against strawberry, mainly because in its current state it requires the schema to be defined code-first with the
strawberry framework on the GQL server side.

We also [reached out](https://github.com/strawberry-graphql/strawberry/issues/1940) to the community, but did not get any response.

## Milestones

1. PoC for custom code generator
1. Design doc with implementation details for custom code generator
