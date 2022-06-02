# App Interface review process

This is a WIP SOP intended for use by App SRE team members acting as Interrupt Catcher or just reviewing merge requests to app-interface.

## Process

1. Verify that build passes.
2. Verify that the `app-interface JSON validation` report is as expected due to the changes introduced in the MR.
3. Check specific review instructions (see [specific-review-instructions](#specific-review-instructions))
4. If any additional reviewers are required, ping them on the MR (see [additional-reviewers](#additional-reviewers)).
5. Once the MR looks good to you, add the `lgtm` label or comment `/label lgtm`. The MR will be merged automatically within minutes. See also the documented [approval process](/docs/app-sre/continuous-delivery-in-app-interface.md#approval-process)

## Notes

* Some merge requests will be created with an `automerge` label. No need to review or merge those.

## Specific review instructions

### InProgress Services

InProgress services are in the process of being onboarded. **@app-sre-ic** should only add the ~onboarding label to these MRs so that they can be reviewed by the **@app-sre-onboarding-ic**.

### saas-deploy image_pattern

This change indicates that an additional component will be allowed to be deployed to a production namespace.

Action items:
* verify the existence of a matching SOP for the additional component before merging

### saas-file-update

This means the changes are limited to saas file. And that usually does not need our involvement, i.e. we don't need to add any labels, tenant team can approve and merge among themselves.

### Insights

Insights MRs should be assigned to the MR and approved as follows:

- `OnBoarded` services - AppSRE
- `BestEffort` services - @bturner
- FedRAMP - @klape

**Note:** the reviewers above are able to add lgtm labels in GitLab

### Status Page Component
If a status page component is newly introduced by an MR, check if the `displayName` references only an existing component on the status page.
If that is the case, the app-interface managed component will take ownership of the existing component on the page. Check the `app-1.yml` that
references the `status-page-component-1.yml` and verify that this is legit.

On status.redhat.com, components are mostly placed in the existing groups depending on top level redhat.com domain they belong to. If a
component should be placed outside of any groups, check for the reasons.

## Additional Reviewers

In general when anyone ask for access to tenant's resource, even if it's in lower environments, it's standard procedure to ask approval from the owner of the service.

### Telemeter access

Access to Telemeter is approved by the telemetry-sme list: telemetry-sme <telemetry-sme@redhat.com> 

The best way to request access is to email that list, point at the MR and ask for approval.

### Insights cluster access

The following folks can be asked to review MR when in doubt:

```
- @klape
- @bturner
- @mafriedm
```

### Managed services access

Access to Managed Services should be approved by one of the following:

```
- @weil
- @stobin
- @dbizzarr
```
