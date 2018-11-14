const db = require('../models/db');
const base = require('./base');
const _ = require('lodash');

var typeDefs = `
  type Access implements DataFile {
    schema: String!
    path: String!
    labels: JSON
    teams: [AccessTeam]!
    roles: [AccessRole]!
  }

  type AccessTeam {
    name: String!
    members: [User]
    permissions: [AccessPermission]!
  }

  type AccessRole {
    name: String!
    permissions: [AccessPermission]!
  }

  interface AccessPermission {
    service: String!
  }

  type AccessPermissionGithubOrg implements AccessPermission {
    service: String!
    org: String!
  }

  type AccessPermissionGithubOrgTeam implements AccessPermission {
    service: String!
    org: String!
    team: String!
  }
`

var resolvers = {
  AccessPermission: {
    __resolveType(root, context) {
      if (db.isRef(root)) {
        root = db.resolveRef(root, context.datafilePath);
      }
      // TODO: autogenerate for all permission types (json-schema enum?)
      switch (root.service) {
        case "github-org":
          return "AccessPermissionGithubOrg";
          break;
        case "github-org-team":
          return "AccessPermissionGithubOrgTeam";
          break;
        default:
          throw "Unknown service";
      }
    },
  }
}

module.exports = {
  "typeDefs": typeDefs,
  "resolvers": resolvers
};
