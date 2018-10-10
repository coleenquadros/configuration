const data = require('../models/data');

const resolvers = {
  Query: {
    namespace(root, args) {
      return data[args.name];
    },
    allNamespaces(root, args) {
      return Object.keys(data).map(n => data[n]);
    },
  },
  Namespace: {
    name(root, args) {
      return root._info.name;
    },
    instances(root, args) {
      return Object.keys(root["data"]).map(i => root["data"][i]);
    },
    items(root, args) {
      var instances;
      var items = [];

      if (typeof (args.instance != 'undefined')) {
        instances = [root["data"][args.instance]];
      } else {
        instances = Object.keys(root["data"]).map(i => root["data"][i]);
      }

      for (var instance of instances) {
        for (var item in instance["data"]) {
          var item = instance["data"][item];
          if (typeof (args.schema) != 'undefined') {
            if (item._info.schema == args.schema) {
              items.push(item);
            }
          } else {
            items.push(item);
          }
        }
      }

      return items;
    }
  },
  Instance: {
    name(root, args) {
      return root._info.name;
    },
    namespace(root, args) {
      return data[root._info.namespace];
    },
    items(root, args) {
      return Object.keys(root["data"]).map(i => root["data"][i]);
    }
  },
  Item: {
    name(root, args) {
      return root._info.name;
    },
    namespace(root, args) {
      return data[root._info.namespace];
    },
    instance(root, args) {
      return data[root._info.namespace]["data"][root._info.instance];
    },
    schema(root, args) {
      return root._info.schema;
    }
  }
}

module.exports = resolvers;
