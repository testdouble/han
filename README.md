# Han: For the Solo Product Engineer

<img src="images/han-banner.png">

Han is a suite of AI skills and agents for solo (or small-team) product engineers. It combines
evidence-based planning, test-driven implementation, full documentation maintenance, deep code review, and
architectural analysis into a team of specialists you can dispatch from Claude Code.

## What this plugin does

Han turns planning, implementation, review, and documentation work that would normally take a team into a
set of deterministic skills you run from Claude Code. Each skill dispatches specialist agents (project
managers, adversarial reviewers, investigators, architectural analysts, testing and security specialists)
to do the judgment-heavy work, then folds their findings into an artifact you can trust.

The skills are designed to compose. You can plan a feature, then plan its implementation, then iterate on
the plan, then build it test-first, then review the resulting code, then write the PR description. All
through named skills that hand off to each other cleanly.

Read [Concepts](./docs/concepts.md) for the skill-and-agent model that runs through the whole plugin.

## For Solo Product Engineers and Small Teams

Han is purpose-built for solo product engineers and small teams, instead of large teams or enterprise. This
does not mean it can't work in larger teams, though. Read about why
[Han's focus is solo product engineers and small teams](./docs/why-solo-and-small-teams.md) to understand
Han's positioning and what it does not bring to the table.

## Installation

## Claude Code

Add the Test Double skills marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

Han ships as multiple plugins:

| Plugin | Type | What it brings |
| --- | --- | --- |
| **`han`** | parent | the parent plugin that brings in `han-core`, `han-planning`, `han-coding`, `han-github`, and `han-reporting` |
| `han-core` | bundled | research, analysis, and documentation skills plus every agent |
| `han-planning` | bundled | planning skills you reach for before implementation |
| `han-coding` | bundled | coding skills you reach for while working in code |
| `han-github` | bundled | GitHub-facing skills like posting a code review on a PR |
| `han-reporting` | bundled | reporting skills like the stakeholder summary |
| `han-feedback` | opt-in | skill for capturing post-session feedback on Han skill runs |
| `han-atlassian` | opt-in | skills for publishing docs and work items to Atlassian products |
| `han-linear` | opt-in | skill for publishing work items to Linear (requires a Linear MCP server) |
| `han-plugin-builder` | opt-in | carries the guidance and skills for building your own skills, agents, and plugins |

Installing `han@han` pulls in the bundled suite (the meta-plugin plus `han-core`, `han-planning`,
`han-coding`, `han-github`, and `han-reporting`), and is the right choice for most people. If you do
not want the planning, coding, GitHub, or reporting skills, install `han-core@han` instead, and add other
specific plugins as desired.

For the full picture and a quick "which one do you need?" guide, see [Choosing a Han plugin](./docs/choosing-a-han-plugin.md).

### Codex

Add this repo as a Codex marketplace:

```
codex plugin marketplace add testdouble/han
```

Codex does not yet support meta-plugins like `han@han` (see openai/codex#23531,) so install the Han packages directly:

```
codex plugin add han-core@han
codex plugin add han-planning@han
codex plugin add han-coding@han
codex plugin add han-github@han
codex plugin add han-reporting@han
```

Install `han-feedback`, `han-atlassian`, `han-linear`, or `han-plugin-builder`
separately when you want those opt-in packages.

## Documentation

- [Concepts](./docs/concepts.md). Skill vs. agent, and how they compose. Read once before using the plugin.
- [Choosing a Han plugin](./docs/choosing-a-han-plugin.md). The full suite vs. core only, the
  `han-planning`, `han-coding`, `han-github`, and `han-reporting` dependencies on `han-core`, and a quick
  guide to which one to install.
- [Quickstart](./docs/quickstart.md). Five paths for five common situations. Each path is a short sequence of skills.
- [Skills Index](./docs/skills/README.md). All skills, grouped by purpose.
- [Agents Index](./docs/agents/README.md). All agents, grouped by role.
- [Sizing](./docs/sizing.md). The small / medium / large model that decides how many agents the swarming
  skills dispatch.
- [YAGNI](./docs/yagni.md). The evidence-based "You Aren't Gonna Need It" rule every planning, review, and
  architecture skill applies.
- [Evidence](./docs/evidence.md). What counts as evidence in Han, how to characterize how strong it is, and
  what to do when no evidence exists at all.
- [Changelog](./CHANGELOG.md). What's new in each version of the plugin.

### How-To Guides

- [How-to guides](./docs/how-to/README.md). End-to-end recipes for planning a feature, revising a plan
  after the build starts, triaging and investigating a bug, and researching a decision. Pick one when you
  want the full walkthrough, not only the path.
- [How to provide feedback on Han](./docs/how-to/provide-feedback.md). Send the maintainers structured
  feedback on a skill or agent run.
- [Extend Han via dependencies](./docs/how-to/extend-han-with-plugin-dependencies.md). Add your own custom
  skills on top of Han.
- [Build a plugin that depends on Han](./docs/how-to/build-a-plugin-that-depends-on-han.md). Ship a plugin
  that builds on Han's skills and agents.

### Contributing to Han

- [Contributing](./CONTRIBUTING.md). Adding or editing skills, agents, and documentation.
- [Create a new skill](./docs/how-to/create-a-new-skill.md). Build a new slash command from scratch with
  `/skill-builder`.
- [Create a new agent](./docs/how-to/create-a-new-agent.md). Build a new subagent from scratch with
  `/agent-builder`.

## Maintenance and Support

- **Maintenance horizon:** Indefinitely maintained, best-effort. No SLA.
- **Project type:** Personal project, with some Test Double support
- **How to report issues:** GitHub Issues, with expected best effort for response within 2 weeks.

Han is an open source product of [Test Double](https://testdouble.com), and maintained by the following people:

- [River Lynn Bailey](https://github.com/mxriverlynn): Creator, and primary maintainer

## LEGAL NOTICES

Copyright 2026 [Test Double, Inc](https://testdouble.com). Distributed under the [MIT license](./LICENSE).
