const db = require('../models/db');
const base = require('./base');

const typeDefs = `
  type Bot implements DataFile {
    schema: String!
    path: String!
    labels: JSON
    name: String!
    github_username: String
    owner: User
  }
`
const resolvers = {}

module.exports = {
  "typeDefs": typeDefs,
  "resolvers": resolvers
};
