const typeDefs = `
  type Query {
    namespace(name: String!): Namespace
    allNamespaces: [Namespace]!
  }

  type Namespace {
    name: String!
    instances: [Instance]!
    items(instance: String, schema: String): [Item]!
  }

  type Instance {
    name: String!
    namespace: Namespace!
    items: [Item]!
  }

  type Item {
    name: String!
    namespace: Namespace!
    instance: Instance!
    schema: String!
  }
`

module.exports = typeDefs;
