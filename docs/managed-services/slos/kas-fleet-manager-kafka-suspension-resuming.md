# Kas Fleet Manager Kafka Resuming/Suspending SLO

## Description
Kafka suspension and resuming will not happen frequently, therefore it was decided that there will be no SLO (for now), as significant code changes to kas-fleet-manager would be required to send metrics to be used to calculate the SLO. 

If there is a strong demand to create such SLO, it will be done in the future.

For now there are alerts in place for kafkas that are stuck for too long in the suspending/ resuming state.

Suspension of a kafka instance should only take a few seconds (to sync the status from the Kas FleetShard Operator), hence an alert is set to fire after five minutes.

Resuming kafka instance should take similar time that it would normally take a kafka instance to be created (about 4-5 minutes on average), hence an alert will fire, if it takes more than 15 minutes for a kafka instance to resume.

## Alerts
The following are the alerts for resuming/ suspending kafkas:

- `KasFleetManagerKafkasStuckInSuspendingState - production`
- `KasFleetManagerKafkasStuckInSuspendingState - stage`
- `KasFleetManagerKafkasStuckInResumingState - production`
- `KasFleetManagerKafkasStuckInResumingState - stage`
