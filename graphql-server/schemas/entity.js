const db = require('../models/db');
const base = require('./base');

const typeDefs = `
  union Entity_v1 = User_v1 | Bot_v1
`
const resolvers = {
  Entity_v1: {
    __resolveType(root, context) {
      switch (root['$schema']) {
        case "access/user.yml":
          return "User_v1";
          break;
        case "access/bot.yml":
          return "Bot_v1";
          break;
      }
    }
  }
}

module.exports = {
  "typeDefs": typeDefs,
  "resolvers": resolvers
};
