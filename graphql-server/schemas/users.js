const db = require('../models/db');
const base = require('./base');

var typeDefs = `
  type Access implements DataFile {
    schema: String!
    labels: JSON
    teams: [AccessTeam]!
    roles: [AccessRole]!
  }

  type AccessTeam {
    name: String!
    members: [User]!
    roles: [AccessRole]!
  }

  type AccessRole {
    name: String!
    permissions: [AccessPermissions]!
  }

  interface AccessPermissions {
    service: String!
  }

  type AccessPermissionsGithub implements AccessPermissions {
    service: String!
    access_type: String!
    repo: String!
  }
`

var resolvers = {
  Access: base.dataFile(),
  AccessTeam: {
    roles(root, args, context, info) {
      var roles = [];

      for (role_ref of root["roles"]) {
        var role = base.resolve_jsonpathref(role_ref, context.datafile_path);
        roles.push(role);
      }

      return roles;
    },
    members(root, args, context, info) {
      var members = []

      for (member_ref of root["members"]) {
        var member = base.resolve_ref(member_ref, context.datafile_path);
        members.push(member);
      }

      return members;
    }
  },
  AccessPermissions: {
    __resolveType(root) {
      switch (root.service) {
        case "github":
          return "AccessPermissionsGithub";
          break;
      }
      return null;
    },
  },
}

module.exports = {
  "typeDefs": typeDefs,
  "resolvers": resolvers
};
