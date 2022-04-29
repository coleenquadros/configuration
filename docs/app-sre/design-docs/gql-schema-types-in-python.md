# Design doc: GQL Schema Types in Python

## Author/date

Karl Fischer / 2022-04-28

## Tracking JIRA

TBD (Will be adjusted during our discussion/review process)

## Problem Statement

Qontract-reconcile (QR) Python integrations consume the GraphQL (GQL) schema as a collection of un-typed nested dictionaries.
While this approach offers large flexibility and initial development speed, it comes at an increased code maintenance cost as the code base matures and grows.
[Similar work](gql-client-for-go-integrations.md) has been conducted for our GQL golang integrations.

## Goals

- Introduction of strict types for the GQL schema of QR Python integrations.
- Long-term migration strategy towards strict types

**NOTE:** In case we decide to use a code generator, this document does not discuss in detail the code generation process, e.g., where to generate/bundle the schema.
That topic is not only relevant to Python integrations and affects all schema code generators we might use.
For that reason it should be discussed in a dedicated document.

## Proposals

### Typing Problem

The following outlines 3 different approaches to tackle the typing issue.

#### GQL Client with Code Generator

Similar to our QR golang integrations, we could rely on a GQL client with code generator functionality for generating schema classes automatically.
An option might be [sgqlc](https://github.com/profusion/sgqlc), which is also listed as a client option on the official [GQL website](https://graphql.org/code/#python).

**Pros:**

- Low type maintenance cost, especially for complex nested types
- fairly easy and fast to setup

**Cons:**

- We depend on a 3rd party to interpret our schema. Maybe one day the schema interpration might change in the 3rd party tool, which will cause huge pain

#### Custom Wrapper

We could manually maintain a `schema` module in our code base.

**Pros:**

- We have full control on how our schema is converted to Python. We can keep that translation stable.

**Cons:**

- Schema changes are more time intensive
- Our current schema is quite big, i.e., setting up a custom schema module will be time intesive

#### GQL Client with Code Generator and Custom Wrapper

We use a code generator, but wrap its output into our own custom schema of most used types.
We might have a reduced set of custom types which are most commonly used.

**Pros:**

- We stay more independant of 3rd party tools -> easier to swap out and keep conversion stable

**Cons:**

- depending on how many types we want to wrap, the use of a code generator feels redundant here
- still maintaining a custom wrapper which comes at an extra time cost

### Migration Strategy

QR Python integrations are bundled in a rather large code base.
No matter which typing approach we choose, we should accomodate for a gradual migration strategy.
I.e., the new typing system must co-exist with our current un-typed approach.
Future changes to the code base will gradually convert towards the new type system.

For that purpose, we should create a new `queries.py`, e.g., a `typed-queries` module, which will
long-term replace `queries.py`. The choice of a module offers more code structuring options over a single file.

## Alternatives Considered

TBD (Will be adjusted during our discussion/review process)

## Milestones

TBD (Will be adjusted during our discussion/review process)

