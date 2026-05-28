# Han: For the Solo Product Engineer

<img src="images/han-banner.png">

Han is a suite of AI skills and agents for solo (or small-team) product engineers. It combines evidence-based planning, test-driven implementation, full documentation maintenance, deep code review, and architectural analysis into a team of specialists you can dispatch from Claude Code.

## What this plugin does

Han turns planning, implementation, review, and documentation work that would normally take a team into a set of deterministic skills you run from Claude Code. Each skill dispatches specialist agents (project managers, adversarial reviewers, investigators, architectural analysts, testing and security specialists) to do the judgment-heavy work, then folds their findings into an artifact you can trust.

The skills are designed to compose. You can plan a feature, then plan its implementation, then iterate on the plan, then build it test-first, then review the resulting code, then write the PR description. All through named skills that hand off to each other cleanly.

Read [Concepts](./docs/concepts.md) for the skill-and-agent model that runs through the whole plugin.

## Which path are you on?

- **New to han?** → Start with [Concepts](./docs/concepts.md), then the [Quickstart](./docs/quickstart.md).
- **Looking for a specific skill?** → [Skills Index](./docs/skills/README.md). 20 skills grouped by purpose.
- **Looking for a specific agent?** → [Agents Index](./docs/agents/README.md). 23 agents grouped by role.
- **Wondering how the agent swarms scale?** → [Sizing](./docs/sizing.md). The small / medium / large dispatch model used by `/architectural-analysis`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`, and `/research`.
- **Wondering why a skill said "YAGNI"?** → [YAGNI](./docs/yagni.md). The evidence-based rule every planning, review, and architecture skill applies before committing items to an artifact.
- **Writing or editing a skill or agent?** → [Contributing](./CONTRIBUTING.md).

## Installation

Add the Test Double skills marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

## Documentation

- [Concepts](./docs/concepts.md). Skill vs. agent, and how they compose. Read once before using the plugin.
- [Quickstart](./docs/quickstart.md). Four paths for four common situations. Each path is a short sequence of skills.
- [Skills Index](./docs/skills/README.md). All 20 skills, grouped by purpose.
- [Agents Index](./docs/agents/README.md). All 23 agents, grouped by role.
- [Sizing](./docs/sizing.md). The small / medium / large model that decides how many agents the swarming skills dispatch.
- [YAGNI](./docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule every planning, review, and architecture skill applies.
- [Contributing](./CONTRIBUTING.md). Adding or editing skills, agents, and documentation.
- [Changelog](./CHANGELOG.md). What's new in each version of the plugin.

## Maintenance and Support

- **Maintenance horizon:** Indefinitely maintained, best-effort. No SLA.
- **Project type:** Personal project, with some Test Double support
- **How to report issues:** GitHub Issues, with expected best effort for response within 2 weeks.

Han is an open source product of [Test Double](https://testdouble.com), and maintained by the following people:

- [River Lynn Bailey](https://github.com/mxriverlynn): Creator, and primary maintainer

## LEGAL NOTICES

Copyright 2026 [Test Double, Inc](https://testdouble.com). Distributed under the [MIT license](./LICENSE).
