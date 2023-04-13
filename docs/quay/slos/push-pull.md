# Push/pull SLO

### SLI description
This value measures the success rate of pushs to and pulls from quay.io in the North American region.

### SLI rationale
Quay's critical function is pushing and pulling images, so it is important that this SLO is tracked.

### Implementation details
Data is tracked via Quay's [catchpoint](https://gitlab.cee.redhat.com/service/app-interface/-/blob/master/docs/quay/sop/quay-catchpoint-failure.md) tests. 
So far, only data from the North American region is 
tracked and alerted on.

### SLO rationale
For Quay's most fundamental feature, an SLO of 99.9% is appropriate
