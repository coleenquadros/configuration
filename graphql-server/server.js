const { GraphQLServer } = require('graphql-yoga')
const merge = require('lodash/merge');

var schemaFiles = [
    'base',
    'user',
    'access',
]

var typeDefs = [];
var resolvers = {};

for (schema of schemaFiles) {
    var schemaItem = require(`./schemas/${schema}`);
    typeDefs.push(schemaItem.typeDefs);
    resolvers = merge(resolvers, schemaItem.resolvers)
}

const server = new GraphQLServer({
    typeDefs: typeDefs,
    resolvers: resolvers,
});

server.start(() => console.log('Server is running on localhost:4000'))
