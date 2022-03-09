# Design doc: GraphQL Client for integrations written in Golang

## Author/date

Jan-Hendrik Boll / 2022-03-01

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-4509

## Problem Statement

One of the biggest advanteges of writing code in Golang is making use of typing. Processing typed data from our qontract-server in Golang requires unmarshalling data into Golang structs. That Requires creating a type, which reflects the data fetched from the API (aka. Query results). 

Example for such a custom type:

```
type Entity struct {
    Field1 string
    Field2 Entity2   
}
type Entity2 struct {
    Field1 string
}
```

A query in GQL specifies the schema of the data returned by the server. 

Example for a Query:
```
{
  Entity: Entity {
    field1
    field2 {
      field1
    }
  }
}
```

Example for data returned by that query:
```
{
  "data": {
    "Entity": [
      {
        "field1": "test",
        "field2": {
            "field1": "foo"
        }
      }
    ]
  }
}
```

One challenge is that the schema a query is based on might change. This might break the integration right away or cause bugs during runtime. As a consequence, integration code needs to be tested upon schema change.

Another challenge when writing a client is that GQL supports [operations](https://graphql.org/learn/queries) that can change the schema of the returned data. These operations make it hard to write data types in Go - [considerations](https://github.com/Khan/genqlient/blob/main/docs/DESIGN.md#how-to-represent-interfaces). When writing an integration, only a subset of the entire schema is relevant. In particular, only what is returned by the query executed against qontract-server.


## Goals

 * Create types for Qontract-Server query results that can be used, to write integrations in Golang
 * Eliminate toil created by schema changes

## Non-objectives

 * Create types for the entire app-interface schema, since we are only interested in query results
 * Create an SDK for Golang integrations

## Proposal

Use a code generator to generate Go client packages. This code generator leverages GraphQL schema definition files and GraphQL query definition files to generate the required client code. 

Code generator of choice is [Khan/genclient](https://github.com/Khan/genqlient). Code generation here is based on the graphql schema file. It has some benefits:
 * Queries are checked against GraphQL schema without running the code
 * Type safety is checked during compile time
 * Only need to be concerned about the query, the rest of the code is generated and ready to go

To use this generator, three configuration files are required:
 *  `qenqclient.graphql`: Contains GraphQL queries the integration is using.
 *  `genqclient.yaml`: Configuration file for the genqlient utility.
 *  `schema.graphql`: Schema definition in GraphQL [schema language](https://graphql.org/learn/schema/#type-language) ([graphql-schemas/schema.yml](https://github.com/app-sre/qontract-schemas/blob/main/graphql-schemas/schema.yml) is not compatible)

### Generating `schema.graphql`

As of writing this document, our GraphQL API is not using the GraphQL schema language. However, this is a strict requirement to use this code generator.

Luckily there are tools to generate this file from a given GraphQL endpoint:
 * https://www.graphql-cli.com/codegen/ 
 * https://github.com/prisma-labs/get-graphql-schema (deprecated, but works)

These tools will fetch the schema from the API and generate the `schema.graphql` file. 

On changing the schema, this schema file can be generated in a pipeline and used to check if any go integration would break by running the code generator. By this, the blast radius of schema changes can be reduced.

## Alternatives considered

* Creating structs for unmarshalling on our own, like done in [vault-manager](https://github.com/app-sre/vault-manager/)
* Other code generators listed here https://graphql.org/code/#go/

## Milestones

* tbd
