# KubePersistentVolumeUsageCritical

## Severity: critical-fts

**This alert was defined by AppSRE and applies to PVs outside our team. It was not created by the tenant.** This alert should be removed in the future once it is confirmed that we have adequate coverage of service-specific alerts.

## Impact

The impact is very specific to the service (this is not a service-specific alert), so the impact will be unclear without contacting the tenant.

## Summary

A PersistentVolume is almost out of disk space.

## Access required

Access to the OSD clusters if we need to provide details to the tenant about what's using the disk space.

## Steps

1. Investigate which service is affected
2. Escalate to the tenant (using their escalation policy) to make them aware of the situation and to figure out the impact to the service
3. Follow-up with the team about whether they would like to be notified about this in the future. If so, **a service-specific alert should be created**. Have the team open a ticket to track the creation of this alert and make it clear to them that this alert is likely to go away in the future.

## Escalations

It should be emphasized again that this alert is not defined by tenants. It may not mean that their service is in danger of breaching their SLO. So, escalations should only happen during business hours unless there are other hints of service degradation.
