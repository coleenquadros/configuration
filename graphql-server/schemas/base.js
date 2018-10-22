const db = require('../models/db');

var path = require('path');
const { JSONPath } = require('jsonpath-plus');
var jsonpointer = require('jsonpointer');

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
 * Splits a $ref in the path and jsonpointer/\#.+$/.exec(ref)
 *
 * @param {string} ref The ref as specified in the datafile
 * @returns {Object} Object with two elements: path and jsonpointer
 */
var split_ref = function (ref) {
  var datafile_path = /^[^#]*/.exec(ref)[0];

  try {
    var jsonpointer = /#(.+)$/.exec(ref)[1];
  } catch(err) {
    var jsonpointer = '';
  }

  // canonicalize the path: '' => '.'
  datafile_path = path.join(datafile_path);

  return { path: datafile_path, jsonpointer: jsonpointer };
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
  } else if (s.path[0] == '/') {
    target_datafile_path = s.path.substr(1);
  } else {
    target_datafile_path = path.join(path.dirname(datafile_path), s.path);
  }

  var datafile = db.datafile[target_datafile_path];
  return JSONPath({ path: s.jsonpath, json: datafile })[0];
}

/**
 * Returns the data pointed by a ref
 *
 * @param {Object} item_ref The item that holds the reference. Must have a
 * `$ref` key
 * @param {string}  datafile_path The path of the source datafile
 * @returns {Object} Resolved data
 */
var resolve_ref = function(item_ref, datafile_path) {
  var target_datafile_path;
  var s = split_ref(item_ref['$ref']);

  if (s.path == '.') {
    target_datafile_path = datafile_path;
  } else if (s.path[0] == '/') {
    target_datafile_path = s.path.substr(1);
  } else {
    target_datafile_path = path.join(path.dirname(datafile_path), s.path);
  }

  var datafile = db.datafile[target_datafile_path];

  return jsonpointer.get(datafile, s.jsonpointer);
}

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
`

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
      // TODO: return based on the schema or some `x-...` attr.

      context.datafile_path = root['path'];

      switch (root['$schema']) {
        case "users/access.yml":
          return "Access";
          break;
      }
      return "DataFileGeneric";
    },
    schema(root) { return root["$schema"]; }
  },
  DataFileGeneric: dataFile(),
}

module.exports = {
  "typeDefs": typeDefs,
  "resolvers": resolvers,
  "dataFile": dataFile,
  "resolve_jsonpathref": resolve_jsonpathref,
  "resolve_ref": resolve_ref,
};
