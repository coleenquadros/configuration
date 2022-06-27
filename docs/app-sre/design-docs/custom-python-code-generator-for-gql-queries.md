# Design doc: Python Code Generator for GraphQL Query Classes

## Author/date

Karl Fischer / 2022-06-16

## Tracking JIRA

[APPSRE-5831](https://issues.redhat.com/browse/APPSRE-5831)

## Problem Statement

In a [previous design doc](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/38147) we agreed to create our own custom code generator for GraphQL (GQL) queries.
This document discusses detailed implementation choices. This document is accompanied by a PoC.
By the end of this discussion the PoC should be ready to be used in production.

## Goals

* A ready to use implementation for a custom GQL query class code generator which allows to easily map nested untyped dictionaries into concrete types.
* Migration strategy towards adopting the code generator.

## Non-Goals

* Having a code generator which leverages all features of GQL (e.g., fragments). The code generator should initially focus on our use-cases.
* Discussing whether we want to have our own implementation. This was thoroughly discussed in a [previous design doc](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/38147).
* Discussing schema classes vs dedicated query classes. This was thoroughly discussed in a [previous design doc](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/38147).

## Proposal

The overall idea is to provide a code generator for GQL query Python classes, which fills a gap that current solutions do not offer (see [previous design doc](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/38147)).
It is an open source project driven by AppSRE.
As a positive side-effect the code generator enriches the overall python GQL eco-system.

### General

#### Name

The code generator will be called `qenerate`.

#### Code Location

We share the generator as a public repository in [app-sre/qenerate](https://github.com/app-sre/qenerate).
The repository is fully dedicated to the code generator to ease potential public collaboration.

#### CI/CD

To stay consistent with other app-interface projects we will use ci-ext.
Further, ci-ext will upload official releases to PyPi.

One big issue with ci-ext is that it requires Red Hat SSO,
which makes public collaboration more difficult. If we ever reach a point
were people outside of Red Hat want to contribute, we will have to find a solution for this.

#### License

As this not a Redhat product and should be community friendly, we choose a very permissive license: MIT.

### Implementation

### Getting the Schema

```sh
qenerate introspection http://localhost:4000/graphql > reconcile/gql_queries/schema_introspection.json
```

The code-generator must map the query to corresponding types. To achieve this an
[introspection query](https://graphql.org/learn/introspection/) json is needed. For debugging purposes, it makes sense to
package the `schema_introspection.json` together with the code. That way, in each
commit we know which exact schema the classes were generated from.

Getting an introspection json is a simple http request against a GQL server and will
be implemented as a dedicated step as shown in the command above.

### GQL and Py File Locations

```sh
qenerate code --introspection reconcile/gql_queries/schema_introspection.json reconcile/gql_queries/
```

The generator is given an introspection query result and a list of paths to walk recursively. Every `*.gql` file
on the way is read and a corresponding `*.py` file with class definitions is created next to it.

The result might look like this

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

### GQL File

A GQL file consists of a single valid named query. The content of the file could be copied and used as is in the `qontract-server` GQL UI.
The GQL standard allows comments via `#`. This is leveraged for code generator feature flags and will be discussed in a later section.

The code generator explicitly disallows anonymous queries, e.g.,

```graphql
query {
  heros {
    name
  }
}
```

Instead, queries must always be named:

```graphql
query QueryWithAName {
  heros {
    name
  }
}
```

The use of named queries is heavily encouraged by GQL to ease server side debugging.

### Plugin Structure for Backwards Compatibility

We might one day come across a situation in which we must extend the code generator or decide to change our data classes.
In that case, we do not want to re-write all our integrations to consume the new data structures.

A plugin based approach like [strawberry](https://strawberry.rocks/docs/codegen/query-codegen#plugin-system) has can help to apply a backwards incompatible change only on
certain queries. I.e., a query with specific requirements can use a different code-generator implementation,
while the other queries stay stable. Feature flags (mentioned in next section) can help here.

Every plugin implements its own methods of parsing the query into a typed abstract syntax tree (AST) and properly traversing the AST.
Once we have more than 1 plugin, we might consider shifting the AST into the `core` module which is common to all plugins.

Initially, we will only create a single plugin for Pydantic data classes, which will be explained in a later section.

### Feature Flags

Lets say for some query we do not want the pydantic `smart_union = True` feature enabled, because it comes with a performance cost.
Further, we might want to use a different code-generator plugin for a specific query.
We use feature toggles in the query, e.g.,:

```graphql
# qenerate: plugin=pydantic_v1
# qenerate: smart_union=False
query Hero {
  hero {
    name
  }
}
```

Note, that `#` is supported by the GQL standard. The query above works as is for a GQL server.

### First Plugin: Pydantic Dataclasses

#### General Mapping

We choose [pydantic data classes](https://pydantic-docs.helpmanual.io/usage/models/) to represent query classes. The main advantage is that pydantic can natively map
nested dictionaries to classes.

Here is an example of a simple query and its correspondingly generated pydantic model:

```graphql
query HeroForEpisode {
  hero {
    name
    primaryFunction
  }
}
```

```python
class Hero(BaseModel):
  name: str = Field(..., alias="name")
  primary_function: str = Field(..., alias="primaryFunction")  # Note that the alias is required for properly mapping dict to class


class QueryData(BaseModel):
  hero: Optional[list[Hero]] = Field(..., alias="hero")
```

#### Mapping interface types

GQL has interface types which should be mapped properly.
Pydantic does a pretty good job in mapping nested dictionaries to classes.

```graphql
query HeroForEpisode {
  hero {
    name
    ... on Droid {
      primaryFunction
    }
    ... on Human {
      height
    }
  }
}
```

```python
class Hero(BaseModel):
  name: str = Field(..., alias="name")


class Droid(Hero):  # Note that Droid implements Hero
  primary_function: str = Field(..., alias="primaryFunction")


class Human(Hero):  # Note that Human implements Hero
  height: str = Field(..., alias="height")


class HeroForEpisodeData(BaseModel):
  hero: Optional[list[Union[Droid, Human, Hero]]] = Field(..., alias="hero")

  class Config:
    # This is set so pydantic can properly match the data to union, i.e., properly infer the correct type
    # https://pydantic-docs.helpmanual.io/usage/model_config/#smart-union
    # https://stackoverflow.com/a/69705356/4478420
    smart_union = True
    extra = Extra.forbid
```

Note, that the interface itself (`Hero`) is still part of the `Union` and can be instantiated. This is necessary
in case neither `primaryFunction` nor `height` are existant on a returned entity.

#### Class name collisions

```graphql
query Hero {
  hero {
    name
    cape {
      color {
        name
      }
    }
    pants {
      color {
        name
        opposite
      }
    }
  }
}
```

```python
class Color:
    name: str
    opposite: str


class Pants:
    color: Color


# REDECLARATION!
class Color:
    name: str


class Cape:
    color: Color


class Hero:
    name: str
    cape: Cape
    pants: Pants


class HeroData:
    heros: Optional[list[Hero]]
```

Here we have a collision: The class `Color` is queried with different attributes in 2 different contexts.

One approach to fix this: prefix with parent context if collision is detected.
If there is also a collision with parent prefix, then add parent's parent and so on until you reach root.
E.g., in this case:

```python
class Color:
    name: str
    opposite: str

...

class Cape_Color:
    name: str
```

#### Data to Class mapping ambiguity

Queries on interfaces might return data that cannot be uniquely mapped to a class.

```graphql
query Hero {

  hero {
    name
    ... on Droid {
      height
    }
    ... on Human {
      height
    }
  }
}
```

```python
class Hero(BaseModel):
  name: str = Field(..., alias="name")


class Droid(Hero):
  height: str = Field(..., alias="height")


class Human(Hero):
  height: str = Field(..., alias="height")


class HeroData(BaseModel):
  hero: Optional[list[Union[Droid, Human, Hero]]] = Field(..., alias="hero")

  class Config:
    # This is set so pydantic can properly match the data to union, i.e., properly infer the correct type
    smart_union = True
    extra = Extra.forbid
```

In this scenario, it is impossible for the client to determine whether the received data belongs to a `Human` or a `Droid`,
because both share the exact same attributes in the query and are essentially the same class except for the name.
In fact, any entity with a `height` attribute will be cast to `Droid`
in this case, because `Droid` is declared first in the `Union` list. Pydantic maps Unions in order of declaration.

It is important to understand that branching based on `instanceof` calls here can lead to undesired behavior.
I.e., we must be aware that for some queries we should check attributes rather than class types.

#### Handling Python Keywords

If a class field has the name of a python keyword, e.g., `from`, then we must remap it to a different name.
This is the proposed remapping:

```python
keyword_remapping = {
    "global": "q_global",
    "from": "q_from",
    "type": "q_type",
    "id": "q_id",
    "to": "q_to",
    "format": "q_format",
}
```

#### Mapping Field Names

Field names are converted to snake case.

```
MyField -> my_field
```

#### Mapping Class Names

For classes the GQL type name is mapped to camel case.

```
App_v1 -> AppV1
```

### Migration Strategy

Currently, our queries reside in a single `queries.py` in qontract-reconcile.
We introduce a proxy class to migrate towards the new typed queries.

#### Leverage a Proxy Class

A [thread](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/38147#note_4000148) in the previous design doc suggests using a Proxy Class.

**queries.py:**

```python
class SchemaProxy:

    def __init__(self, data: object):
        self.data = data

    def __getitem__(self, item):
        return getattr(self.data, item)


def get_integrations() -> SchemaProxy
    return SchemaProxy(typed_queries.get_integrations())
```

**typed_queries.py:**

```python
def get_integrations() -> list[schema.Integration_v1]:
   ...
   return list_saas
```

The main advantage with this approach is that it reduces the amount of code changes required.

## Alternatives considered

### Migration: Dedicated new Module

We create a new module `typed_queries`. In this module we leverage the custom code generator and `*.gql` files to get typed query data.
The structure will look like this:

```sh
typed_queries/
├── app
│   ├── all_apps.py
│   └── __init__.py
├── code_gen
│   ├── app
│   │   ├── all_apps.gql
│   │   ├── all_apps.py
│   │   └── __init__.py
│   ├── __init__.py
│   └── saas
│       ├── __init__.py
│       ├── saas_small.gql
│       └── saas_small.py
├── __init__.py
└── saas
    ├── __init__.py
    └── saas_small.py
```

We will gradually move integrations away from `queries.py` towards the `typed_queries` module.
One advantage of the module approach is that it allows to split the logic into multiple files,
reducing average LoC per file.

In the end we decided against this approach as it requires more changes than introducing a
proxy class.

## Milestones

* PoC ready for production
* first query in qontract-reconcile migrated to use this code generator
* all queries in qontract-reconcile use this code generator
