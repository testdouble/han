# Workflows

This page is the map of which Han skills chain together. Most real work runs several skills in sequence, where one
skill's output becomes the next one's input. This page shows the common chains, with a flow diagram wherever a chain
branches enough that a picture beats the prose.

It is one of four navigation surfaces, and each has a distinct job:

- **This page (Workflows)** is the map of which skills chain together.
- **[Quickstart](./quickstart.md)** gives you do-this-now paths for five common situations.
- **[How-to guides](./how-to/README.md)** walk a single task end to end, step by step.
- **[Concepts](./concepts.md)** explains the skill-and-agent model the whole suite is built on.

If you know the task but not the sequence, you are in the right place. If you want the model behind the skills, read
Concepts first.

## From a problem to a shipped change

The planning skills feed the coding and delivery skills. This is the longest chain in the suite, and it branches at
several points depending on what you already know and where the work is tracked.

```mermaid
flowchart TD
    triage["/issue-triage"] --> research["/research"]
    triage --> investigate["/investigate"]
    research --> feature["/plan-a-feature"]
    feature --> impl["/plan-implementation"]
    impl --> review["/iterative-plan-review"]
    review --> items["/plan-work-items"]
    impl --> items
    items --> gh["/work-items-to-issues (GitHub)"]
    items --> jira["/work-items-to-jira (Jira)"]
    items --> linear["/work-items-to-linear (Linear)"]
    gh --> build["/tdd"]
    jira --> build
    linear --> build
    pairing["/pairing"] -.drives.-> impl
    pairing -.drives.-> review
    pairing -.drives.-> build
```

- **[`/issue-triage`](../han-research/docs/skills/issue-triage.md) → [`/investigate`](../han-coding/docs/skills/investigate.md).**
  When a report is vague, triage it first, then investigate the root cause.
- **[`/issue-triage`](../han-research/docs/skills/issue-triage.md) →
  [`/research`](../han-research/docs/skills/research.md) → [`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md).**
  When triage finds a problem-space unknown, research the options first, then specify the chosen one.
- **[`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md) →
  [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md) →
  [`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md) →
  [`/plan-work-items`](../han-planning/docs/skills/plan-work-items.md).** Specify, plan the build, stress-test the plan,
  then break it into work. Skip the review pass when the plan is already trusted.
- **[`/plan-work-items`](../han-planning/docs/skills/plan-work-items.md) → publish.** Turn the work items into tickets
  where your team tracks them: [`/work-items-to-issues`](../han-github/docs/skills/work-items-to-issues.md) for GitHub,
  [`/work-items-to-jira`](../han-atlassian/docs/skills/work-items-to-jira.md) for Jira (opt-in `han-atlassian`), or
  [`/work-items-to-linear`](../han-linear/docs/skills/work-items-to-linear.md) for Linear (opt-in `han-linear`).
- **[`/pairing`](../han-core/docs/skills/pairing.md) drives
  [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md) and
  [`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md).** Both run their rounds without
  pausing today, so this is where the wrapper changes the most: you see each round as it closes rather than only the
  finished plan.

## From a gap to a plan

When you have two artifacts to compare (a spec against an implementation, a PRD against a shipped feature), start from
the gap report and route its findings into planning.

```mermaid
flowchart TD
    gap["/gap-analysis"] --> impl["/plan-implementation"]
    gap --> phased["/plan-a-phased-build"]
    phased --> impl
```

- **[`/gap-analysis`](../han-research/docs/skills/gap-analysis.md) →
  [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md).** The gap report's `G-NNN` IDs become
  work in the implementation plan.
- **[`/gap-analysis`](../han-research/docs/skills/gap-analysis.md) →
  [`/plan-a-phased-build`](../han-planning/docs/skills/plan-a-phased-build.md) →
  [`/plan-implementation`](../han-planning/docs/skills/plan-implementation.md).** Order the `G-NNN` IDs into vertical
  slices first, then give each greenlit phase its own implementation plan.

## Working in code

The review, refactor, and build skills chain in both directions: a review can feed a refactor, and a refactor can
prepare the ground for a test-first build.

```mermaid
flowchart TD
    review["/code-review"] --> refactor["/refactor"]
    arch["/architectural-analysis"] --> refactor
    arch --> design["/design-an-api"]
    design --> tdd["/tdd"]
    review --> pr["/post-code-review-to-pr"]
    refactor --> tdd
    tdd --> prdesc["/update-pr-description"]
    investigate["/investigate"] --> iterate["/iterative-plan-review"]
    pairing["/pairing"] -.drives.-> refactor
    pairing -.drives.-> tdd
    pairing -.drives.-> design
```

- **[`/code-review`](../han-coding/docs/skills/code-review.md) →
  [`/post-code-review-to-pr`](../han-github/docs/skills/post-code-review-to-pr.md).** Review locally, then post the
  review to the PR.
- **[`/code-review`](../han-coding/docs/skills/code-review.md) or
  [`/architectural-analysis`](../han-coding/docs/skills/architectural-analysis.md) →
  [`/refactor`](../han-coding/docs/skills/refactor.md).** The review's structural findings become the refactoring plan's
  work orders.
- **[`/refactor`](../han-coding/docs/skills/refactor.md) → [`/tdd`](../han-coding/docs/skills/tdd.md).** Preparatory
  refactoring makes the change easy, then `/tdd` makes the easy change.
