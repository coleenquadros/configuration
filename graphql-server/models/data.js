const fs = require('fs');
const yaml = require('js-yaml');
const path = require('path');

const rootDir = '../data/';
var data = {};

var setDefault = function (obj, key, val) {
  if (typeof (obj[key]) == 'undefined') {
    obj[key] = val;
  }
}

var infoData = function (info, data) {
  return {
    "_info": info,
    "data": data
  };
}

for (namespace of fs.readdirSync(rootDir)) {
  var namespace_path = path.join(rootDir, namespace);

  if (fs.lstatSync(namespace_path).isDirectory()) {
    for (instance of fs.readdirSync(namespace_path)) {
      var instance_path = path.join(namespace_path, instance);

      if (fs.lstatSync(instance_path).isDirectory()) {
        for (item of fs.readdirSync(instance_path)) {
          var item_path = path.join(instance_path, item);

          if (fs.lstatSync(item_path).isFile()) {
            var item_raw = fs.readFileSync(item_path, 'utf8');
            var item_data;

            if (item_path.match(/\.ya?ml$/)) {
              item_data = yaml.safeLoad(item_raw);
            } else if (item_path.match(/\.json$/)) {
              item_data = JSON.parse(item_raw);
            }

            if (item_data != null) {
              var ns_info = {
                name: namespace,
                namespace: namespace,
                kind: 'namespace'
              };

              var instance_info = {
                name: instance,
                namespace: namespace,
                instance: instance,
                kind: 'instance'
              };

              var item_info = {
                name: item,
                namespace: namespace,
                instance: instance,
                item: item,
                schema: item_data['$schema'],
                kind: 'item'
              };

              setDefault(data, namespace, infoData(ns_info, {}));
              setDefault(data[namespace]["data"], instance, infoData(instance_info, {}));
              setDefault(data[namespace]["data"][instance]["data"], item, infoData(item_info, item_data));
            }
          }
        }
      }
    }
  }
}

module.exports = data;
