const { GraphQLServer } = require('graphql-yoga')
const merge = require('lodash/merge');

const base = require('./schema/base');
const user = require('./schema/user');
const users = require('./schema/users');

const server = new GraphQLServer({
    typeDefs: [
        base.typeDefs,
        user.typeDefs,
        users.typeDefs,
    ],
    resolvers: merge(
        base.resolvers,
        user.resolvers,
        users.resolvers,
    )
})

server.start(() => console.log('Server is running on localhost:4000'))
