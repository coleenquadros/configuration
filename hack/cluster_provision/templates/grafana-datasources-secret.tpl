---
apiVersion: v1
kind: Secret
metadata:
  name: grafana-datasources
  annotations:
    qontract.recycle: "true"
    qontract.ignore_reconcile_time: "true"
data:
  datasources.yaml:
    {{{{% b64encode %}}}}
{datasources}
    {{{{% endb64encode %}}}}
