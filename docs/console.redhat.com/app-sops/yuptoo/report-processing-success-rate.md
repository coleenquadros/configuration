# Yuptoo - report processing success rate

SLI description
With this SLI we are measuring the number of successful (or unsuccessful due to user error) processing of reports/archive. We aim for 95% of our reports to be processed successfully.

Implementation details
To measure the success rate of the SLO we are using two custom metrics yuptoo_report_processing_exceptions_total, which counts the number of internal errors, and yuptoo_archive_downloaded_success_total, which is the total number of reports download from S3.  The success rate is then measured by subtracting the ratio of the two metrics from 1 i.e. 1 - (yuptoo_report_processing_exceptions_total/yuptoo_archive_downloaded_success_total).

SLO Rationale
The success rate for report processing is significantly higher, we have set the SLO target to 95%. This target is subject to change and may be adjusted in the future should the success rate change with increase traffic.

Alerts
We have alert rule for this in rules file - /insights-prod/yuptoo-prod/yuptoo.prometheusrules.yaml

## Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/yuptoo/app.yml
