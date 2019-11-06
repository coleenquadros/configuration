# Sprint Guidelines

## Sprint Warranty
These are the team values and standards we adhere to throughout this set of guidelines:
- We will keep track of all deliverable work in [Jira](https://jira.coreos.com)
  - Design notes should be stored in the shared [gdocs](https://drive.google.com/drive/u/1/folders/186ExLmi--buOzMLaiUnCkzzRYfwX_y9L) folder where appropriate (reference to these from Jira, where appropriate)
- We will continuously evaluate and refine our delivery process via the end-of-sprint retro
- We will commit to work that has been scoped and prioritized with respect to the needs of:
  - The organization via org-level epic briefs & arch-team guidance
  - By our team by capturing bug/feature/request input as stories
- All the team members are responsible for the planning of the next sprint, and as such each member will add new stories to the future sprint throughout the whole active sprint.

## Sprint Cadence
- Sprints follow a repeating cycle of: **Planning|Estimation** --> **Start|Commit** -->  **Demo|Review|Retro**
- Sprint activity dates will be maintained by the team manager on the [App-SRE Sprints](TODO) calendar
- Sprint activity dates will be maintained by the team manager on the [App-SRE](https://calendar.google.com/calendar/embed?src=redhat.com_0pjkkmnhjs9e4b0h09st36rspc%40group.calendar.google.com) calendar.
  - Events that fall on days where the greater part of the team is unavailable will be moved to accommodate

### Start (First Monday)
#### Planning (~60m BJN)
- We do a final review of stories on the staged sprint, pruning, adding, and scoring any unexpected last minute changes on a Bluejeans call
#### Kick-off!
- We commit, as a team, to the body of work and the team lead hits the start button
  - Upon pressing the start button, a fanfare of trumpets followed by a shower of confetti and balloons appears.
    - Just kidding, but keep this to yourself. This may be a trivia question to just see if you read this. Read words, win prizes!
- The sprint is 3 weeks in length

### Prep and Review
#### Estimation (Final Thursday EOB, Async)
- Final Wednesday EOB is the deadline for stories to be staged for the next sprint
- Final Thursday EOB is the deadline for stories to be scored
- The team manager will record un-estimated stories from the staged sprint into the [estimation sheet](https://docs.google.com/spreadsheets/d/1FEsF60JY-advVvqe9CNCN7NlncR-ExnZeC9c-7V3Gq8/edit?usp=sharing)
- Each team member should score each story
- Scoring values:
  - **1** (SMALLINT) regular task / simple well-known work
  - **3** (INT) light complexity, maybe some unknowns
  - **5** (BIGINT) very complex, very involved, lots of unknowns
  - **13** (E_TOOBIG) needs to be broken down or significant further research is needed
- Questions/discussions about each story can be surfaced in the comments of each story
  - (Most) Significant outstanding clarification should, ideally, be worked out before Thursday EOB
- Last Friday of the sprint estimation wraps up
  - The manager will record rounded-up-average estimation scores into each story

### During the sprint
- Provide a daily summary of your activity on the [#sd-app-sre-daily](https://coreos.slack.com/messages/sd-app-sre-daily) Slack channel
  - Links to Jira stories or relevant documentation are extremely helpful but are voluntary
- Drag Jira stories from ToDo -> In Progress -> Review (where applicable) -> Done
  - Keyboard shortcut: type a period and then start typing the status, ooh.. ahh!
- Daily/Weekly review the backlog
  - Any stories that no longer make sense, should be deleted (don't use OBSOLETE status, this is eternal status limbo!)
  - Stories that should likely see movement in the next sprint should be re-positioned toward the top section of the backlog

#### Demo (Final Thursday, ~60m BJN)
- Demo will be recorded (Bluejeans) and hosted by the team manager
- Demo content must be kept to under 5 minutes, enforced by the team
- Demos should be a *demonstration* of what you can *do* (show the value) vs a technical review or code review

#### Retro (Final Thursday, ~60m BJN)
- Immediately follows demos
- Hosted by the team manager
  - Retro will be summarized and documented as a [Google doc](https://docs.google.com/document/d/1LFwp5KDmwVKzi3Ht8aMjL5jQr-aSS-J3ivkzjLtM44w/edit?usp=sharing)
- Each team member will review their sprint burndown chart: accomplishments vs what they weren't able to complete. 2 min per person.
- The team manager will review key metrics for the sprint: velocity, total stories, etc.
- The team manager create host an http://www.ideaboardz.com sync session in which team members can provide feedback for the sprint:
  - What worked? What didn't? What do we need to do differently?
- As a result of retro feedback, we should be capturing Jira stories into the backlog to action improvements

# TODO subjects for future discussion/MR:
- Async-friendly retro process, ex: git issues?
- Async-friendly pre-commit planning process
- Epics vs stories; when to create an epic
- Writing a good story: ISBAT format, acceptance criteria (value delivery); writing stories is not about the how but the what we're trying to achieve
- Fifo-priority story ordering/grooming; highest priority at top, lowest bottom, weekly review (grooming)
- Team-board epic progress+priority view; how the, what the..
- Sprint metrics?
