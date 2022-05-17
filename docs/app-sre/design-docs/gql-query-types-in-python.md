# Design doc: Generate GQL Query Types in Python

## Author/date

Karl Fischer / 2022-04-28

## Tracking JIRA

[APPSRE-5537](https://issues.redhat.com/browse/APPSRE-5537)

## Problem Statement

Qontract-reconcile (QR) Python integrations consume the GraphQL (GQL) schema as a collection of un-typed nested dictionaries.
While this approach offers large flexibility and initial development speed, it comes at an increased code maintenance cost as the code base matures and grows.
[Similar work](gql-client-for-go-integrations.md) has been conducted for our GQL golang integrations.

## Goals

- Introduction of types for GQL queries of QR Python integrations, which can be statically verified (e.g., with `mypy`)
- CI should detect if a GQL schema change was not properly propagated to the query data structures in QR
- Long-term migration strategy towards strict types

## Proposals

### Code Generation

We generate classes dedicated to queries, i.e., every query gets its own classes.
By doing so, we can ensure that fields only get `Optional` if allowed by the schema.
If we generated a single class for every object in the schema, then we would need to make every field `Optional` to accomodate for custom GQL queries.
By making every field `Optional` we lose some stability offered through static type checking.

In the following we discuss 3 options:

- [sgqlc](https://github.com/profusion/sgqlc)
- [strawberry](https://github.com/strawberry-graphql/strawberry)
- [custom generator](https://github.com/app-sre/qontract-reconcile/pull/2389)

#### SGQLC

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

#### Strawberry

[strawberry](https://github.com/strawberry-graphql/strawberry) is a python library to define schemas as python classes and convert them to GQL.
Further, it offers a query code generator which converts a given `my_query.gql` into `my_query.py` file with corresponding dataclasses.
We need a PoC for this option to properly evaluate its capabilities.

**Pros:**

- we do not need to maintain an extra code component

**Cons:**

- code generation is experimental -> [subject to changes](https://strawberry.rocks/docs/codegen/query-codegen)

#### Custom Generator

Code generation for **our current use-cases** is **no rocket science**. We could easily maintain our own code generator.

Similar to `sgqcl` or `strawberry`, the generator takes a `my_query.gql` file and converts it to `my_query.py`.
The `my_query.py` contains very simple pydantic classes. Pydantic handles the mapping of dict to classes.

A PoC for a simple code generator with a usage example can be found [here](https://github.com/app-sre/qontract-reconcile/pull/2389).

**Pros:**

- offers very simple Pydantic dataclasses
- works with static type checks
- we fully control our base types. E.g., we might decide to use a different kind of dataclass later on.

**Cons:**

- we need to maintain an additional code component
- might be difficult to change something later on if we decide our implementation lacks a feature

##### Details on Custom Implementation

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
apps: list[saas_files_full.AppV1] = saas_files_full.SaasFilesFullQuery(**data).apps_v1 or []
```

More specifics and details can be found in the [PoC](https://github.com/app-sre/qontract-reconcile/pull/2389).

### Migration Strategy

The following outlines 2 viable migration strategies.

#### Use a Separate Module

QR Python integrations are bundled in a rather large code base.
No matter which typing approach we choose, we should accomodate for a gradual migration strategy.
I.e., the new typing system must co-exist with our current un-typed approach.
Future changes to the code base will gradually convert towards the new type system.

For that purpose, we should create a new `queries.py`, e.g., a `typed_queries` module, which will
long-term replace `queries.py`. The choice of a module offers more code structuring options over a single file.

#### Use a Proxy Class

On top of using a separate module, we could leverage proxy classes.

**queries.py:**

```
class SchemaProxy:

    def __init__(self, data: object):
        self.data = data

    def __getitem__(self, item):
        return getattr(self.data, item)


def get_integrations() -> SchemaProxy
    return SchemaProxy(typed_queries.get_integrations())
```

**typed-queries.py:**

```

def get_integrations() -> list[schema.Integration_v1]:
   ...
   return list_saas
```

## Alternatives Considered

TBD (Will be adjusted during our discussion/review process)

## Milestones

TBD (Will be adjusted during our discussion/review process)
