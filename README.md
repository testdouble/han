# Han: For the Solo Product Engineer

<img src="images/han-banner.png">

Han is a suite of AI skills and agents for solo (or small-team) product engineers. It combines evidence-based planning, test-driven implementation, full documentation maintenance, deep code review, and architectural analysis into a team of specialists you can dispatch from Claude Code.

## What this plugin does

Han turns planning, implementation, review, and documentation work that would normally take a team into a set of deterministic skills you run from Claude Code. Each skill dispatches specialist agents (project managers, adversarial reviewers, investigators, architectural analysts, testing and security specialists) to do the judgment-heavy work, then folds their findings into an artifact you can trust.

The skills are designed to compose. You can plan a feature, then plan its implementation, then iterate on the plan, then build it test-first, then review the resulting code, then write the PR description. All through named skills that hand off to each other cleanly.

Read [Concepts](./docs/concepts.md) for the skill-and-agent model that runs through the whole plugin.

> **Evaluating Han for a larger org?** Han is built for solo product engineers and small teams, not for large teams or enterprise. Read [Why solo and small teams, and not large teams or enterprise?](./docs/why-solo-and-small-teams.md) for the honest fit answer before going further.

## Which path are you on?

- **New to han?** → Start with [Concepts](./docs/concepts.md), then the [Quickstart](./docs/quickstart.md).
- **Deciding which plugin to install?** → [Choosing a Han plugin](./docs/choosing-a-han-plugin.md). The full suite, core only, and the dependency that surprises people, with a quick "which one do you need?" guide.
- **Want the end-to-end recipe for a workflow?** → [How-to guides](./docs/how-to/README.md). Plan a feature, triage and investigate a bug, or research a decision, walked through step by step.
- **Looking for a specific skill?** → [Skills Index](./docs/skills/README.md). All skills grouped by purpose.
- **Looking for a specific agent?** → [Agents Index](./docs/agents/README.md). All agents grouped by role.
- **Wondering how the agent swarms scale?** → [Sizing](./docs/sizing.md). The small / medium / large dispatch model used by `/architectural-analysis`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`, and `/research`.
- **Wondering why a skill said "YAGNI"?** → [YAGNI](./docs/yagni.md). The evidence-based rule every planning, review, and architecture skill applies before committing items to an artifact.
- **Wondering what counts as evidence?** → [Evidence](./docs/evidence.md). The three principles (proximity, corroboration, no-evidence labeling) and the trust-class vocabulary every evidence-aware skill and agent applies.
- **Writing or editing a skill or agent?** → [Contributing](./CONTRIBUTING.md).

## Installation

Add the Test Double skills marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

Han ships as three plugins: `han.core` (the planning, investigation, review, and documentation skills plus every agent), `han.github` (GitHub-facing skills like posting a code review on a PR), and `han` (a meta-plugin with no components of its own that depends on the other two). Installing `han@han` pulls in the whole suite, and is the right choice for almost everyone. If you do not want the GitHub skills, install `han.core@han` instead. There is no GitHub-only install: `han.github` depends on `han.core`, so installing it brings the core skills and every agent along with it. For the full picture and a quick "which one do you need?" guide, see [Choosing a Han plugin](./docs/choosing-a-han-plugin.md).

## Documentation

- [Concepts](./docs/concepts.md). Skill vs. agent, and how they compose. Read once before using the plugin.
- [Choosing a Han plugin](./docs/choosing-a-han-plugin.md). The full suite vs. core only, the `han.github` dependency on `han.core`, and a quick guide to which one to install.
- [Quickstart](./docs/quickstart.md). Five paths for five common situations. Each path is a short sequence of skills.
- [How-to guides](./docs/how-to/README.md). End-to-end recipes for planning a feature, triaging and investigating a bug, and researching a decision. Pick one when you want the full walkthrough, not only the path.
- [Skills Index](./docs/skills/README.md). All skills, grouped by purpose.
- [Agents Index](./docs/agents/README.md). All agents, grouped by role.
- [Sizing](./docs/sizing.md). The small / medium / large model that decides how many agents the swarming skills dispatch.
- [YAGNI](./docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule every planning, review, and architecture skill applies.
- [Evidence](./docs/evidence.md). What counts as evidence in Han, how to characterize how strong it is, and what to do when no evidence exists at all.
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
