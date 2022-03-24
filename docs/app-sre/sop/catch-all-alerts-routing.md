## Catch-all Alerts Routing

When performing an SRE checkpoint, we validate that the service meets some best practices and validations using Dash.db: https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/content/process/sre_checkpoints.md

A part of that process is to look at a Grafana dashboard containing data from DVO ([example](https://grafana.app-sre.devshift.net/d/dashdotdb/dash-db?orgId=1&var-datasource=dashdotdb-rds&var-cluster=appsres03ue1&var-namespace=app-interface-stage)), and essentially copy paste what we see there into a ticket on the tenant's Jira board. This is a human process because it is not easy to (automatically) determine what namespace to look at, and how to associate that with the correct Jira board.

This is a single example for a repeating problem - how do we associate "catch-all" issues to a specific tenant and to their Jira board? or any other communication mechanism for that matter. Another example to explain a "catch-all" issue is RDS related alerts. Since we are using cloudwatch-exporter, it is not trivial to associate a database identifier showing an issue (out of burst balance for example) back to a Jira board.

A human can get an alert, dig through app-interface to find the related namespace, the related app, and how to get in touch with the team in case of issues, or in the SRE checkpoint case - create a ticket on their board.

These two examples also share a similar behavior - metrics. RDS alerts come from metrics and DVO dashboards come from metrics. So our problem is really associating a metric to a tenant. Each such metric should include a label that (using app-interface data) can lead back to a specific service and to their Jira board (escalation policy really).

To take the two examples and solve them as one, let's imagine we have created one giant DVO catch-all alert that alerts AppSRE on every issue in every namespace on every cluster. Much like the RDS alerts, where AppSRE gets alerted for every DB in every account (which we monitor).

At this point, we have catch-all alerts, and a human acts on these alerts.


An alternative to catch-all alerts is a collection of an alert per resource to be monitored. In the RDS case - an alert per databse. And in the DVO case - an alert per namespace. This is obviously not feasable for a human to create or maintain, but if we have per-resource alerts, we can route them directly to the tenant instead of acting on them ourselves.

The only way to generate per-resource alerts is to do it based on data in app-interface. Taking DVO as an example - (For each cluster) For each namespace, create an alert on DVO metrics that is routed to the tenant's jira board (via jiralert).


To generate per-resource alerts, one would need to use the `query` built-in function of openshift-resources (as documented [here](/README.md#manage-openshift-resources-via-app-interface-openshiftnamespace-1yml)) with a custom query. The templating should include logic to decide on the data to use according to the graphql query results.

Examples:
1. [Generate Jiralert related AlertManager configuration](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/36052/diffs?commit_id=40070af0e0ac02b2b9067ce4aa123e55daa7943d)
1. [Generate DVO alerts which are automatically routed to a tenant's jira board](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/36096/diffs?commit_id=d7ab037ad084fae6a81e9cc8e904388fe5b51a3a)
