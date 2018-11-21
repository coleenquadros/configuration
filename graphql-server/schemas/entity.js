const db = require('../models/db');
const base = require('./base');

const typeDefs = `
  union Entity = User | Bot
`
const resolvers = {
  Entity: {
    __resolveType(root, context) {
      switch (root['$schema']) {
        case "access/user.yml":
          return "User";
          break;
        case "access/bot.yml":
          return "Bot";
          break;
      }
    }
  }
}

module.exports = {
  "typeDefs": typeDefs,
  "resolvers": resolvers
};
