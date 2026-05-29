# Han: For the Solo Product Engineer

<img src="images/han-banner.png">

Han is a suite of AI skills and agents for solo (or small-team) product engineers. It combines evidence-based planning, test-driven implementation, full documentation maintenance, deep code review, and architectural analysis into a team of specialists you can dispatch from Claude Code.

## What this plugin does

Han turns planning, implementation, review, and documentation work that would normally take a team into a set of deterministic skills you run from Claude Code. Each skill dispatches specialist agents (project managers, adversarial reviewers, investigators, architectural analysts, testing and security specialists) to do the judgment-heavy work, then folds their findings into an artifact you can trust.

The skills are designed to compose. You can plan a feature, then plan its implementation, then iterate on the plan, then build it test-first, then review the resulting code, then write the PR description. All through named skills that hand off to each other cleanly.

Read [Concepts](./docs/concepts.md) for the skill-and-agent model that runs through the whole plugin.

> **Evaluating Han for a larger org?** Han is built for solo product engineers and small teams, not for large teams or enterprise. Read [Why solo and small teams, and not large teams or enterprise?](./docs/why-solo-and-small-teams.md) for the honest fit answer before going further.

## Which path are you on?

### Getting started

- **New to han?** → Start with [Concepts](./docs/concepts.md), then the [Quickstart](./docs/quickstart.md).
- **Deciding which plugin to install?** → [Choosing a Han plugin](./docs/choosing-a-han-plugin.md). The bundled suite, core only, the opt-in `han.feedback` plugin, and the dependency that surprises people, with a quick "which one do you need?" guide.

### Running a workflow

- **Want the end-to-end recipe for a workflow?** → [How-to guides](./docs/how-to/README.md). Plan a feature, triage and investigate a bug, or research a decision, walked through step by step.
- **Want to send the maintainers feedback?** → [How to provide feedback on Han](./docs/how-to/provide-feedback.md). Shape an idea or complaint into a postable issue with `/issue-triage`, or summarize a session with the opt-in `han.feedback` plugin.

### Finding a skill or agent

- **Looking for a specific skill?** → [Skills Index](./docs/skills/README.md). All skills grouped by purpose.
- **Looking for a specific agent?** → [Agents Index](./docs/agents/README.md). All agents grouped by role.

### Understanding how Han works

- **Wondering how the agent swarms scale?** → [Sizing](./docs/sizing.md). The small / medium / large dispatch model used by `/architectural-analysis`, `/code-review`, `/gap-analysis`, `/iterative-plan-review`, `/plan-a-feature`, `/plan-implementation`, and `/research`.
- **Wondering why a skill said "YAGNI"?** → [YAGNI](./docs/yagni.md). The evidence-based rule every planning, review, and architecture skill applies before committing items to an artifact.
- **Wondering what counts as evidence?** → [Evidence](./docs/evidence.md). The three principles (proximity, corroboration, no-evidence labeling) and the trust-class vocabulary every evidence-aware skill and agent applies.

### Extending and contributing

- **Want to extend Han with custom skills?** → [Extend Han with plugin dependencies](./docs/how-to/extend-han-with-plugin-dependencies.md) explains how one plugin builds on another through the `dependencies` field, using Han's own multi-plugin split as the worked example. [Build a plugin that depends on Han](./docs/how-to/build-a-plugin-that-depends-on-han.md) is the hands-on walkthrough: stand up your own plugin, add a skill that builds on `han.core`, and confirm a clean install pulls Han in alongside it.
- **Writing or editing a skill or agent?** → [Contributing](./CONTRIBUTING.md).

## Installation

Add the Test Double skills marketplace to Claude Code, then install the plugin:

```
/plugin marketplace add testdouble/han
/plugin install han@han
```

Han ships as five plugins:
* `han`: a meta-plugin with no components of its own that depends on `han.core`, `han.github`, and `han.reporting`
* `han.core`: the planning, investigation, review, and documentation skills plus every agent
* `han.github`: GitHub-facing skills like posting a code review on a PR
* `han.reporting`: reporting skills like the stakeholder summary
* `han.feedback`: an opt-in skill for capturing post-session feedback on Han skill runs

Installing `han@han` pulls in the bundled suite (the meta-plugin plus `han.core`, `han.github`, and `han.reporting`),
and is the right choice for almost everyone. If you do not want the GitHub or reporting skills, install `han.core@han`
instead. There is no GitHub-only or reporting-only install: both `han.github` and `han.reporting` depend on `han.core`,
so installing either brings the core skills and every agent along with it. `han.feedback` is the exception: it depends
on `han.core` too, but the `han` meta-plugin does not pull it in, so install it separately with `han.feedback@han` if
you want it. For the full picture and a quick "which one do you need?" guide,
see [Choosing a Han plugin](./docs/choosing-a-han-plugin.md).

## Documentation

- [Concepts](./docs/concepts.md). Skill vs. agent, and how they compose. Read once before using the plugin.
- [Choosing a Han plugin](./docs/choosing-a-han-plugin.md). The full suite vs. core only, the `han.github` and `han.reporting` dependencies on `han.core`, and a quick guide to which one to install.
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
