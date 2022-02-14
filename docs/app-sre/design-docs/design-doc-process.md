## Authors

-   [<u>Guillaume Pont</u>](mailto:gpont@redhat.com)

-   [<u>Rafa Porres Molina</u>](mailto:rporresm@redhat.com)

## Date

Oct 4, 2021

## Objectives of the design doc process

-   Create a tool to build solutions collaboratively and asynchronously  for app-sre team

-   Fill some of our documentation gaps

    -   Create point in time feature documentation that helps understand development by providing context and technical specifications.

    -   Sharing context and knowledge around main developments

-   Ensure design choices are taken and signed off in a timely manner

## Non-objectives

-   Design docs won't be updated

-   Design docs are not meant to replace app-sre internal technical documentation.

## Design doc process

### Trigger

There is no deterministic way to decide if a given Jira card will
require a design doc. This will be part of the grooming process. If the
grooming group states a ticket requires a design doc, it will be added
to the Acceptance Criteria for the ticket.

### Building the design doc

When a team member picks up a ticket with a design doc AC, they become
responsible for the design doc itself. The design doc structure will be
described in a later section.

Writing the design doc is not necessarily an individual effort, the
ticket owner is free to share it, discuss it with other team members
before submitting it for the team's review.

*Note: while writing this document, it might be helpful to start writing
some code or prototyping. However, as long as the design doc has not
been reviewed and accepted, all of this might have to be discarded!*

Once ready, the ticket owner will submit the document for review to the
team by using the sd-app-sre mail list. (ticket owner is free to
announce it in other channels as well)

### Reviews

As a general rule, the approval process should not last more than 5
working days from the submission date.

Once submitted, every team member is encouraged to review the design
doc, provide feedback and a ‘lgtm if approved.. Those reviews are
happening asynchronously.

Ticket owner is responsible for getting these reviews and processing the
comments, either incorporating them in the doc or addressing them in the
dedicated comment thread.

At the end of the approval period, we should be in one of the 2
following situations:

-   There is a general consensus on the proposal, comments have been incorporated, questions answered and no red flag remains. In that case, the ticket owner will confirm the approval of the design doc by sending a mail to sd-app-sre.

-   No consensus emerges (too many comments, a new proposal emerges, red flags ...). In that case, the ticket owner takes back the design doc to rework it (by sending a mail to sd-app-sre). They might engage further with reviewers to work on another proposal. If some facilitation is needed, managers can be involved and the technical lead or stream leads will have a quality vote to unblock
    disagreements.

### Acceptance

Once approved, the team de facto commits to the proposed design and
implementation can start.

Design doc will be persisted (more details in the dedicated section)

## Design doc structure

These are the sections that design docs will have. Once approved, a
template will be created containing the structure.

### Author / Date

### Tracking JIRA

### Problem Statement

-   What’s going on?

-   Why is it important?

-   Where is the problem?

### Goals

-   Describe technically what is going to be delivered with this proposal

-   If a metric/dashboard is provided as part of the goals, it’s even better

### Non-objectives

-   Describe technically what it is not going to be delivered

-   This is especially important to focus the conversations around the design doc

### Proposal

-   Ideally, it should be detailed enough that somebody who already understands the problem could go out and code the project without having to make any significant decisions.

-   The design doc should only include one proposal. If alternatives considered are worth mentioning, do it in the appropriate section.

### Alternatives considered

-   Add this section only if there are alternatives and if they are relevant

    -   Highlight why they were discarded in favor of the proposal

### Milestones

-   List all the different steps that will take to get the proposal running in production

## Design doc persistence

The proposal here is based on the following premises:

-   Design docs need to be persisted in a read-only manner to ensure they won’t be modified once approved.

-   Design docs may contain sensitive information which may prevent them to be public

-   Design docs should be easy to find so they should be in a central location.

-   Design docs discussions should be available for future reference.

Based on the above, the design doc proposals and discussions should be
done as pull requests in the app-interface repository, under
docs/app-sre/design-docs directory.

## Reviews

| date        | reviewer | comment |
|-------------|----------|---------|
| 2021-10-04  | jmelis   | LGTM!   |
| Oct 4, 2021 | patmarti | LGTM    |
| 2021-10-04  | mafriedm | LGTM!   |
| Oct 6, 2021 | goberlec | LGTM!   |

## NOTES

This document has been translated to GitHub flavored markdown from the original google doc in https://docs.google.com/document/d/1m_FL64n2nnpAeiu9T1JYzJYzRdSoCOln4fGIQb9dteo/edit#heading=h.tfx8o4gr1tai
