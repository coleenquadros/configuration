# RhsmConduitValidationErrors
Severity: Medium

## Impact
An error was observed while processing a host.

## Summary
This alert fires when host data does not match defined schema and emits an error.

## Access required
Need access to the Kibana instance to view logs.
https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/

## Steps
-  Look in [HBI kibana search](https://kibana.apps.crcp01ue1.o9m8.p1.openshiftapps.com/app/kibana#/discover?_g=(refreshInterval:(pause:!t,value:0),time:(from:now-12h,mode:quick,to:now))&_a=(columns:!(_source),filters:!(),index:%2743c5fed0-d5ce-11ea-b58c-a7c95afd7a5d%27,interval:auto,query:(language:lucene,query:%27@log_stream:%20%22host-inventory-mq-*%22%20AND%20message:%20%22Validation%20error%20while%20adding%20or%20updating%20host%20%22%20AND%20host.reporter:%20%22rhsm-conduit%22%27),sort:!(%27@timestamp%27,desc))) ( and note the error message associated with the error message.  Check to see if there’s an open issue in the SWATCH project for it.  If there’s not an issue already for it then create one. E.g. for a message like
"Validation error while adding or updating host: {'system_profile': ["System profile does not conform to schema.\n'Unknown' is not a 'ipv4'\n\nFailed validating 'format' in schema['properties']['network_interfaces']['items']['properties']['ipv4_addresses']['items']:\n"

- Look for an open issue with either "system profile does not conform to schema" or "Unknown is not a 'ipv4'").
- Open a new bug at https://issues.redhat.com/secure/RapidBoard.jspa?projectKey=SWATCH, Priority: Major

## Escalations
https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml
