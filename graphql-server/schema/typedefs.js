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

  interface Item {
    name: String!
    namespace: Namespace!
    instance: Instance!
    schema: String!
  }

  type Users implements Item {
    name: String!
    namespace: Namespace!
    instance: Instance!
    schema: String!
    teams: [UsersTeam]!
    roles: [UsersRole]!
  }

  type UsersTeam {
    name: String!
    members: [String]!
    roles: [UsersRole]!
  }

  type UsersRole {
    name: String!
    permissions: [UsersPermissions]!
  }

  interface UsersPermissions {
    service: String!
  }

  type UsersPermissionsGithub implements UsersPermissions {
    service: String!
    access_type: String!
    repo: String!
  }
`

module.exports = typeDefs;
