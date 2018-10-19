const db = require('../models/db');
const { JSONPath } = require('jsonpath-plus');

var path = require('path');

var dataFile = function (additionalResolvers = {}) {
  return Object.assign({
    schema(root, args) { return resolvers.DataFile.schema(root, args) },
  }, additionalResolvers);
}

/**
 * Splits a $jsonpathref in the path and jsonpath components
 *
 * @param {string} jsonpathref The jsonpathref as specified in the datafile
 * @returns {Object} Object with two elements: path and jsonpath
 */
var split_jsonpathref = function (jsonpathref) {
  var datafile_path = /^[^$]*/.exec(jsonpathref)[0];
  var jsonpath = /\$.+$/.exec(jsonpathref)[0];

  // canonicalize the path: '' => '.'
  datafile_path = path.join(datafile_path);

  return { path: datafile_path, jsonpath: jsonpath };
}

/**
 * Returns the data pointed by a jsonpathref
 *
 * @param {Object} item_ref The item that holds the reference. Must have a
 * `$jsonpathref` key
 * @param {string}  datafile_path The path of the source datafile
 * @returns {Object} Resolved data
 */
var resolve_jsonpathref = function(item_ref, datafile_path) {
  var target_datafile_path;
  var s = split_jsonpathref(item_ref['$jsonpathref']);

  if (s.path == '.') {
    target_datafile_path = datafile_path;
  } else {
    target_datafile_path = path.join(path.dirname(datafile_path), s.path);
  }

  var datafile = db.datafile[target_datafile_path];
  return JSONPath({ path: s.jsonpath, json: datafile })[0];
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
      context.datafile_path = root['path'];

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
  UsersTeam: {
    roles(root, args, context, info) {
      var roles = [];

      for (role_ref of root["roles"]) {
        var role = resolve_jsonpathref(role_ref, context.datafile_path);
        roles.push(role);
      }
      return roles;
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

module.exports = resolvers;
