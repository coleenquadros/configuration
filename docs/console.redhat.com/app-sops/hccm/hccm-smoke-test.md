# Smoke Test

## Impact

If the following steps are not working the application is not usable by customers

## Summary

Check for service health by viewing the grafana dashboard to view backend processing. Check that the API is available.

## Access Required

Need access to the Grafana instance to view service health.

## Steps

- Check the dashboards
    - Grafana -> Insights -> Cost Management:  https://grafana.stage.devshift.net/d/R0HueuFGk/cost-management?orgId=1
        - Make sure the datasource & rdsdatasource are set to the production values: “crcp01ue1-prometheus” & “AWS insights-prod”
        - DB Stats -> CPU / Memory/ Disk looks healthy

    - Grafana -> Insights -> Strimzi Kafka: https://grafana.stage.devshift.net/d/8wCTC5Tmz/strimzi-kafka?orgId=1&var-kubernetes_namespace=platform-mq-prod&var-strimzi_cluster_name=platform-mq&var-kafka_broker=All&var-kafka_topic=platform.upload.announce&var-kafka_partition=All&var-datasource=crcp01ue1-prometheus
        - Select topic "platform.upload.announce" then Consumer Lag -> hccm-group group lag” is trending towards 0 (may need to look over more than 1 hour as there is a large batch job run each hour)
- Make sure API is routable:
```
curl https://console.redhat.com/api/cost-management/v1/openapi.json
```

## Escalations
-  https://visual-app-interface.devshift.net/services#/services/insights/hccm/app.yml
