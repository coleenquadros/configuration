const fs = require('fs');
const yaml = require('js-yaml');
const path = require('path');

// Load the data
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

const { GraphQLServer } = require('graphql-yoga')

const typeDefs = `
  type Query {
    namespace(name: String!): Namespace
    allNamespaces: [Namespace]!
  }

  type Namespace {
    name: String!
    instances: [Instance]!
    items(instance: String, schema: String): [Item]!
  }

  type Instance {
    name: String!
    namespace: Namespace!
    items: [Item]!
  }

  type Item {
    name: String!
    namespace: Namespace!
    instance: Instance!
    schema: String!
  }
`

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

const server = new GraphQLServer({ typeDefs, resolvers })
server.start(() => console.log('Server is running on localhost:4000'))
