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
- Long-term migration strategy towards strict types

## Proposals

### Code Generation

As of writing there is only 1 GQL code generator for Python actively maintained.
The following outlines 2 options we have.

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
- rather complex classes -> lots of magic happening

#### Custom Implementation

Code generation for **our use-case** is **no rocket science**. We could easily maintain our own code generator.

Similar to sgqcl, the generator takes a `my_query.gql` file and converts it to `my_query.py`.
The `my_query.py` contains very simple pydantic classes and a `data_to_obj(data: dict[Any, Any])` conversion method.

A PoC for a simple code generator can be found [here](https://github.com/app-sre/qontract-reconcile/pull/2389).

**Pros:**

- offers very simple Pydantic dataclasses
- works with static type checks
- we fully control our base types. E.g., we might decide to use a different kind of dataclass later on.

**Cons:**

- we need to maintain an additional code component

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
