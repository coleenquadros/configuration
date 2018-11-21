const db = require('../models/db');
const hash = require('object-hash');
const _ = require('lodash');

var defaultResolver = function (root, args, context, info) {
  let datafileImplementations = info.schema._implementations.DataFile;
  let parentType = info.parentType;

  if (datafileImplementations.includes(parentType)) {
    // TODO: This `if` is a temporary hack. We need to define
    // `context.datafilePath = root.path;` but we must not reassign it every
    // time we shift to another datafile, because it will not revert back to the
    // previous value once we exit a nested field. This means that with the
    // current implementation would be able to resolve one `resolveRef` going to
    // another datafile, but not a second one.
    if (typeof (context.datafilePath) == "undefined") {
      context.datafilePath = root.path;
    }

    if (info.fieldName == "schema") {
      return root["$schema"];
    }
  }

  let val = root[info.fieldName];

  if (val.constructor === Array && val.length > 0) {
    if (!(_.map(val, (e) => db.isRef(e)).includes(false))) {
      let arrayResolve = _.map(val, (e) => db.resolveRef(e, context.datafilePath));
      if (String(info.returnType)[0]=="[") {
        return _.flattenDepth(arrayResolve, 1);
      }
      return arrayResolve;
    }

    return val;
  }

  if (db.isRef(val)) {
    val = db.resolveRef(itemRef, context.datafilePath);
  }

  return val;
}

var typeDefs = `
  scalar JSON

  type Query {
    datafile(label: JSON, schemaIn: [String]): [DataFile]

    # TODO: autogenerate for all types that implement DataFile
    access(label: JSON): [Access]
    user(label: JSON): [User]
    role(label: JSON): [Role]
  }

  interface DataFile {
    schema: String!
    path: String!
    labels: JSON
  }

  type DataFileGeneric implements DataFile {
    schema: String!
    path: String!
    labels: JSON
  }
`

var resolvers = {
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
    },

    // TODO: autogenerate for all types that implement DataFile
    access(root, args, context, info) {
      args.schemaIn = ["users/access.yml"];
      return resolvers.Query.datafile(root, args, context, info);
    },
    user(root, args, context, info) {
      args.schemaIn = ["users/user.yml"];
      return resolvers.Query.datafile(root, args, context, info);
    },
    role(root, args, context, info) {
      args.schemaIn = ["users/role.yml"];
      return resolvers.Query.datafile(root, args, context, info);
    }
  },
  DataFile: {
    __resolveType(root, context) {
      // TODO: autogenerate for all types that implement DataFile
      switch (root['$schema']) {
        case "users/access.yml":
          return "Access";
          break;
        case "users/user.yml":
          return "User";
          break;
        case "users/role.yml":
          return "Role";
          break;
      }
      return "DataFileGeneric";
    }
  }
}

module.exports = {
  "typeDefs": typeDefs,
  "resolvers": resolvers,
  "defaultResolver": defaultResolver,
};
