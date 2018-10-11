const dirTree = require('directory-tree');
const fs = require('fs');
const yaml = require('js-yaml');

const rootDir = '../data/';

var db = {
  "datafiles": [],
  "datafile": {},
  "labelFilter": function (label_filter, input_set) {
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
  },
  "schemaInFilter": function (schema_in_filter, input_set) {
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
};

const filteredTree = dirTree(rootDir, { extensions: /\.(ya?ml|json)$/ }, function (item, PATH) {
  var relativePath = item.path.slice(rootDir.length);
  var raw = fs.readFileSync(item.path);
  var data;

  if (item.path.match(/\.ya?ml$/)) {
    data = yaml.safeLoad(raw);
  } else if (item.path.match(/\.json$/)) {
    data = JSON.parse(raw);
  }

  db.datafiles.push(data);
  db.datafile[relativePath] = data;
});

module.exports = db;
