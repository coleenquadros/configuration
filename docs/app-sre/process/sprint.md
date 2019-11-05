# Sprint Guidelines

## Sprint Warranty
These are the team values and standards we adhere to throughout this set of guidelines:
- We will keep track of all deliverable work in [Jira](https://jira.coreos.com)
  - Design notes should be stored in the shared [gdocs](https://drive.google.com/drive/u/1/folders/186ExLmi--buOzMLaiUnCkzzRYfwX_y9L) folder where appropriate (reference to these from Jira, where appropriate)
- We will continuously evaluate and refine our delivery process via the end-of-sprint retro
- We will commit to work that has been scoped and prioritized with respect to the needs of:
  - The organization via org-level epic briefs & arch-team guidance
  - By our team by capturing bug/feature/request input as stories

## Sprint Cadence
- Sprints follow a repeating cycle of: **Start|Commit** --> **Planning|Estimation** --> **Demo|Review|Retro**
- Sprint activity dates will be maintained by the team manager on the [App-SRE Sprints](TODO) calendar
  - Events that fall on days where the greater part of the team is unavailable will be moved to accommodate
  - Reminders for each phase of the sprint will be kept here
  - Each person can set up as little or as much notification they want or need for sprint-specific events through Google Calendar's notification settings

### Start (First Monday)
#### Planning (~60m BJN)
- We do a final review of stories on the staged sprint, pruning, adding, and scoring any unexpected last minute changes on a Bluejeans call
#### Kick-off!
- We commit, as a team, to the body of work and the team lead hits the start button
  - Upon pressing the start button, a fanfare of trumpets followed by a shower of confetti and balloons appears.
    - Just kidding, but keep this to yourself. This may be a trivia question to just see if you read this. Read words, win prizes!
- The sprint is 3 weeks in length

### Prep and Review (Final Wednesday-Thursday)
#### Estimation (Final Wednesday - Friday, Async)
- Final Wednesday, stories are staged into the next sprint placeholder ready for team-majority-derived estimation consensus
  - The team lead will bless the next sprint for the team to review
  - The team lead will record un-estimated stories from the staged sprint into the [estimation sheet](https://docs.google.com/spreadsheets/d/1FEsF60JY-advVvqe9CNCN7NlncR-ExnZeC9c-7V3Gq8/edit?usp=sharing)
  - Each team member should review and give a "beefiness" estimate of a story
  - To help support async-friendly estimation, we use a simplified estimation represenation:
    - **1** (SMALLINT) regular task / simple well-known work
    - **3** (INT) light complexity, maybe some unknowns
    - **5** (BIGINT) very complex, very involved, lots of unknowns
    - **13** (E_TOOBIG) needs to be broken down or significant further research is needed
      - eg: a spike is needed to better understand if a delivery is at all possible or the story is
        - ex: deliver an enterprise-grade kubernetes cluster platform
      - eg: the delivery itself has several smaller deliveries, story should be an epic and elaboration done to create smaller deliverable chunks as their own stories
    - Questions/discussions about each story can be surfaced in the comments of each story
      - (Most) Significant outstanding clarification should, ideally, be worked out before  Monday's planning session      
- Last Friday of the sprint estimation wraps up
  - The team lead will record rounded-up-average estimation scores into each story

### During the sprint
- Provide a daily summary of your activity on the [#sd-app-sre-daily](https://coreos.slack.com/messages/sd-app-sre-daily) Slack channel
  - This is in place of a daily face to face standup call, due to the async (*and often busy*) disposition of the App-SRE team
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
- Team will review a sprint burndown chart: accomplishments vs what we weren't able to complete
  - Total points committed vs completed
    - Review velocity, as a team are we trending up or down
      - Team should commit to improving expectations: such as commit to less up front, deflect blockers, make changes to processes, add features to reduce toil, etc.
  - Total stories committed/completed
    - Review how to reduce incompletes (ex: over-committed, blocked, pto, too beefy, etc)
  - Total stories added/removed
    - Review where we can improve on future planning
      - Removed, how to better prevent false-commits?
      - Added, how to better capture prior to sprint start?
- Team will provide feedback on the sprint
  - What worked? What didn't? What do we need to do differently?
  - Can also follow format: Continue, Stop, Start
  - Team should strive to capture activities that they find fulfilling or define us a team as well as raise items that do not bring joy/value
  - As a result of retro feedback, we should be capturing Jira stories into the backlog to action improvements
    - If the team decides to immediately take action on a retro-derived story in the next sprint
      - The story can be staged into the next sprint and then estimated immediately

# TODO subjects for future discussion/MR:
- Async-friendly retro process, ex: git issues?
- Async-friendly pre-commit planning process
- Epics vs stories; when to create an epic
- Writing a good story: ISBAT format, acceptance criteria (value delivery); writing stories is not about the how but the what we're trying to achieve
- Fifo-priority story ordering/grooming; highest priority at top, lowest bottom, weekly review (grooming)
- Team-board epic progress+priority view; how the, what the..
- Sprint metrics?
