# Troubleshooting High Cardinality Metrics

This SOP covers troubleshooting cases where Prometheus is having performance issues
that are believed to be related to high cardinality series.

Series in Prometheus are a unique combination of a metric name and labels. You can read
more about the Prometheus data
model [here](https://prometheus.io/docs/concepts/data_model/). Performance issues
typically occur when labels are chosen that have a high cardinality (think account id
when there are many accounts).

The steps below should be helpful in determining whether the performance issue that
you're seeing is related to a large number of series.

1. Check the growth of the number of series by graphing the following
   query: `prometheus_tsdb_head_series{job="prometheus-app-sre"}`
    * An abrupt and large increase (100,000+ series) could indicate a metric with high
      cardinality being added by a tenant


2. Check the metrics with the highest cardinality by viewing a table
   of: `topk(10, count by (__name__)({__name__=~".+"}))`
    * Normally we expect somewhere around 10k series for the metrics with the highest
      cardinality
    * Very large numbers (>50k or even 100k+) probably mean that someone has added a
      label with high cardinality


3. Altering the query above slightly will allow us to determine which job is scraping
   these metrics: `topk(10, count by (__name__, job)({__name__=~".+"}))`
    * From here, you can check the **Targets** page on the Prometheus UI to search for
      the job name to find the `namespace` and `service` associated with the metrics.
      This will allow you to link back to a service owner using app-interface.
    * Note that these values could be lower than the query in the previous step if more
      than one job/tenant is using the same metric name


4. Notify the team who owns the Prometheus job immediately. Ask if any changes have been
   made to the labels on the metric recently. There are some different options for
   helping them figure out what the problematic label(s) are:
    1. `oc port-forward $POD_NAME :$METRIC_PORT` and open their metrics endpoint in your
       browser. Scrolling through the results might help identify the issue in the case
       of more obvious issues
    2. If you cannot quickly figure out the high cardinality label from above, use a
       query like this to get the number of unique values for a label
       name: `count(count by ($REPLACE_WITH_LABEL_NAME)($REPLACE_WITH_METRIC_NAME))` -
       an example being `count(count by (status_code)(some_http_metric))`
    3. The Prometheus UI also has a **TSDB Status** page that has a "Top 10 label names
       with value count" query that can be helpful, but this isn't linked to a specific
       metric, so may be less useful


5. There are a few different options for mitigating this issue:
    1. Notify the tenant and ask them to promptly rollback the change to the metrics if
       they are able to do so
    2. Use `metricRelabelings` to `drop` problematic metrics so that they're not
       scraped ([example MR](https://gitlab.cee.redhat.com/service/app-interface/-/merge_requests/48104/diffs))
       . This might be too much of a risk if the tenant uses this metric for critical
       alerts, but if the overall health of Prometheus is in question, it can be used.
    3. Use `metricRelabelings` to `labeldrop` certain labels while keeping the
       metric ([read more in docs](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#relabel_config))
       .
        * **Note**: the docs mention "Care must be taken with labeldrop and labelkeep to
          ensure that metrics are still uniquely labeled once the labels are removed."
          This will not be useful if the high cardinality metric is what makes the
          series unique, but probably more in cases where a large number of extra and
          unnecessary labels exist.

## Other resources

* [Cardinality is key article](https://www.robustperception.io/cardinality-is-key)
