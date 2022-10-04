# Backlog maintenance sessions

## Clarifying some terms

### Grooming a ticket
This is the process of checking if a ticket is actionnable:
  * the ticket belong in AppSRE backlog
  * there's a clear problem statement
  * there are enough context/references
  * special Acceptance Criteria are defined if needed. (Defaults are SD epics ACs)

A ticket will be marked as `groomed` if is satisfies all of those criteria.
A `groomed` ticket should be workable by anyone in the team.

For tickets requiring more context, scoping or more discussion, use the label `needs-grooming` and when possible reassign it to either the logger or a lead. Be explicit on what is required and from whom. (an unassigned ticket might just get ignored)

### Prioritization
We are loosely using this term here.
Prioritization refers to selecting the set of tickets to be worked on next.
AppSRE leads will pick every week 10 `groomed` tickets to be added to the bounties board.

### Bounties
Bounties are the priority tickets for the upcoming week. They are selected at the end of grooming sessions by AppSRE leads.
List of bounties will be shared with the team at the start of every week. And a wrap up will be shared with the team at the end of the week.

## Grooming sessions
Backlog maintenance must be a recurring effort. A session will be scheduled every week by a manager, alternating EMEA and NASA timezones. The minimum audience for a grooming session to happen is a tech lead and a manager.
Those sessions will be 30 min long and published in AppSRE calendar.

Those sessions will be organized as follows:

### Grooming newly created tickets
Open `newly created tickets` [dashboard](https://issues.redhat.com/secure/Dashboard.jspa?selectPageId=12345266) and go through all the tickets.
For each of those:
  * if the ticket is workable, mark it as `groomed`
  * if not, reassign to logger for additional info or reject if the ticket doesn't belong in AppSRE backlog

We should not spend more than a couple of min on any given ticket. If the ticket needs work to become actionnable, this will have to be done asynchronously.

The following tickets does NOT have to be groomed:
  * DVO tickets: assign them directly to the stream lead owning the service (see assignments in app-interface). This work will be managed within the stream.
  * onboarding tickets: those tickets are already assigned to a stream. Work will be dispatched as regular stream work.
  * tickets belonging to an overarching epic: when a ticket belongs to an epic being worked by a stream, work will be handled by the stream.

A dashboard will come soon, in the meantime here's the query used :

`project = APPSRE AND created >= -8d AND assignee in (EMPTY) and status = "To Do" and labels != "groomed"`

### Grooming recently updated tickets
Same as with new tickets, but for tickets without a `groomed` label that received an update in the past week.
If time allows, we could even go further in the backlog and check older tickets.

Here is the query:
`project = APPSRE AND updated >= -8d AND assignee in (EMPTY) and status = "To Do" and labels != "groomed"`



The grooming will be time bound to 25min. If time allows, start reviewing older tickets.

### Bounties selection
Use the last 5 min of the session to pick up bounties.

query: `project = APPSRE AND assignee in (EMPTY) and status = "To Do" and labels = "groomed"`

Add the label `bounty` to the ones selected. At the end of the session, there should be 10 bounties.
`project = APPSRE AND assignee in (EMPTY) and status = "To Do" and labels = "bounty"`

##
