# Quickstart

Choose your adventure. What do you want to do?

I want to
* Plan a new feature
* Investigate a bug
* Review my code
* Research alternatives
* Teach Han (or Claude generally) about my app to optimize agent execution

## I want to plan a new feature

You have a feature idea, but you need help fleshing it out.

### What does my feature do?

Start by [planning a feature](../han-planning/docs/skills/plan-a-feature.md)

Optional side quest: [Generate a plan summary for a business stakeholder](../han-reporting/docs/skills/stakeholder-summary.md).

### How should I build it?

Start with [planning an implementation](../han-planning/docs/skills/plan-implementation.md).

We recommend [building your feature test-first](../han-coding/docs/skills/tdd.md).

Optional side quests:
- If you want to break your implementation down into smaller steps, Han can [generate work items](../han-planning/docs/skills/plan-work-items.md).
- If the implementation is large, Han can help you [plan a phased build](../han-planning/docs/skills/plan-a-phased-build.md), breaking your feature down into demoable slices.
- If, during implementation, you realize you need to change your plan, try [an iterative plan review](../han-planning/docs/skills/iterative-plan-review.md).

### Artifacts

Han will generate a `feature-specification.md` and a `feature-implementation-plan.md`.

If you had to change your plan, Han will document research findings and a decision log.

If your feature required a phased build, Han will generate a `build-phase-outline.md`.

Finally, if you built your features test-first, your code will have evolved behavior by behavior.

## I want to investigate a bug

Something in your code is broken or behaving oddly, and you want to know why.

### I don't know what's wrong

If you don't know what's wrong, start by [triaging the issue](https://github.com/testdouble/han/blob/main/han-research/docs/skills/issue-triage.md).

Examples of vaguely defined bugs appropriate for triage:
- The app is slow.
- There's something wrong.

Han will clarify the issue, classify it, assess its severity and reproducibility, and recommend next steps.

Possible recommendations include:
- Investigate: determine the cause of the error
- Research: find the answer to an error-related question
- Plan: add a missing feature

### I don't want to fix it now

You can copy the triage artifact into your issue tracker or ask Claude to do it for you.

```
Post the triage report as a GitHub issue in {owner/repo}.
```

### I know what's wrong, but I don't know how to fix it

Once you know the specific error, ask Han to [investigate](https://github.com/testdouble/han/blob/main/han-coding/docs/skills/investigate.md).

Examples of specific bugs appropriate for investigation:
- The `/products` page is returning a status code 500.
- The report generation worker is timing out.
- The database is returning a null constraint violation.
- The new product form intermittently fails to submit.

In your investigation prompt, reference additional context such as:
- Log files
- Error messages
- Stack traces
- Object IDs
- Timestamps or time ranges
- HTTP responses
- Screenshots

For example:
> ```/investigate Loading product with id 8f3a is returning a 500 error. The error started after a deploy on 2026-05-20. The stack trace is: {...}```

If the bug is visible in a UI, you can use a browser automation MCP server to tell Han how to reproduce the error.

> ```Use the browser integration to load /products, click on the product with id 8f3a, and capture the errors.```

Han will generate an investigation report including:
- Evidence
- A root cause
- A fix plan
- A review of the plan

If Han doesn't have enough evidence to determine a root cause, it'll ask for additional context. If you can fetch that data, pass it to Han and investigate again.

### I know what's wrong and I can fix it

Great! Follow the fix plan or ask Han to resolve the issue for you

If the fix plan looks like a new feature, you can ask Han to update your plan.

```
/iterative-plan-review {path to the investigation report}
```

If the error is likely to return, ask Han to generate a plan for the next time it happens.

```
/runbook Write a runbook for the bugfix I just completed
```

### Artifacts

- An investigation report identifying a root cause down to file names and line numbers.
- A plan to fix the bug.
- Optionally, a runbook for the next time the error recurs.

## I want to review my code

I want feedback on code that's already been written.

### I want to review my current branch

Use [the code review skill](../han-coding/docs/skills/code-review.md).

### I want to review an open GitHub PR

Use [the `/post-code-review-to-pr` skill](../han-github/docs/skills/post-code-review-to-pr.md). This does everything the code review skill does, plus posts the review as a pull request comment.

### I want to review the architecture of an entire app module or subsystem

Use  [the architectural analysis skill](../han-coding/docs/skills/architectural-analysis.md). Han will analyze coupling, data flow, and alignment with SOLID principles. 

### I want to check if the code works, but I don't know how

If you'd like to generate an automated test for the code, use [the automated test planning skill](../han-coding/docs/skills/automated-test-planning.md). Han will produce a test plan that you can later ask it to implement. 

If you prefer to test by hand, use [the manual test planning skill](../han-coding/docs/skills/manual-test-planning.md). Han will create a plan-language plan including manual test steps and their expected outcomes. 

### I want to know if a feature is missing

Use [the gap analysis skill](../han-research/docs/skills/gap-analysis.md) to compare the current state of the code to the desired state. Han will generate a plain-language report of any feature gaps it uncovers.

### Artifacts

A code review document with findings labeled by filename, line number, and severity. 

## I want to research alternative ways to do something

I have a question. It's not yet a bug or a feature. I need options and a recommendation I can trust.

Use [the research skill](../han-research/docs/skills/research.md). Han will generate a report with evidence-backed, adversarially validated options and a recommendation.

If the question is actually a bug or feature, Han's research skill will route you down those paths instead.

When you select an option, you can document your decision using [the architectural decision record skill](https://github.com/testdouble/han/blob/main/han-documentation/docs/skills/architectural-decision-record.md).

If the decision involves creating or updating a plan or feature, you can use the [feature planning](https://github.com/testdouble/han/blob/main/han-planning/docs/skills/plan-a-feature.md) or [plan review](https://github.com/testdouble/han/blob/main/han-planning/docs/skills/iterative-plan-review.md) skills.

### Artifacts

A research report including options and a recommendation. All claims will be linked to verifiable sources, including results from the open web.

## I want to teach Han or other Claude skills about my app

Use [the project discovery skill](../han-core/docs/skills/project-discovery.md) to scan your codebase and generate a concise `### Project Discovery` section in your `AGENTS.md` or `CLAUDE.md` files.

The generated text will include your app's:
- programming languages 
- frameworks
- build commands
- directory structure

This isn't just useful for you. Han's skills reference this project summary for additional context.

If you want to document how your app works, use [the  project documentation skill](../han-documentation/docs/skills/project-documentation.md). For example:

> ```/project-documentation document the authentication system```

If your app has an undocumented coding standard that you want to formalize, use [the coding standard skill](../han-coding/docs/skills/coding-standard.md).

### Artifacts

A "Project Discovery" section in your `AGENTS.md` or `CLAUDE.md`, along with documentation related to how your app works and how you and your team work with your app.
