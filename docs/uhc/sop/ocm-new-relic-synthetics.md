# OCM New Relic Synthetic probe failing

## Severity: Critical

## Impact

OCM API potentially unavailable

## Summary

This alert uses the [OCM New Relic synthetics scripted monitor](https://one.newrelic.com/launcher/nr1-core.explorer?pane=eyJuZXJkbGV0SWQiOiJzeW50aGV0aWNzLW5lcmRsZXRzLm1vbml0b3Itb3ZlcnZpZXciLCJpc092ZXJ2aWV3Ijp0cnVlLCJyZWZlcnJlcnMiOnsibGF1bmNoZXJJZCI6InN5bnRoZXRpY3MtbmVyZGxldHMuaG9tZSIsIm5lcmRsZXRJZCI6InN5bnRoZXRpY3MtbmVyZGxldHMubW9uaXRvci1saXN0In0sImVudGl0eUlkIjoiTWpRd09USTVNSHhUV1U1VVNIeE5UMDVKVkU5U2ZEUXdPRGc0TmpObUxUVTFZamN0TkdVelpTMDVOakV6TFdNeFptWmhNRGs1WkROa01nIn0=&sidebars[0]=eyJuZXJkbGV0SWQiOiJucjEtY29yZS5hY3Rpb25zIiwiZW50aXR5SWQiOiJNalF3T1RJNU1IeFRXVTVVU0h4TlQwNUpWRTlTZkRRd09EZzROak5tTFRVMVlqY3ROR1V6WlMwNU5qRXpMV014Wm1aaE1EazVaRE5rTWciLCJzZWxlY3RlZE5lcmRsZXQiOnsibmVyZGxldElkIjoic3ludGhldGljcy1uZXJkbGV0cy5tb25pdG9yLW92ZXJ2aWV3IiwiaXNPdmVydmlldyI6dHJ1ZX19&platform[accountId]=2409290&platform[timeRange][duration]=1800000&platform[$isFallbackTimeRange]=true) to check if the [OCM clusters page](https://cloud.redhat.com/openshift/) in cloud.redhat.com from the app-sre is returning a list of clusters. If it can't, it means OCM API is having problems.

The monitor is used in [cloud.redhat.com-OCM New Relic policy](https://one.newrelic.com/launcher/nrai.launcher?pane=eyJuZXJkbGV0SWQiOiJhbGVydGluZy11aS1jbGFzc2ljLnBvbGljaWVzIiwibmF2IjoiUG9saWNpZXMiLCJwb2xpY3lJZCI6IjExMDU3OTAifQ&sidebars[0]=eyJuZXJkbGV0SWQiOiJucmFpLm5hdmlnYXRpb24tYmFyIiwibmF2IjoiUG9saWNpZXMifQ&platform[accountId]=2409290) that sends a mail to `app-sre-interrupts@redhat.pagerduty.com` when at least two of three location from where the monitor runs returns an error

## Access required

* [New Relic Synthetics](https://one.newrelic.com/launcher/synthetics-nerdlets.home?platform[accountId]=2409290)
* [OCM page in console.redhat.com](https://console.redhat.com/openshift) with your app-sre account

## Steps

* Check you can reproduce the error via login OCM page
* Log in the synthetics page and check the monitor for further information in the error
* Follow the [Clusters Service Down SOP](/docs/uhc/sop#clusters-service-down)
