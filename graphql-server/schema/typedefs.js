const typeDefs = `
  scalar JSON

  type Query {
    datafile(label: JSON, schemaIn: [String]): [DataFile]
  }

  interface DataFile {
    schema: String!
    labels: JSON
  }

  type DataFileGeneric implements DataFile {
    schema: String!
    labels: JSON
  }

  type User implements DataFile {
    schema: String!
    labels: JSON
    name: String!
    redhat_username: String!
    github_username: String!
  }

  type Users implements DataFile {
    schema: String!
    labels: JSON
    teams: [UsersTeam]!
    roles: [UsersRole]!
  }

  type UsersTeam {
    name: String!
    members: [User]!
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
