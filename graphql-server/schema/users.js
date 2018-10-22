const db = require('../models/db');
const base = require('./base');

var typeDefs = `
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

var resolvers = {
  Users: base.dataFile(),
  UsersTeam: {
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
  UsersPermissions: {
    __resolveType(root) {
      switch (root.service) {
        case "github":
          return "UsersPermissionsGithub";
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
