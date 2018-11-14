const dirTree = require('directory-tree');
const fs = require('fs');
const yaml = require('js-yaml');
const path = require('path');
const jsonpointer = require('jsonpointer');
const { JSONPath } = require('jsonpath-plus');
const _ = require('lodash');

const rootDir = '../data/';

// utils

var isRef = function (obj) {
  if (obj.constructor === Object) {
    if (_.isEqual(_.keys(obj), ['$ref']) || _.isEqual(_.keys(obj), ['$jsonpathref'])) {
      return true;
    }
  }
  return false;
}

var getRefPath = function (ref) {
  return /^[^$]*/.exec(ref)[0];
}

var getRefExpr = function (ref) {
  m = /[$#].*/.exec(ref);
  return m ? m[0] : "";
}

var resolvePath = function (relPath, basePath) {
  if (relPath == '.' || relPath == "") {
    return basePath;
  } else if (relPath[0] == '/') {
    return relPath.substr(1);
  } else {
    return path.join(path.dirname(basePath), relPath);
  }
}

// filters

var schemaInFilter = function (schema_in_filter, input_set) {
  var datafiles;

  if (typeof (input_set) == "undefined") {
    datafiles = this.datafiles;
  } else {
    datafiles = input_set;
  }

  if (typeof (schema_in_filter) == "undefined") {
    return datafiles;
  }

  var match_datafiles = [];
  for (datafile of datafiles) {
    if (schema_in_filter.includes(datafile["$schema"])) {
      match_datafiles.push(datafile);
    }
  }

  return match_datafiles;
}

var labelFilter = function (label_filter, input_set) {
  var datafiles;

  if (typeof (input_set) == "undefined") {
    datafiles = this.datafiles;
  } else {
    datafiles = input_set;
  }

  if (typeof (label_filter) == "undefined") {
    return datafiles;
  }

  var match_datafiles = [];

  for (datafile of datafiles) {
    var datafile_labels = datafile["labels"];

    if (typeof (datafile_labels) == "undefined") {
      continue;
    }

    var match = true;

    for (var label in label_filter) {
      if (label_filter[label] != datafile_labels[label]) {
        match = false;
        break;
      }
    }

    if (match) {
      match_datafiles.push(datafile);
    }
  }

  return match_datafiles;
}

// main db object
var db = {
  // collect datafiles
  "datafiles": [],
  "datafile": {},

  // filter functions
  "labelFilter": labelFilter,
  "schemaInFilter": schemaInFilter,

  // utils
  "resolveRef": function (itemRef, datafilePath) {
    let ref, resolveFunc;

    if (ref = itemRef['$ref']) {
      resolveFunc = (d, e) => jsonpointer.get(d, e);
    } else if (ref = itemRef['$jsonpathref']) {
      resolveFunc = (d, e) => JSONPath({ json: d, path: e });
    } else {
      throw "Invalid ref object";
    }

    let path = getRefPath(ref);
    let expr = getRefExpr(ref);

    let targetDatafilePath = resolvePath(path, datafilePath);
    let datafile = db.datafile[targetDatafilePath];
    return resolveFunc(datafile, expr);
  },
  "isRef": isRef,
  "load": () => {
    db.datafile = {};
    db.datafiles = [];
    dirTree(rootDir, { extensions: /\.(ya?ml|json)$/ }, function (item, PATH) {
      var relativePath = item.path.slice(rootDir.length);
      var raw = fs.readFileSync(item.path);
      var data;

      if (item.path.match(/\.ya?ml$/)) {
        data = yaml.safeLoad(raw);
      } else if (item.path.match(/\.json$/)) {
        data = JSON.parse(raw);
      }

      data['path'] = relativePath;

      db.datafiles.push(data);
      db.datafile[relativePath] = data;
    });
  }
};

module.exports = db;
