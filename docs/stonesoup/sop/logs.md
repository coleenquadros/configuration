# Cloudwatch logs and useful queries

## Pre-requisites

* [Gain access to view logs](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/stonesoup/sop/getting-access.md)

## Some common logging groups:

<!-- TODO provide more up-to-date example queries; at first it might be helpful to use these as a starting point

* [hacbss02ue1.hacbs-kcp-syncer](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.hacbs-kcp-syncer)))

* [hacbss02ue1.application-service](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.application-service)))
* [hacbss02ue1.build-service](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.build-service)))
* [hacbss02ue1.gitops](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.gitops)))
* [hacbss02ue1.integration-service](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.integration-service)))
* [hacbss02ue1.release-service](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.release-service)))
* [hacbss02ue1.spi-system](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.spi-system)))
* [hacbss02ue1.openshift-gitops](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.openshift-gitops)))
* [hacbss02ue1.openshift-pipelines](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights$3FqueryDetail$3D~(end~0~start~-3600~timeType~'RELATIVE~unit~'seconds~editorString~'~isLiveTail~false~queryId~'~source~(~'hacbss02ue1.openshift-pipelines)))

-->

## Example Queries

<!-- TODO provide more up-to-date example queries; at first it might be helpful to use these as a starting point

### KCP Syncer Watch Failures

```
fields @timestamp, @message
| sort @timestamp desc
| filter message like "Failed to watch"
| display message
```
-->
