# Han: For the Solo Product Engineer

<img src="images/han-banner.png">

Han is a suite of AI skills and agents for solo (or small-team) product engineers. It combines evidence-based planning, test-driven implementation, full documentation maintenance, deep code review, and architectural analysis into a team of specialists you can dispatch from Claude Code.

## What this plugin does

Han turns planning, implementation, review, and documentation work that would normally take a team into a set of deterministic skills you run from Claude Code. Each skill dispatches specialist agents (project managers, adversarial reviewers, investigators, architectural analysts, testing and security specialists) to do the judgment-heavy work, then folds their findings into an artifact you can trust.

The skills are designed to compose. You can plan a feature, then plan its implementation, then iterate on the plan, then build it test-first, then review the resulting code, then write the PR description. All through named skills that hand off to each other cleanly.

Read [Concepts](./docs/concepts.md) for the skill-and-agent model that runs through the whole plugin.

## Which path are you on?

- **New to han?** → Start with [Concepts](./docs/concepts.md), then the [Quickstart](./docs/quickstart.md).
- **Looking for a specific skill?** → [Skills Index](./docs/skills/README.md). 18 skills grouped by purpose.
- **Looking for a specific agent?** → [Agents Index](./docs/agents/README.md). 21 agents grouped by role.
- **Wondering how the agent swarms scale?** → [Sizing](./docs/sizing.md). The small / medium / large dispatch model used by `/architectural-analysis`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, and `/plan-implementation`.
- **Wondering why a skill said "YAGNI"?** → [YAGNI](./docs/yagni.md). The evidence-based rule every planning, review, and architecture skill applies before committing items to an artifact.
- **Writing or editing a skill or agent?** → [Contributing](./CONTRIBUTING.md).

## Skills

Eighteen skills, grouped by the moment you reach for them. Each category links to the full long-form docs through the [Skills Index](./docs/skills/README.md).

### Planning

Spec what to build, plan how to build it, sequence it into phases, and stress-test the plan before you commit.

- **[`/plan-a-feature`](./docs/skills/plan-a-feature.md).** Build a feature specification from scratch through an evidence-based interview.
- **[`/plan-implementation`](./docs/skills/plan-implementation.md).** Turn a feature specification into an implementation plan through a project-manager-led team conversation.
- **[`/plan-a-phased-build`](./docs/skills/plan-a-phased-build.md).** Split a body of work into a numbered sequence of vertical-slice phases, each independently demoable.
- **[`/iterative-plan-review`](./docs/skills/iterative-plan-review.md).** Stress-test an existing plan through multiple codebase-grounded review passes.
- **[`/plan-work-items`](./docs/skills/plan-work-items.md).** Divide a trusted implementation plan into independently-grabbable work items in a single work-items file.

### Building

Write the code, test-first, through a disciplined red-green-refactor loop.

- **[`/tdd`](./docs/skills/tdd.md).** Drive a feature or behavior through a BDD-framed red-green-refactor loop with an enforced observed-failure gate, applying coding standards and ADRs in green and refactor.

### Investigation & root cause

Find out *why* something is broken, with evidence to back it.

- **[`/issue-triage`](./docs/skills/issue-triage.md).** Classify a vague issue or bug report, identify missing information, assess severity and reproducibility, and recommend the right next skill.
- **[`/investigate`](./docs/skills/investigate.md).** Evidence-based investigation of bugs, failures, and unexpected behavior, with adversarial validation of the proposed fix.

### Review & analysis

Get a second set of eyes on code that already exists.

- **[`/code-review`](./docs/skills/code-review.md).** Comprehensive code review of the current branch or specified files.
- **[`/gh-pr-review`](./docs/skills/gh-pr-review.md).** Run a code review against a GitHub PR and post the review as comments.
- **[`/architectural-analysis`](./docs/skills/architectural-analysis.md).** Deep architectural analysis of a module: coupling, data flow, concurrency, risk, and SOLID alignment.
- **[`/gap-analysis`](./docs/skills/gap-analysis.md).** Compare two artifacts (spec vs. implementation, PRD vs. shipped feature) and produce a plain-language report indexed by stable gap IDs.
- **[`/test-planning`](./docs/skills/test-planning.md).** Produce a prioritized test plan for a branch or directory.

### Discovery & context

Produce reference material every other skill (and future-you) benefits from.

- **[`/project-discovery`](./docs/skills/project-discovery.md).** Scan the repository for languages, frameworks, tooling, and structure.
- **[`/project-documentation`](./docs/skills/project-documentation.md).** Create and maintain documentation for features, systems, and components.

### Conventions & decisions

Codify how the team works.

- **[`/coding-standard`](./docs/skills/coding-standard.md).** Create and update coding standards from existing patterns or evidence-based research.
- **[`/architectural-decision-record`](./docs/skills/architectural-decision-record.md).** Create, extract, or convert architectural decision records.

### Reporting

Turn work into something shareable outside the repo.

- **[`/update-pr-description`](./docs/skills/update-pr-description.md).** Generate a PR description from the current branch's changes.

Not sure which category fits your situation? The [Quickstart](./docs/quickstart.md) has path-by-path guidance for the most common ones.

## Installation

Add the Test Double skills marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

## Documentation

- [Concepts](./docs/concepts.md). Skill vs. agent, and how they compose. Read once before using the plugin.
- [Quickstart](./docs/quickstart.md). Four paths for four common situations. Each path is a short sequence of skills.
- [Skills Index](./docs/skills/README.md). All 18 skills, grouped by purpose.
- [Agents Index](./docs/agents/README.md). All 21 agents, grouped by role.
- [Sizing](./docs/sizing.md). The small / medium / large model that decides how many agents the swarming skills dispatch.
- [YAGNI](./docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule every planning, review, and architecture skill applies.
- [Contributing](./CONTRIBUTING.md). Adding or editing skills, agents, and documentation.
- [Changelog](./CHANGELOG.md). What's new in each version of the plugin.

## Maintainance and Support

- **Maintenance horizon:** Indefinitely maintained, best-effort. No SLA.
- **Project type:** Personal project, with some Test Double support
- **How to report issues:** GitHub Issues, with expected best effort for response within 2 weeks.

Han is an open source product of [Test Double](https://testdouble.com), and maintained by the following people:

- [River Lynn Bailey](https://github.com/mxriverlynn): Creator, and primary maintainer

## LEGAL NOTICES

Copyright 2026 [Test Double, Inc](https://testdouble.com). Distributed under the [MIT license](./LICENSE).
