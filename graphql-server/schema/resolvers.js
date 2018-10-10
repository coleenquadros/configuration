const data = require('../models/data');

var interfaceItem = function (additionalResolvers = {}) {
  return Object.assign({
    name(root, args) { return resolvers.Item.name(root, args) },
    namespace(root, args) { return resolvers.Item.namespace(root, args) },
    instance(root, args) { return resolvers.Item.instance(root, args) },
    schema(root, args) { return resolvers.Item.schema(root, args) },
  }, additionalResolvers);
}

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

      if (typeof (args.instance) != 'undefined') {
        instances = [root["data"][args.instance]];
      } else {
        instances = Object.keys(root["data"]).map(i => root["data"][i]);
      }

      for (var instance of instances) {
        for (var item in instance["data"]) {
          var item = instance["data"][item];
          if (typeof (args.schema) == 'undefined' || args.schema == item._info.schema) {
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
    __resolveType(root, context) {
      context.item = root;
      switch (root._info.schema) {
        case "users/users.yml":
          return "Users";
          break;
      }
      return null;
    },
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
  },
  // users/users.yml
  Users: interfaceItem({
    teams(root, args) {
      return root["data"]["teams"];
    },
    roles(root, args) {
      return root["data"]["roles"];
    }
  }),
  UsersTeam: {
    roles(root, arg, context) {
      var roles = [];
      for (role of context.item["data"]["roles"]) {
        if (root.roles.includes(role.name)) {
          roles.push(role);
        }
      }
      return roles;
    }
  },
  UsersRole: {},
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
  UsersPermissionsGithub: {}
}

module.exports = resolvers;