- **[`/architectural-analysis`](../han-coding/docs/skills/architectural-analysis.md) →
  [`/design-an-api`](../han-coding/docs/skills/design-an-api.md) → [`/tdd`](../han-coding/docs/skills/tdd.md).** Judge
  the structure you are designing into, shape the contract against one stated goal, then implement it test-first. The
  analysis step is optional; `/design-an-api` runs its own discovery wave when you start there.
- **[`/investigate`](../han-coding/docs/skills/investigate.md) →
  [`/iterative-plan-review`](../han-planning/docs/skills/iterative-plan-review.md).** Root-cause the bug, then stress-test
  the proposed fix.
- **[`/tdd`](../han-coding/docs/skills/tdd.md) →
  [`/update-pr-description`](../han-github/docs/skills/update-pr-description.md).** Once the branch carries the change,
  turn its commits into the PR body. This is the description half of the PR; `/post-code-review-to-pr` is the review half,
  and the two are independent.
- **[`/pairing`](../han-core/docs/skills/pairing.md) drives
  [`/refactor`](../han-coding/docs/skills/refactor.md), [`/tdd`](../han-coding/docs/skills/tdd.md), and
  [`/design-an-api`](../han-coding/docs/skills/design-an-api.md).** This is not a chain but a wrapper: `/pairing` runs one
  of them and takes control back at each unit boundary, so you review as the work lands rather than at the end. Invoking
  any of the three directly runs it straight through, unchanged.

## Planning the tests

Two skills plan tests, and they split on who runs them. Both take the same kinds of input (a branch, a feature, a plan, a
PR), so pick by the audience rather than by the stage.

```mermaid
flowchart TD
    auto["/automated-test-planning"] --> tdd["/tdd"]
    manual["/manual-test-planning"]
```

- **[`/automated-test-planning`](../han-coding/docs/skills/automated-test-planning.md) →
  [`/tdd`](../han-coding/docs/skills/tdd.md).** Find the coverage gaps and edge cases first, then implement the tests
  test-first. The plan names what to write; `/tdd` writes it.
- **[`/manual-test-planning`](../han-coding/docs/skills/manual-test-planning.md).** The sibling for steps a person runs by
  hand, as an acceptance walkthrough or a QA pass. It ends at the document, because nothing downstream automates it.

## Understanding and documenting a codebase

These chains are linear, so they need no diagram.

- **[`/project-discovery`](../han-core/docs/skills/project-discovery.md) →
  [`/project-documentation`](../han-documentation/docs/skills/project-documentation.md) →
  [`/coding-standard`](../han-coding/docs/skills/coding-standard.md).** Discover the project, document it, then capture
  its conventions as standards.
- **[`/code-overview`](../han-coding/docs/skills/code-overview.md) →
  [`/code-review`](../han-coding/docs/skills/code-review.md).** Get oriented in unfamiliar code or a PR first, then judge
  whether it is any good.
- **[`/code-walkthrough`](../han-coding/docs/skills/code-walkthrough.md) →
  [`/code-review`](../han-coding/docs/skills/code-review.md).** The same chain when you want to be taught rather than
  handed a document: walk the change one step at a time, asking questions as you go, then review it. Reach for
  `/code-overview` instead when you want one artifact you can keep, share, or paste into a PR description.
- **[`/project-documentation`](../han-documentation/docs/skills/project-documentation.md) → the specialized documents.**
  Feature and system docs live in `/project-documentation`, but three kinds of writing route elsewhere: a decision and its
  rejected alternatives go to
  [`/architectural-decision-record`](../han-documentation/docs/skills/architectural-decision-record.md), an operational
  scenario someone gets paged for goes to [`/runbook`](../han-documentation/docs/skills/runbook.md), and an enforceable
  convention goes to [`/coding-standard`](../han-coding/docs/skills/coding-standard.md).

## Sharing the work with a non-technical reader

A specification is written for the people who will build the thing. These two skills turn it into something for the
people who are funding or approving it.

```mermaid
flowchart TD
    feature["/plan-a-feature"] --> summary["/stakeholder-summary"]
    summary --> html["/html-summary"]
```

- **[`/plan-a-feature`](../han-planning/docs/skills/plan-a-feature.md) →
  [`/stakeholder-summary`](../han-reporting/docs/skills/stakeholder-summary.md) →
  [`/html-summary`](../han-reporting/docs/skills/html-summary.md).** Specify the feature, restate it in plain language for
  stakeholders, then render that summary as a single self-contained HTML file you can send to someone.
- **[`/edit-for-readability`](../han-communication/docs/skills/edit-for-readability.md).** The polish pass for any of it.
  Point it at a document any other skill produced, or at a draft in the conversation, and it rewrites the prose against the
  shared readability standard without changing a fact.

## Related documentation

- [Repo root](../README.md). The Han suite landing page.
- [Skills index](./skills/README.md). Every skill, with a scent line and a link to its long-form doc.
- [Agents index](./agents/README.md). Every agent the skills dispatch.
- [Plugin index](./choosing-a-han-plugin.md). Every plugin and which one to install.
- [Quickstart](./quickstart.md), [How-to guides](./how-to/README.md), [Concepts](./concepts.md). The other three
  navigation surfaces.
