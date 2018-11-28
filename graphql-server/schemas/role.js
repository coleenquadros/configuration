const db = require('../models/db');
const base = require('./base');
const { JSONPath } = require('jsonpath-plus');
const _ = require('lodash');

const typeDefs = `
  type Role implements DataFile {
    schema: String!
    path: String!
    labels: JSON
    name: String!
    members: [Entity]!
    permissions: [Permission]!
  }
`
const resolvers = {
  Role: {
    members(root, args, context, info) {
      // TODO: this is not acceptable, it requires absolute paths
      let jsonpath = `$.roles[?(@["$ref"]=="/${root.path}")]`;
      let users = db.schemaInFilter(["access/user.yml", "access/bot.yml"]);
      return _.filter(users, user => JSONPath({ json: user, path: jsonpath }).length > 0);
    },
  },
}

module.exports = {
  "typeDefs": typeDefs,
  "resolvers": resolvers
};
