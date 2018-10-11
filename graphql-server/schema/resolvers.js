const db = require('../models/db');

var dataFile = function (additionalResolvers = {}) {
  return Object.assign({
    schema(root, args) { return resolvers.DataFile.schema(root, args) },
  }, additionalResolvers);
}

const resolvers = {
  Query: {
    datafile(root, args, context, info) {
      var datafiles = db.datafiles;

      if (args.label) {
        datafiles = db.labelFilter(args.label, datafiles);
      }

      if (args.schemaIn) {
        datafiles = db.schemaInFilter(args.schemaIn, datafiles);
      }

      return datafiles;
    }
  },
  DataFile: {
    __resolveType(root, context) {
      switch (root['$schema']) {
        case "users/users.yml":
          return "Users";
          break;
      }
      return "DataFileGeneric";
    },
    schema(root) { return root["$schema"]; }
  },
  DataFileGeneric: dataFile(),
  Users: dataFile(),
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

module.exports = resolvers;
