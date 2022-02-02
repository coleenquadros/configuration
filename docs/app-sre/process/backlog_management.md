# Backlog management

## creating a ticket
Every team member is encouraged to create Jira tickets to either plan future team work or track ongoing unplanned work.
General guideline is everything taking more than a couple of hours of engineering time should be reflected in the team's backlog.
There are 2 Jira projects for AppSRE tasks (both are merged in a single backlog then)
  * [ASIC](https://issues.redhat.com/projects/ASIC/summary) should contain only tasks raised by IC and potential follow up items.
  * [AppSRE](https://issues.redhat.com/projects/APPSRE/summary) is the place for all of project work, onboarding tickets, internal improvement work (Toil reduction)

### description
Every ticket created should contain enough details for:
  * Team lead/Stream leads so they can assess urgency and priority
  * any team member to start working on it

To fulfil this, please focus on the following when creating the description for a ticket:
  * Write down a clear problem statement first. 
  * Do not focus on the solution you might envision when creating the description, as you might miss some details.  
  * Add Acceptence Criterias, so the Assigne can make sure, to fulfill the ticket. 

### ticket template
<create and then link a template in jira-cli/jira-sre/templates>

Once created, if there's any sense of urgency, the author might call out the ticket in one of our channels: #sd-app-sre-teamchat, mail to sd-app-sre or within their stream.

## grooming
Grooming's goal is to make sure all tickets comply with previous requirements (and template).

This process will be lead by stream leads on a weekly rotation: every week (starting on Wednesdays), a stream will be responsible for grooming new tickets and reviewing/ catching up on the existing ones. (Special attention to tickets raised by team members in one of the team's channel)

Once groomed, tickets complying with the guidelines will be flagged with a *groomed* label.

## prioritization
Goal is to highlight which of the groomed tickets are the next ones to be picked up by team members.

*Priority* field will be used in Jira to reflect this. General guideline is to have around a dozen of tickets highlighted.

This assessment is performed on a weekly basis by Steam leads and the Team lead. In case anything urgent pops up, any stream lead is empowered to update the priority of a ticket.

If an urgent ticket is becoming at risk, it will be assigned to a stream. Chosen Stream lead becomes responsible for the ticket (as they are for any other project work)
