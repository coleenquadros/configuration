# Design doc: AppSRE initiatives

## Author/date

Maor Friedman / 2022-05-20

## Tracking JIRA

https://issues.redhat.com/browse/APPSRE-5617

## Problem Statement

AppSRE follows long term, wide impact goals. These goals do not fit the design doc approach, since they are wider and would require several design docs.

In addition, we currently lack an ability to define dependencies between different work items in a human readable form. This means it is difficult to display (or find) long term plans that may affect additional work.

## Goals

Define a process to plan and execute on long term plans. The proposed name for this process is an Initiative.

## Non-objectives

* Define the AppSRE roadmap.

## Proposal

As we grow as a team, we need to be able to plan our work properly, under constraints we do not always control. Some examples would be: onboardings, emergencies, external requests, etc. In our reality, we encounter situations where new work items get higher priority compared to a long term goal.

An Initiative is a process that will allow us to build long term plans collaboratively and asynchronously and to share context and knowledge. It is intended to provide a way to structure a set of work items in a sequential form that can be executed step by step.

You may find the terms "step by step" and "sequential" to be strange in a world of sharded threaded integrations. What is stopping us from working on all work items of an initiative all at once?

The short answer is - nothing. The long answer is -

When a lot of effort is spent at the same time on related areas, with multiple "drop everything" events, or even only the routine IC shifts, we are being less agile. Instead of providing useful functionality in iterations, we are working in an approach more similar to "feature completeness" in a single iteration.

Making a lot of significant changes to related areas at the same time also makes it harder for team members to follow the changes.

To summarize so far, working in parallel on related areas means our delivery is slow, and our predictability is low.

For that reason, we need to slow down. Yes, slow down, that is not a typo. If we were able to plan our work and execute sequentially, with each iteration providing value, we will -
* become more agile
* be able to better predict our delivery
* be able to plan even longer term items (ROADMAP!)

To summarize the proposal:

During the proces of grooming a work item, if it -
* carries a wide impact on how the team operates
* includes multiple steps towards a goal
* is too wide for a single design doc

We will create an Initiative.

An initiative is essentially a high level design document that lays down a plan. Each step of that plan will have a design doc of itself, all referencing the initiative. An initiative document will be submitted in the form of a merge request to app-interface (under docs/app-sre/initiative), and will follow the same review guidelines as a design document. The structure of an initiative document will be the same as that of a design doc, except that each Milestone will end up as a design doc.

## Alternatives considered

* Keep doing what we are doing; separate design docs with no higher level understanding of dependencies, design or process. Use jira links between tickets to illustrate order.

## Milestones

1. Approve Initiative process.
