# Catchpoint

## Catchpoint in a nutshell
Catchpoint is a monitoring tool that executes checks from a vantage point. It can
probe our services from various multiple places worldwide to discover problems.
Catchpoint provides various kinds of checks but the most used ones are Synthetics.
They simulate requests to applications and services to verify performance, availability
and reachability.

Synthetics are organized in a folder structure. Those folders are more than just organizational
grouping, they can hold configuration as well, that is inherted by all nested groups
and Synthetics. This can be used to apply common check intervals or common alerting rules
to a set of Synthetics. e.g. see "PNT/SD/SRES".

Checks are scheduled based on the "Target & Scheduling" settings. The most influential
settings are
* the set of nodes checks will run on
* the frequency of the checks
* the number of nodes to run the checks on during a frequency interval

e.g. if you pick "Continental United States Cloud Nodes" with a frequency of 5 minutes and
a node count of 3, a check will be executed at three different nodes in a window of 5 minutes.

The most important thing about a Synthetic is the check itself. When creating a Synthetic,
you can pick from a range of different check types, e.g. web checks for browser testing,
API checks to test for parsable responses and return codes, DNS checks, ping checks, ...
The definition of the check routine heavily depends on the chosen check.

## Create a Synthetic API check
The following process describes how to create an API Synthetic that will check
the returned content of a URL.

While this is specific for API checks, most steps apply to other check types as well.

* Log in to the Catchpoint portal https://portal.catchpoint.com/ via "Company Credentials (SSO)"
  and specify "redhat" as namespace
* Navigate to "Control Center" > "Synthetic"
* Go the to folder you want to create the Synthetic in, e.g. "PNT/SD/SRES" and click on
  on the "+ New" action and pick API check
* Choose Javascript as the script type and provide the following Javascript

```javascript
open("https://yakshaving.com/status")
var res = Catchpoint.extract('resp-content','(?s).*')
data = JSON.parse(res);
assert(data.yak_mood === "happy");
```

This example script fetches the contents of the URL, inherently checks for the statuscode
to be 2xx and expects a following JSON payload:

```json
{
    "yak_mood": "happy"
}
```

## Update a status page component with a Synthetic check
To use the results of the check as Synthetic check to flip the state of a status page
component, an alerting rule needs to be defined. For that, the automation email address for
a status component is required.

* [Log into the status page](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/app-sre/statuspage.md)
and get the automation email address for the component that should be automated
* Back in Catchpoint, edit the Synthetic and enable alerting by activating "Inherit & Add Alerts"
* Use the automation email address as recipient
* Use the following expression for the subject
```
${switch('${NotificationLevelId}','0','DOWN','1','DOWN','3','UP')} - ${TestName} - CatchPoint Alert
```
* Add a simple alerting rule based on "Test Failure" specifying the number of failed runs
  that will trigger an alert

You can check about current alerts by navigating the left sidemenu to "Alerts" > "Alert Log".
To see how your test is doing in general, navigate the left sidemenu to "Analysis" > "Explorer" and
select your Synthetic. The scatterplot visualization nicely shows failed vs successful tests over time.

## Forward an alert to PagerDuty
Alerts from multiple Synthetics can be forwarded to a PagerDuty service. To integrate a PagerDuty service
as an alert target in Catchpoint, Catchpoint admin permissions are required. Permissions can be
granted by Artem Savenkov or Shane Newman.

To receive Catchpoint alerts on a PagerDuty service, it must have the Event API V2 integration enabled.
Extract the "Integration Key" and “Integration URL (Alert Events)” from that service.

Catchpoint alerts can be forwarded to PagerDuty with alert webhooks. For each PagerDuty service,
a dedicated alert webhook must be created because the required "Integration Key" is part of the template
used

* Navigate to "Settings" > "API" in the left sidemenu (admin permissions required)
* Click “Add URL” at the bottom of the “Alert Webhook” section
* Give the Alert Webhook a unique name like "AppSRE PagerDuty ${PagerDuty Service Name}"
* Copy the “Integration URL (Alert Events)” to the URL of the new web hook config
* Pick "Template" as format - scroll down and choose "Add New"
* Select JSON as template format and use the following as reference, specifying the "Integration Key"
  as `routing_key`

```json
{
  "routing_key": "$(pagerduty service integration key goes here)",
  "event_action": "${switch('${NotificationLevelId}','0','trigger','1','trigger','3','resolve')}",
  "dedup_key": "${TestId}",
  "client": "Catchpoint",
  "client_url": "${scatterplotChartURL}",
  "payload": {
    "summary": "[FIRING] ${TestName} is ${switch('${NotificationLevelId}','0','warning','1','critical','3','ok')}",
    "source": "Catchpoint",
    "severity": "${switch('${NotificationLevelId}','0','warning','1','critical','3','info')}",
    "class": "${displayTestTypeId}",
    "custom_details": {
      "alertCreatedUTC": "${alertCreateDateUtc}"
    }
  },
  "links": [
    {
      "href": "${testLink}",
      "text": "Catchpoint probe"
    },
    {
      "href": "${smartboardUrl}",
      "text": "Smartboard"
    },
    {
      "href": "${performanceChartURL}",
      "text": "Performance Chart"
    },
    {
      "href": "${scatterplotChartURL}",
      "text": "Scatterplot Chart"
    },
    {
      "href": "${waterfallChartURL}",
      "text": "Waterfall Chart"
    }
  ]
}
```
* save the template and save at the bottom of the API page

Once an alert webhook for a PagerDuty service has been created, it can be used for alerting in Synthetics
* Edit the Synthetic and enable alerting by activating "Inherit & Add Alerts"
* Use alert webhook for "API Endpoint"
* Setup a simple alert as described in the status page section

More information about PagerDuty and Catchpoint, the involved integration mechanisms and data formats can be
found here:
* PagerDuty event format - https://support.pagerduty.com/docs/pd-cef
* PagerDuty how to send alerts - https://developer.pagerduty.com/docs/ZG9jOjExMDI5NTgx-send-an-alert-event
* Catchpoint - PagerDuty integration guide - https://support.catchpoint.com/hc/en-us/articles/203351619
* Catchpoint makros usable in templates - https://support.catchpoint.com/hc/en-us/articles/210003423-Alert-Webhook-Macro-Index

## Send Synthetic metrics to SignalFX
Metrics about Synthetics can be forwarded to SignalFX for dashboarding or analytics.
To enable the forwarding, edit your Synthetic and enable "Test Data Webhook" in "More Settings".

To watch the metrics, go to https://redhat.signalfx.com and navigate to "Dashboards". Search for the "Synthetic Metrics"
dashboard. Use the Catchpoint Synthetic name as "TestName" in the filter to see metrics related to the check.

## Advanced alerts
todo
