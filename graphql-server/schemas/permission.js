const db = require('../models/db');
const base = require('./base');

const typeDefs = `
  interface Permission {
    service: String!
  }

  type PermissionAWSAnalytics implements Permission {
    service: String!
  }

  type PermissionGithubOrg implements Permission {
    service: String!
    org: String!
  }

  type PermissionGithubOrgTeam implements Permission {
    service: String!
    org: String!
    team: String!
  }

  type PermissionOpenshiftRolebinding implements Permission {
    service: String!
    cluster: String!
    namespace: String!
    permission: String!
  }

  type PermissionQuayOrg implements Permission {
    service: String!
    org: String!
  }
`
const resolvers = {
    Permission: {
      __resolveType(root, context) {
        switch (root['service']) {
          case "aws-analytics":
            return "PermissionAWSAnalytics";
            break;
          case "github-org":
            return "PermissionGithubOrg";
            break;
          case "github-org-team":
            return "PermissionGithubOrgTeam";
            break;
          case "openshift-rolebinding":
            return "PermissionOpenshiftRolebinding";
            break;
          case "quay-org":
            return "PermissionQuayOrg";
            break;
        }
      }
    }

}

module.exports = {
    "typeDefs": typeDefs,
    "resolvers": resolvers
};
