# Smoke Test

## Impact

If the following steps are not working the application is not usable by customers

## Summary

Check for service health by viewing the grafana dashboard to view backend processing. Check that the API is available.

## Access Required

Need access to the Grafana instance to view service health.

## Steps

- Check the dashboard (grafana -> insights -> subscription watch)
https://grafana.stage.devshift.net/d/lkPhH-1Zk/subscription-watch?orgId=1&from=now-24h&to=now
    - Make sure the datasource & rdsdatasource are set to the production values: “crcp01ue1-prometheus” & “AWS insights-prod”
    - DB Stats -> BurstBalance % is above 0
    - Swatch-tally -> tally consumer group lag” is trending towards 0 (may need to look over more than 1 hour as there is a large batch job run each hour)
    - Billing Provider Integration -> all usage lag graphs are at 0 or trending towards within 1 hour window when batch jobs are triggered. 
- Make sure API is routable
curl https://console.redhat.com/api/rhsm-subscriptions/v1/openapi.json

## Escalations

https://visual-app-interface.devshift.net/services#/services/insights/rhsm/app.yml
