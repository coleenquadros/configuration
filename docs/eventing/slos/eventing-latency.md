## SLI description
We are measuring the event handling success rate and the kafka lag for events.

## SLI Rationale
The Eventing service takes events off of the tocamel Kafka topic placed there by Notifications service, transforms them as necessary, and sends them on to Splunk, or other third party services before sending a success message back on the fromcamel Kafka topic.

## Implementation details
We count the number of successfully handled events as a ratio out of the total events processed to reach a percentage
success rate on our Grafana: https://grafana.app-sre.devshift.net/d/eventing/eventing-integrations?orgId=1&var-interval=10m&var-datasource=crcp01ue1-prometheus&from=now-2d&to=now

We also track the kafka lag which can have a max of one second lag per message per event.

## SLO Rationale
The vast majority of events are handled without issue in typically 98% or 100% success rates.  We have set alerts like
 other services if this dips below 90% for a length of time.  This is particularly important as we are not an api that
 can be queried again; we are sending critical notifications once to third party services that customers might not otherwise see without visiting their Insights Dashboard.

Events should empty from the kafka topic in a timely manner.  If it takes each event longer than one second per message, we want to be alerted as this could indicate a problem early before it starts effecting the handled success rate above which would impact the customers.

## Alerts
We have set up Alerts for both handled event success rate and kafka lag over in https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/resources/insights-prod/eventing-prod/eventing-prometheusrules.yaml
